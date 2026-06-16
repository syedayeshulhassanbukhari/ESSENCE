const { parseChatId } = require('../utils/chatId');
const { requireChatPayload, requireString, sanitizeMessageText } = require('../utils/validation');

function registerSocketHandlers(io, { chatService, listingService, presenceStore }) {
  const typingTimers = new Map();

  io.on('connection', (socket) => {
    const userId = socket.user.uid;
    socket.data.userId = userId;
    socket.data.joinedChats = new Set();

    console.log('[AUTH] userId:', userId);

    const firstSocket = presenceStore.connect(userId);
    if (firstSocket) {
      socket.broadcast.emit('presence_update', {
        userId,
        online: true,
      });
    }

    socket.on('join_chat', async (payload) => {
      try {
        const body = requireChatPayload(payload);
        const chatId = requireString(body.chatId, 'chatId');
        const listingId = typeof body.listingId === 'string' ? body.listingId.trim() : '';
        console.log('[SOCKET_JOIN] room:', chatId, 'userId:', userId, 'listingId:', listingId || '(none)');

        const { participants } = parseChatId(chatId);
        if (participants.length !== 2 || !participants.includes(userId)) {
          throw permissionError('You are not allowed to join this chat room.');
        }

        const sellerId = participants.find((participant) => participant !== userId) || '';
        if (!sellerId) {
          throw permissionError('You are not allowed to join this chat room.');
        }

        if (listingId) {
          const listing = await listingService.getListingForChat(listingId, userId);
          if (listing.ownerId !== sellerId) {
            throw permissionError('You are not allowed to join this chat room.');
          }
        }

        await chatService.ensureChatRoom({
          chatId,
          listingId,
          buyerId: userId,
          sellerId,
        });

        socket.join(chatId);
        socket.data.joinedChats.add(chatId);
        console.log('[SOCKET_JOIN] confirmed:', { chatId, userId });

        socket.to(chatId).emit('presence_update', {
          chatId,
          userId,
          online: presenceStore.isOnline(userId),
        });

        socket.emit('presence_update', {
          chatId,
          userId: sellerId,
          online: presenceStore.isOnline(sellerId),
        });
      } catch (error) {
        console.error('[Socket] Error in join_chat:', error.message);
        emitSocketError(socket, error);
      }
    });

    socket.on('send_message', async (payload) => {
      try {
        const body = requireChatPayload(payload);
        const chatId = requireString(body.chatId, 'chatId');
        const receiverId = requireString(body.receiverId, 'receiverId');
        const text = sanitizeMessageText(body.text);
        const clientMessageId = typeof body.clientMessageId === 'string' ? body.clientMessageId : '';
        const listingId = typeof body.listingId === 'string' ? body.listingId.trim() : '';

        console.log('[CHAT_CLICK] sender:', userId, 'receiver:', receiverId);
        console.log('[SEND_MESSAGE] payload:', {
          chatId,
          senderId: userId,
          receiverId,
          clientMessageId,
        });

        const { participants } = parseChatId(chatId);

        if (participants.length !== 2 || !participants.includes(userId) || !participants.includes(receiverId)) {
          console.error('[Socket] Permission denied: user or receiver not in participants', { userId, receiverId, participants });
          throw permissionError('You cannot send messages in this chat.');
        }

        if (!socket.data.joinedChats.has(chatId)) {
          console.warn('[Socket] User attempted to send message without joining room:', { userId, chatId });
          throw permissionError('Join the chat before sending messages.');
        }

        const message = await chatService.sendMessage({
          chatId,
          senderId: userId,
          receiverId,
          text,
          clientMessageId,
          listingId,
        });

        console.log('[Socket] Message saved to Firestore:', {
          messageId: message.messageId,
          clientMessageId: message.clientMessageId,
        });

        const receiverPayload = {
          ...message,
          deliveryStatus: 'received',
          isSender: false,
        };
        const senderPayload = {
          ...message,
          deliveryStatus: 'sent',
          isSender: true,
        };

        socket.to(chatId).emit('message_received', receiverPayload);
        socket.emit('message_received', senderPayload);
        console.log('[SEND_MESSAGE] chatId:', chatId, 'clientMessageId:', message.clientMessageId);
      } catch (error) {
        console.error('[Socket] Error in send_message:', error.message);
        emitSocketError(socket, error);
      }
    });

    socket.on('typing', (payload) => {
      try {
        const body = requireChatPayload(payload);
        const chatId = requireString(body.chatId, 'chatId');
        if (!socket.data.joinedChats.has(chatId)) {
          throw permissionError('Join the chat before sending typing status.');
        }

        const timerKey = `${chatId}:${userId}`;
        if (typingTimers.has(timerKey)) {
          clearTimeout(typingTimers.get(timerKey));
        }

        socket.to(chatId).emit('typing_status', {
          chatId,
          userId,
          typing: true,
        });

        const timeoutMs = Number(process.env.CHAT_TYPING_TIMEOUT_MS || 3000);
        typingTimers.set(timerKey, setTimeout(() => {
          socket.to(chatId).emit('typing_status', {
            chatId,
            userId,
            typing: false,
          });
          typingTimers.delete(timerKey);
        }, timeoutMs));
      } catch (error) {
        emitSocketError(socket, error);
      }
    });

    socket.on('mark_seen', async (payload) => {
      try {
        const body = requireChatPayload(payload);
        const chatId = requireString(body.chatId, 'chatId');
        if (!socket.data.joinedChats.has(chatId)) {
          throw permissionError('Join the chat before marking messages as seen.');
        }

        const result = await chatService.markSeen({
          chatId,
          readerId: userId,
        });

        socket.to(chatId).emit('message_seen', {
          chatId,
          readerId: userId,
          updatedCount: result.updatedCount,
        });
      } catch (error) {
        emitSocketError(socket, error);
      }
    });

    socket.on('disconnect', () => {
      const lastSocket = presenceStore.disconnect(userId);

      if (lastSocket) {
        io.emit('presence_update', {
          userId,
          online: false,
        });
      }

      for (const chatId of socket.data.joinedChats) {
        if (lastSocket) {
          socket.to(chatId).emit('presence_update', {
            userId,
            online: false,
          });
        }

        const timerKey = `${chatId}:${userId}`;
        if (typingTimers.has(timerKey)) {
          clearTimeout(typingTimers.get(timerKey));
          typingTimers.delete(timerKey);
        }
      }
    });
  });
}

function emitSocketError(socket, error) {
  socket.emit('api_error', {
    code: error.code || 'error',
    message: error.message || 'Request failed.',
  });
}

function permissionError(message) {
  const error = new Error(message);
  error.code = 'permission_denied';
  error.statusCode = 403;
  return error;
}

module.exports = {
  registerSocketHandlers,
};


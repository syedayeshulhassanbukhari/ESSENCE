const { FieldValue } = require('firebase-admin/firestore');
const { parseChatId } = require('../utils/chatId');
const { requireString, sanitizeMessageText } = require('../utils/validation');

class ChatService {
  constructor({ db }) {
    this.db = db;
    this.maxHistoryLimit = Number(process.env.CHAT_HISTORY_LIMIT || 50);
  }

  getChatRef(chatId) {
    return this.db.collection('chats').doc(chatId);
  }

  getMessagesCollection(chatId) {
    return this.db.collection('messages').doc(chatId).collection('items');
  }

  async ensureChatRoom({ chatId, listingId = '', buyerId, sellerId }) {
    const normalizedUsers = normalizeUsers([buyerId, sellerId]);
    const chatRef = this.getChatRef(chatId);
    const snapshot = await chatRef.get();
    const safeListingId = typeof listingId === 'string' ? listingId.trim() : '';

    if (!snapshot.exists) {
      await chatRef.set({
        chatId,
        listingId: safeListingId,
        buyerId,
        sellerId,
        users: normalizedUsers,
        lastMessage: '',
        lastSenderId: '',
        buyerUnreadCount: 0,
        sellerUnreadCount: 0,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        lastMessageAt: null,
      }, { merge: true });
    } else {
      const updateData = {
        chatId,
        buyerId,
        sellerId,
        users: normalizedUsers,
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (safeListingId) {
        updateData.listingId = safeListingId;
      }

      await chatRef.set(updateData, { merge: true });
    }

    return this.getChatForUser(chatId, buyerId);
  }

  async getChatForUser(chatId, userId) {
    const id = requireString(chatId, 'chatId');
    const requester = requireString(userId, 'userId');
    const snapshot = await this.getChatRef(id).get();

    if (!snapshot.exists) {
      const error = new Error('Chat not found.');
      error.code = 'chat_not_found';
      error.statusCode = 404;
      throw error;
    }

    const data = snapshot.data() || {};
    if (!Array.isArray(data.users) || !data.users.includes(requester)) {
      const error = new Error('You do not have access to this chat.');
      error.code = 'permission_denied';
      error.statusCode = 403;
      throw error;
    }

    return {
      chatId: snapshot.id,
      ...data,
    };
  }

  async listChatsForUser(userId) {
    const requester = requireString(userId, 'userId');
    const snapshot = await this.db.collection('chats')
      .where('users', 'array-contains', requester)
      .orderBy('updatedAt', 'desc')
      .get();

    return snapshot.docs.map((doc) => ({
      chatId: doc.id,
      ...doc.data(),
    }));
  }

  async getMessagesForUser(chatId, userId, limit = this.maxHistoryLimit) {
    const chat = await this.getChatForUser(chatId, userId);
    const safeLimit = clamp(limit, 1, 100);
    const snapshot = await this.getMessagesCollection(chat.chatId)
      .orderBy('createdAt', 'desc')
      .limit(safeLimit)
      .get();

    return snapshot.docs.map((doc) => ({
      messageId: doc.id,
      ...doc.data(),
    })).reverse();
  }

  async sendMessage({ chatId, senderId, receiverId, text, clientMessageId, listingId = '' }) {
    const safeChatId = requireString(chatId, 'chatId');
    const safeSenderId = requireString(senderId, 'senderId');
    const safeReceiverId = requireString(receiverId, 'receiverId');
    const safeText = sanitizeMessageText(text);

    const { listingId: parsedListingId, participants } = parseChatId(safeChatId);
    if (!participants.includes(safeSenderId) || !participants.includes(safeReceiverId)) {
      const error = new Error('Sender or receiver does not belong to this chat.');
      error.code = 'permission_denied';
      error.statusCode = 403;
      throw error;
    }

    if (safeSenderId === safeReceiverId) {
      const error = new Error('Receiver must be different from sender.');
      error.code = 'invalid_participants';
      error.statusCode = 400;
      throw error;
    }

    const chatRef = this.getChatRef(safeChatId);
    const messageRef = this.getMessagesCollection(safeChatId).doc();
    const safeListingId = typeof listingId === 'string' ? listingId.trim() : '';

    await this.db.runTransaction(async (transaction) => {
      const chatSnapshot = await transaction.get(chatRef);

      if (!chatSnapshot.exists) {
        transaction.set(chatRef, {
          chatId: safeChatId,
          listingId: safeListingId || parsedListingId,
          buyerId: participants[0],
          sellerId: participants[1],
          users: participants,
          lastMessage: safeText,
          lastSenderId: safeSenderId,
          buyerUnreadCount: 0,
          sellerUnreadCount: 0,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
          lastMessageAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      } else {
        const chatData = chatSnapshot.data() || {};
        const currentUsers = Array.isArray(chatData.users) ? chatData.users : [];
        if (!participants.every((participant) => currentUsers.includes(participant)) && currentUsers.length > 0) {
          const error = new Error('Chat membership does not match the requested room.');
          error.code = 'permission_denied';
          error.statusCode = 403;
          throw error;
        }

        transaction.set(chatRef, {
          chatId: safeChatId,
          buyerId: chatData.buyerId || participants[0],
          sellerId: chatData.sellerId || participants[1],
          users: participants,
          lastMessage: safeText,
          lastSenderId: safeSenderId,
          buyerUnreadCount: safeSenderId === (chatData.buyerId || participants[0]) ? 0 : ((chatData.buyerUnreadCount || 0) + 1),
          sellerUnreadCount: safeSenderId === (chatData.sellerId || participants[1]) ? 0 : ((chatData.sellerUnreadCount || 0) + 1),
          updatedAt: FieldValue.serverTimestamp(),
          lastMessageAt: FieldValue.serverTimestamp(),
        }, { merge: true });

        if (safeListingId) {
          transaction.set(chatRef, {
            listingId: safeListingId || parsedListingId,
          }, { merge: true });
        }
      }

      transaction.set(messageRef, {
        messageId: messageRef.id,
        senderId: safeSenderId,
        receiverId: safeReceiverId,
        text: safeText,
        body: safeText,
        clientMessageId: clientMessageId || '',
        seen: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    return {
      chatId: safeChatId,
      messageId: messageRef.id,
      senderId: safeSenderId,
      receiverId: safeReceiverId,
      text: safeText,
      body: safeText,
      clientMessageId: clientMessageId || '',
      seen: false,
      createdAt: new Date().toISOString(),
    };
  }

  async markSeen({ chatId, readerId }) {
    const safeChatId = requireString(chatId, 'chatId');
    const safeReaderId = requireString(readerId, 'readerId');
    const chat = await this.getChatForUser(safeChatId, safeReaderId);
    const messagesRef = this.getMessagesCollection(chat.chatId);
    const unreadSnapshot = await messagesRef
      .where('receiverId', '==', safeReaderId)
      .where('seen', '==', false)
      .get();

    if (unreadSnapshot.empty) {
      return { chatId: safeChatId, updatedCount: 0 };
    }

    const batch = this.db.batch();
    unreadSnapshot.docs.forEach((doc) => {
      batch.set(doc.ref, { seen: true, seenAt: FieldValue.serverTimestamp() }, { merge: true });
    });

    const chatData = chat || {};
    const updatedChat = {
      updatedAt: FieldValue.serverTimestamp(),
      buyerUnreadCount: safeReaderId === chatData.buyerId ? 0 : chatData.buyerUnreadCount || 0,
      sellerUnreadCount: safeReaderId === chatData.sellerId ? 0 : chatData.sellerUnreadCount || 0,
    };

    batch.set(this.getChatRef(chat.chatId), updatedChat, { merge: true });

    await batch.commit();

    return {
      chatId: safeChatId,
      updatedCount: unreadSnapshot.size,
    };
  }

}

function createChatService({ db }) {
  return new ChatService({ db });
}

function normalizeUsers(users) {
  if (!Array.isArray(users) || users.length !== 2) {
    throw new Error('A chat must contain exactly two users.');
  }

  return users.map((user) => requireString(user, 'user')).sort();
}

function clamp(value, min, max) {
  const parsed = Number(value);
  if (Number.isNaN(parsed)) {
    return min;
  }
  return Math.max(min, Math.min(max, parsed));
}

module.exports = {
  ChatService,
  createChatService,
};

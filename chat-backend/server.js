const http = require('http');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Server } = require('socket.io');

const { initializeFirebaseAdmin, getFirestore, verifyFirebaseIdToken } = require('./src/config/firebase');
const { createChatService } = require('./src/services/chatService');
const { createListingService } = require('./src/services/listingService');
const { buildChatId, parseChatId } = require('./src/utils/chatId');
const { createPresenceStore } = require('./src/services/presenceStore');
const { registerSocketHandlers } = require('./src/socket/registerSocketHandlers');

dotenv.config();

async function main() {
  initializeFirebaseAdmin();

  const app = express();
  const server = http.createServer(app);

  const io = new Server(server, {
    cors: {
      origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',').map((item) => item.trim()) : true,
      credentials: true,
    },
  });

  const db = getFirestore();
  const chatService = createChatService({ db });
  const listingService = createListingService({ db });
  const presenceStore = createPresenceStore();

  app.use(cors({ origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',').map((item) => item.trim()) : true, credentials: true }));
  app.use(express.json({ limit: '64kb' }));

  app.get('/', (req, res) => {
    res.json({ ok: true, service: 'scentswap-chat-backend', message: 'Chat backend is running' });
  });

  app.get('/health', (req, res) => {
    res.json({ ok: true, service: 'scentswap-chat-backend' });
  });

  app.use('/api', createHttpRouter({ chatService, listingService }));

  app.use((req, res) => {
    console.log('[Router] 404 - Route not found:', req.method, req.path);
    res.status(404).json({ error: 'not_found', message: 'Route not found' });
  });

  io.use(async (socket, next) => {
    try {
      console.log('[Socket.IO Auth] Connection attempt from:', socket.handshake.address);
      const token = extractSocketToken(socket);
      console.log('[Socket.IO Auth] Token extracted:', !!token);
      
      if (!token) {
        console.error('[Socket.IO Auth] No token provided');
        return next(new Error('Missing Firebase ID token.'));
      }

      const decodedToken = await verifyFirebaseIdToken(token);
      console.log('[Socket.IO Auth] Token verified, uid:', decodedToken.uid);
      
      socket.user = {
        uid: decodedToken.uid,
        email: decodedToken.email || null,
        name: decodedToken.name || null,
      };
      return next();
    } catch (error) {
      console.error('[Socket.IO Auth] Authentication failed:', error.message);
      return next(new Error('Invalid Firebase ID token.'));
    }
  });

  registerSocketHandlers(io, {
    chatService,
    listingService,
    presenceStore,
  });

  const port = Number(process.env.PORT || 5051);
  server.listen(port, () => {
    console.log(`Chat backend running on http://localhost:${port}`);
  });
}

function extractSocketToken(socket) {
  const authToken = socket.handshake.auth && socket.handshake.auth.token;
  if (authToken) {
    return String(authToken).replace(/^Bearer\s+/i, '').trim();
  }

  const headerToken = socket.handshake.headers && socket.handshake.headers.authorization;
  if (headerToken) {
    return String(headerToken).replace(/^Bearer\s+/i, '').trim();
  }

  const queryToken = socket.handshake.query && socket.handshake.query.token;
  return queryToken ? String(queryToken).trim() : '';
}

function createHttpRouter({ chatService, listingService }) {
  const router = express.Router();

  router.get('/me/chats', async (req, res) => {
    try {
      const user = await authenticateHttpRequest(req);
      const chats = await chatService.listChatsForUser(user.uid);
      res.json({ chats });
    } catch (error) {
      respondHttpError(res, error);
    }
  });

  router.get('/chats/:chatId', async (req, res) => {
    try {
      const user = await authenticateHttpRequest(req);
      const chat = await chatService.getChatForUser(req.params.chatId, user.uid);
      res.json({ chat });
    } catch (error) {
      respondHttpError(res, error);
    }
  });

  router.get('/chats/:chatId/messages', async (req, res) => {
    try {
      const user = await authenticateHttpRequest(req);
      const limit = clampNumber(req.query.limit, Number(process.env.CHAT_HISTORY_LIMIT || 50), 1, 100);
      const messages = await chatService.getMessagesForUser(req.params.chatId, user.uid, limit);
      res.json({ messages });
    } catch (error) {
      respondHttpError(res, error);
    }
  });

  router.get('/listings/:listingId/chat-id', async (req, res) => {
    try {
      console.log('[CHAT_CLICK] listingId:', req.params.listingId);
      const user = await authenticateHttpRequest(req);
      console.log('[AUTH] userId:', user.uid);
      const listing = await listingService.getListingForChat(req.params.listingId, user.uid);
      const chatId = buildChatId({
        listingId: listing.id,
        userA: listing.ownerId,
        userB: user.uid,
      });
      console.log('[CHAT_ID] generated:', chatId);
      res.json({
        chatId,
        listingId: listing.id,
        ownerId: listing.ownerId,
      });
    } catch (error) {
      console.error('[Chat API] Error:', error.message);
      respondHttpError(res, error);
    }
  });

  return router;
}

async function authenticateHttpRequest(req) {
  const header = req.header('authorization') || '';
  const token = header.replace(/^Bearer\s+/i, '').trim();
  console.log('[Auth] Authenticating HTTP request, token present:', !!token);
  if (!token) {
    console.error('[Auth] No token provided');
    const error = new Error('Missing Firebase ID token.');
    error.statusCode = 401;
    throw error;
  }

  try {
    const decodedToken = await verifyFirebaseIdToken(token);
    console.log('[Auth] Token verified, uid:', decodedToken.uid);
    return decodedToken;
  } catch (err) {
    console.error('[Auth] Token verification failed:', err.message);
    throw err;
  }
}

function respondHttpError(res, error) {
  const statusCode = Number(error.statusCode || error.httpStatusCode || 400);
  res.status(statusCode).json({
    error: error.code || 'error',
    message: error.message || 'Request failed.',
  });
}

function clampNumber(value, fallback, min, max) {
  const parsed = Number(value);
  if (Number.isNaN(parsed)) {
    return fallback;
  }
  return Math.max(min, Math.min(max, parsed));
}

main().catch((error) => {
  console.error('Fatal chat backend startup error:', error);
  process.exit(1);
});

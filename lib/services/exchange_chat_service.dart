import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;
import 'package:uuid/uuid.dart';

import '../models/exchange_chat_message.dart';
import '../models/exchange_chat_thread.dart';

class ExchangeChatService {
  ExchangeChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  socket_io_client.Socket? _socket;
  String? _socketToken;
  Completer<void>? _socketReady;
  Completer<socket_io_client.Socket>? _connectionLock;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String threadId) =>
      _firestore.collection('messages').doc(threadId).collection('items');

  String generateChatId({required String listingId, required String userA, required String userB}) {
    final firstUser = userA.replaceAll('/', '_');
    final secondUser = userB.replaceAll('/', '_');
    final participants = [firstUser, secondUser]..sort();
    return '$listingId::${participants[0]}::${participants[1]}';
  }

  Future<ExchangeChatThread> createOrLoadThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != buyerId) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'You must be signed in to start a chat.',
      );
    }

    final chatInfo = await _fetchChatInfo(listingId);
    final sellerFromServer = chatInfo['ownerId'] is String ? chatInfo['ownerId'] as String : sellerId;
    final chatId = generateChatId(listingId: listingId, userA: buyerId, userB: sellerFromServer);

    debugPrint('[CHAT_CLICK] sender: $buyerId receiver: $sellerFromServer');
    debugPrint('[CHAT_ID] generated: $chatId');

    await _joinChat(chatId, listingId: listingId);

    debugPrint('[Active chatId AFTER navigation]: $chatId');

    return ExchangeChatThread.fromJson(
      chatId,
      {
        'listingId': listingId,
        'buyerId': buyerId,
        'sellerId': sellerFromServer,
        'lastMessage': '',
        'lastSenderId': '',
        'buyerUnreadCount': 0,
        'sellerUnreadCount': 0,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'lastMessageAt': null,
      },
    );
  }

  Future<ExchangeChatThread?> loadThread(String threadId) async {
    final snapshot = await _threads.doc(threadId).get();
    if (!snapshot.exists) {
      return null;
    }
    return ExchangeChatThread.fromSnapshot(snapshot);
  }

  Future<void> markThreadAsRead({
    required ExchangeChatThread thread,
    required String viewerId,
  }) async {
    if (viewerId != thread.buyerId && viewerId != thread.sellerId) {
      return;
    }

    await _joinChat(thread.id);
    final socket = await _ensureSocket();
    socket.emit('mark_seen', {
      'chatId': thread.id,
    });
  }

  Stream<List<ExchangeChatThread>> streamThreadsForListing({
    required String listingId,
    required String sellerId,
  }) {
    return _threads.orderBy('updatedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
          .map(ExchangeChatThread.fromSnapshot)
          .where((thread) => thread.sellerId == sellerId)
          .toList(growable: false),
      );
  }

  Stream<List<ExchangeChatThread>> streamThreadsForUser(String userId) {
    return _threads.orderBy('updatedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
          .map(ExchangeChatThread.fromSnapshot)
          .where((thread) => thread.buyerId == userId || thread.sellerId == userId)
          .toList(growable: false),
      );
  }

  Stream<List<ExchangeChatMessage>> streamMessages(String threadId) {
    debugPrint("[EXCHANGE_CHAT_SERVICE] Starting message stream for thread: $threadId");
    return _messages(threadId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          debugPrint("[EXCHANGE_CHAT_SERVICE] Received ${snapshot.docs.length} messages for $threadId");
          return snapshot.docs
            .map(ExchangeChatMessage.fromSnapshot)
            .toList(growable: false);
        })
        .handleError((error) {
          debugPrint("[EXCHANGE_CHAT_SERVICE] Error in message stream: $error");
          throw error;
        });
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final thread = await loadThread(threadId);
    if (thread == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Chat thread was deleted or inaccessible.',
      );
    }

    if (senderId != thread.buyerId && senderId != thread.sellerId) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'You cannot send messages in this chat.',
      );
    }

    final socket = await _ensureSocket();
    final receiverId = senderId == thread.buyerId ? thread.sellerId : thread.buyerId;
    final clientMessageId = _uuid.v4();
    final completer = Completer<void>();

    print('[ExchangeChat] Sending message with clientMessageId: $clientMessageId');

    void messageListener(dynamic payload) {
      if (payload is! Map) {
        print('[ExchangeChat] Received non-map payload: $payload');
        return;
      }
      final receivedClientMessageId = payload['clientMessageId'];
      print('[ExchangeChat] Received message_received. Looking for clientMessageId: $clientMessageId, Got: $receivedClientMessageId');
      
      if (receivedClientMessageId == clientMessageId) {
        print('[ExchangeChat] MATCH! Completing send for $clientMessageId');
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }

    void errorListener(dynamic payload) {
      print('[ExchangeChat] Received api_error: $payload');
      if (payload is! Map) {
        return;
      }
      if (!completer.isCompleted) {
        completer.completeError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: payload['code']?.toString() ?? 'unknown',
            message:
                payload['message']?.toString() ?? 'Unable to send message.',
          ),
        );
      }
    }

    print('[ExchangeChat] Registering listeners for message delivery...');
    socket.on('message_received', messageListener);
    socket.on('api_error', errorListener);

    try {
      await _joinChat(threadId, socket: socket);
      print('[ExchangeChat] Emitting send_message to backend for $clientMessageId');
      socket.emit('send_message', {
        'chatId': threadId,
        'receiverId': receiverId,
        'text': trimmed,
        'clientMessageId': clientMessageId,
        'listingId': thread.listingId,
      });

      print('[ExchangeChat] Waiting for message_received acknowledgement...');
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[ExchangeChat] TIMEOUT: Message delivery failed for $clientMessageId after 15s');
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
            message: 'Message delivery timed out.',
          );
        },
      );
      print('[ExchangeChat] Message delivery confirmed');
    } catch (e) {
      print('[ExchangeChat] Error sending message: $e');
      if (e is FirebaseException) {
        rethrow;
      }
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unknown',
        message: 'Failed to send message: ${e.toString()}',
      );
    } finally {
      socket.off('message_received', messageListener);
      socket.off('api_error', errorListener);
    }
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _socketReady = null;
    _socketToken = null;
  }

  Future<void> _joinChat(String chatId, {socket_io_client.Socket? socket, String? listingId}) async {
    final s = socket ?? await _ensureSocket();
    final completer = Completer<void>();
    late void Function(dynamic) errorListener;

    void joinListener(dynamic payload) {
      if (payload is! Map) {
        return;
      }
      if (payload['chatId'] == chatId && !completer.isCompleted) {
        completer.complete();
      }
    }

    errorListener = (dynamic payload) {
      if (payload is! Map) {
        return;
      }
      if (!completer.isCompleted) {
        completer.completeError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: payload['code']?.toString() ?? 'unknown',
            message:
                payload['message']?.toString() ?? 'Unable to join chat.',
          ),
        );
      }
    };

    s.on('presence_update', joinListener);
    s.on('api_error', errorListener);

    try {
      s.emit('join_chat', {
        'chatId': chatId,
        if (listingId != null && listingId.isNotEmpty) 'listingId': listingId,
      });

      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
            message: 'Chat join timed out.',
          );
        },
      );
    } finally {
      s.off('presence_update', joinListener);
      s.off('api_error', errorListener);
    }
  }

  Future<Map<String, dynamic>> _fetchChatInfo(String listingId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'You must be signed in to open chat.',
      );
    }

    final uri = Uri.parse('$_backendBaseUrl/api/listings/$listingId/chat-id');
    print('[ExchangeChat] Fetching chat info for listing $listingId from $_backendBaseUrl');
    final token = await currentUser.getIdToken();
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[ExchangeChat] Chat info response: ${response.statusCode}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('[ExchangeChat] Error response body: ${response.body}');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unknown',
        message: _decodeErrorMessage(response.body) ?? 'Unable to initialize chat.',
      );
    }

    print('[ExchangeChat] Response body: ${response.body}');
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      print('[ExchangeChat] Chat info loaded: $decoded');
      return decoded;
    }

    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unknown',
      message: 'Invalid chat metadata response.',
    );
  }

  Future<socket_io_client.Socket> _ensureSocket() async {
    if (_connectionLock != null) {
      print('[ExchangeChat] Waiting for in-flight socket connection...');
      return _connectionLock!.future;
    }

    final completer = Completer<socket_io_client.Socket>();
    _connectionLock = completer;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unauthenticated',
          message: 'You must be signed in to use chat.',
        );
      }

      final token = await currentUser.getIdToken();
      if (_socket != null && _socketToken == token && _socket!.connected) {
        print('[ExchangeChat] Reusing existing socket connection');
        completer.complete(_socket!);
        return _socket!;
      }

      print('[ExchangeChat] Creating new socket connection to $_backendBaseUrl');
      _socket?.dispose();
      _socketReady = Completer<void>();
      _socketToken = token;

      final socket = socket_io_client.io(
        _backendBaseUrl,
        <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'upgrade': true,
          'autoConnect': false,
          'auth': {'token': token},
          'forceNew': true,
          'timeout': 10000,
        },
      );

      socket.onConnect((_) {
        print('[ExchangeChat] Socket connected successfully');
        if (!(_socketReady?.isCompleted ?? true)) {
          _socketReady?.complete();
        }
      });

      socket.onConnectError((error) {
        print('[ExchangeChat] Socket connection error: $error');
        if (!(_socketReady?.isCompleted ?? true)) {
          _socketReady?.completeError(
            FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'Unable to connect to chat service: $error',
            ),
          );
        }
      });

      socket.onDisconnect((_) {
        print('[ExchangeChat] Socket disconnected');
        if (_socketReady != null && !(_socketReady?.isCompleted ?? true)) {
          _socketReady?.completeError(
            FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'Chat connection was closed.',
            ),
          );
        }
      });

      socket.connect();
      _socket = socket;
      debugPrint("[ExchangeChat] Waiting for socket ready...");
      await _socketReady!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint("[ExchangeChat] Socket connection TIMEOUT after 10s");
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
            message: 'Chat connection timed out.',
          );
        },
      );
      debugPrint("[ExchangeChat] Socket is READY");
      
      completer.complete(socket);
      return socket;
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    } finally {
      _connectionLock = null;
    }
  }

  String get _backendBaseUrl =>
      dotenv.env['CHAT_BACKEND_URL'] ?? 'http://localhost:5051';

  String? _decodeErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // ignore malformed error bodies
    }
    return null;
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/exchange_chat_message.dart';
import '../models/exchange_chat_thread.dart';
import '../services/exchange_chat_service.dart';

class ExchangeChatProvider extends ChangeNotifier {
  ExchangeChatProvider({required ExchangeChatService service}) : _service = service;

  final ExchangeChatService _service;

  final List<ExchangeChatMessage> _messages = [];
  final List<ExchangeChatThread> _threads = [];
  ExchangeChatThread? _activeThread;
  StreamSubscription<List<ExchangeChatMessage>>? _messageSub;
  StreamSubscription<List<ExchangeChatThread>>? _threadSub;

  bool _isLoading = false;
  bool _isSending = false;
  String _errorMessage = '';

  List<ExchangeChatMessage> get messages => List.unmodifiable(_messages);
  List<ExchangeChatThread> get threads => List.unmodifiable(_threads);
  ExchangeChatThread? get activeThread => _activeThread;
  String? get activeChatId => _activeThread?.id;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage.isEmpty) {
      return;
    }
    _errorMessage = '';
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearActiveThread() {
    _messageSub?.cancel();
    _messageSub = null;
    _messages.clear();
    _activeThread = null;
    notifyListeners();
  }

  Future<void> ensureBuyerThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    debugPrint("[CHAT_PROVIDER] ensureBuyerThread: listingId=$listingId, buyerId=$buyerId, sellerId=$sellerId");
    debugPrint("[CHAT_PROVIDER] Active chatId BEFORE navigation: ${_activeThread?.id ?? 'none'}");
    await _openBuyerThread(
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
    );
  }

  Future<void> openExistingThread({
    required ExchangeChatThread thread,
    required String viewerId,
  }) async {
    debugPrint("[CHAT_PROVIDER] Opening existing thread: ${thread.id}");
    _activeThread = thread;
    await _service.markThreadAsRead(thread: thread, viewerId: viewerId);
    _subscribeToMessages(thread.id);
    notifyListeners();
  }

  Future<void> ensureSellerThreads({
    required String listingId,
    required String sellerId,
  }) async {
    debugPrint("[CHAT_PROVIDER] ensureSellerThreads: listingId=$listingId, sellerId=$sellerId");
    _startSellerThreadStream(sellerId: sellerId);
  }

  Future<void> _openBuyerThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _resetConversationState();
    notifyListeners();

    try {
      debugPrint("[CHAT_PROVIDER] Calling createOrLoadThread for listing: $listingId");
      final thread = await _service.createOrLoadThread(
        listingId: listingId,
        buyerId: buyerId,
        sellerId: sellerId,
      );
      debugPrint("[CHAT_PROVIDER] createOrLoadThread success: ${thread.id}");
      _activeThread = thread;
      debugPrint("[CHAT_PROVIDER] Active chatId AFTER navigation: ${thread.id}");
      _subscribeToMessages(thread.id);
    } catch (e) {
      debugPrint("[CHAT_PROVIDER] Error in _openBuyerThread: $e");
      _errorMessage = _formatError(e, 'Unable to load chat right now.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startSellerThreadStream({
    required String sellerId,
  }) {
    _isLoading = true;
    _errorMessage = '';
    _resetConversationState();
    notifyListeners();

    _threadSub?.cancel();
    _threadSub = _service
        .streamThreadsForUser(sellerId)
        .listen(
      (threads) {
        _threads
          ..clear()
          ..addAll(threads);
        if (_activeThread == null && _threads.isNotEmpty) {
          _activeThread = _threads.first;
          _subscribeToMessages(_activeThread!.id);
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = _formatError(e, 'Unable to load buyer threads.');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void selectThread(ExchangeChatThread thread) {
    if (_activeThread?.id == thread.id) {
      return;
    }
    _activeThread = thread;
    _subscribeToMessages(thread.id);
    notifyListeners();
  }

  void _subscribeToMessages(String threadId) {
    debugPrint("[CHAT_PROVIDER] Subscribing to messages for thread: $threadId");
    _messageSub?.cancel();
    _messages.clear();
    notifyListeners();
    _messageSub = _service.streamMessages(threadId).listen(
      (messages) {
        debugPrint("[CHAT_PROVIDER] Received ${messages.length} messages for $threadId");
        _messages
          ..clear()
          ..addAll(messages);
        notifyListeners();
      },
      onError: (e) {
        debugPrint("[CHAT_PROVIDER] CRITICAL: Error loading messages for $threadId: $e");
        _errorMessage = _formatError(e, 'Unable to load chat messages.');
        notifyListeners();
      },
    );
  }

  void _resetConversationState() {
    _messageSub?.cancel();
    _messageSub = null;
    _messages.clear();
    _activeThread = null;
  }

  Future<bool> sendMessage({
    required String senderId,
    required String body,
  }) async {
    final thread = _activeThread;
    if (thread == null) {
      return false;
    }
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    _isSending = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.sendMessage(
        threadId: thread.id,
        senderId: senderId,
        body: trimmed,
      );
      return true;
    } catch (e) {
      _errorMessage = _formatError(e, 'Unable to send message.');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  String _formatError(dynamic error, String fallback) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to access this chat.';
        case 'not-found':
          return 'Chat thread not found.';
        case 'failed-precondition':
          return 'Operation failed. Please try again.';
        default:
          return error.message ?? fallback;
      }
    }
    if (error is StateError) {
      return error.message;
    }
    return fallback;
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _threadSub?.cancel();
    super.dispose();
  }
}

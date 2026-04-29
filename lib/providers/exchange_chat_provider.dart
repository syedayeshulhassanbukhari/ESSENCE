import 'dart:async';

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
  bool _hasLoaded = false;
  String _errorMessage = '';

  List<ExchangeChatMessage> get messages => List.unmodifiable(_messages);
  List<ExchangeChatThread> get threads => List.unmodifiable(_threads);
  ExchangeChatThread? get activeThread => _activeThread;
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

  Future<void> ensureBuyerThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    await _openBuyerThread(
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
    );
  }

  Future<void> ensureSellerThreads({
    required String listingId,
    required String sellerId,
  }) async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    _hasLoaded = true;
    _startSellerThreadStream(listingId: listingId, sellerId: sellerId);
  }

  Future<void> _openBuyerThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final thread = await _service.createOrLoadThread(
        listingId: listingId,
        buyerId: buyerId,
        sellerId: sellerId,
      );
      _activeThread = thread;
      _subscribeToMessages(thread.id);
    } catch (_) {
      _errorMessage = 'Unable to load chat right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startSellerThreadStream({
    required String listingId,
    required String sellerId,
  }) {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _threadSub?.cancel();
    _threadSub = _service
        .streamThreadsForListing(listingId: listingId, sellerId: sellerId)
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
      onError: (_) {
        _errorMessage = 'Unable to load buyer threads.';
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
    _messageSub?.cancel();
    _messages.clear();
    notifyListeners();
    _messageSub = _service.streamMessages(threadId).listen(
      (messages) {
        _messages
          ..clear()
          ..addAll(messages);
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Unable to load chat messages.';
        notifyListeners();
      },
    );
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
    } catch (_) {
      _errorMessage = 'Unable to send message.';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _threadSub?.cancel();
    super.dispose();
  }
}

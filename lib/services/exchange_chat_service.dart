import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exchange_chat_message.dart';
import '../models/exchange_chat_thread.dart';

class ExchangeChatService {
  ExchangeChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _firestore.collection('exchange_threads');

  String buildThreadId({required String listingId, required String buyerId}) {
    final safeListing = listingId.replaceAll('/', '_');
    final safeBuyer = buyerId.replaceAll('/', '_');
    return '${safeListing}_$safeBuyer';
  }

  DocumentReference<Map<String, dynamic>> _threadRef({
    required String listingId,
    required String buyerId,
  }) {
    final threadId = buildThreadId(listingId: listingId, buyerId: buyerId);
    return _threads.doc(threadId);
  }

  Future<ExchangeChatThread> createOrLoadThread({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    final ref = _threadRef(listingId: listingId, buyerId: buyerId);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'listingId': listingId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageAt': null,
        'lastSenderId': '',
      });
    } else {
      await ref.set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    final fresh = await ref.get();
    return ExchangeChatThread.fromSnapshot(fresh);
  }

  Stream<List<ExchangeChatThread>> streamThreadsForListing({
    required String listingId,
    required String sellerId,
  }) {
    return _threads
        .where('listingId', isEqualTo: listingId)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(ExchangeChatThread.fromSnapshot)
            .toList(growable: false));
  }

  Stream<List<ExchangeChatMessage>> streamMessages(String threadId) {
    return _threads
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(ExchangeChatMessage.fromSnapshot)
            .toList(growable: false));
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
    final threadRef = _threads.doc(threadId);
    final messageRef = threadRef.collection('messages').doc();
    await _firestore.runTransaction((transaction) async {
      transaction.set(messageRef, {
        'senderId': senderId,
        'body': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(
        threadRef,
        {
          'lastMessage': trimmed,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastSenderId': senderId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}

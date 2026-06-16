import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeChatThread {
  const ExchangeChatThread({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.lastMessage,
    required this.lastSenderId,
    required this.buyerUnreadCount,
    required this.sellerUnreadCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessageAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String lastMessage;
  final String lastSenderId;
  final int buyerUnreadCount;
  final int sellerUnreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastMessageAt;

  int unreadCountForUser(String userId) {
    if (userId == buyerId) {
      return buyerUnreadCount;
    }
    if (userId == sellerId) {
      return sellerUnreadCount;
    }
    return 0;
  }

  factory ExchangeChatThread.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return ExchangeChatThread.fromJson(snapshot.id, snapshot.data() ?? const {});
  }

  factory ExchangeChatThread.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return ExchangeChatThread(
      id: id,
      listingId: json['listingId'] is String ? json['listingId'] as String : '',
      buyerId: json['buyerId'] is String ? json['buyerId'] as String : '',
      sellerId: json['sellerId'] is String ? json['sellerId'] as String : '',
      lastMessage: json['lastMessage'] is String ? json['lastMessage'] as String : '',
      lastSenderId:
          json['lastSenderId'] is String ? json['lastSenderId'] as String : '',
        buyerUnreadCount: json['buyerUnreadCount'] is int
          ? json['buyerUnreadCount'] as int
          : (json['buyerUnreadCount'] is num
            ? (json['buyerUnreadCount'] as num).toInt()
            : 0),
        sellerUnreadCount: json['sellerUnreadCount'] is int
          ? json['sellerUnreadCount'] as int
          : (json['sellerUnreadCount'] is num
            ? (json['sellerUnreadCount'] as num).toInt()
            : 0),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      lastMessageAt: _parseDate(json['lastMessageAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

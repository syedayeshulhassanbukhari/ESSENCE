import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeChatMessage {
  const ExchangeChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String body;
  final DateTime? createdAt;

  factory ExchangeChatMessage.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return ExchangeChatMessage(
      id: snapshot.id,
      senderId: data['senderId'] is String ? data['senderId'] as String : '',
      body: data['body'] is String ? data['body'] as String : '',
      createdAt: _parseDate(data['createdAt']),
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

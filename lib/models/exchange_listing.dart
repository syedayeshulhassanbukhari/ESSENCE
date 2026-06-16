import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeListing {
  const ExchangeListing({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final DateTime createdAt;

  String get priceLabel => 'PKR ${price.toStringAsFixed(2)}';

  factory ExchangeListing.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse('${json['price'] ?? ''}') ?? 0;
    final createdValue = json['created_at'] ?? json['createdAt'];
    final imageValue = json['image_url'] ?? json['imageUrl'];
    final ownerValue = json['owner_id'] ?? json['ownerId'];
    DateTime? parsedDate;
    if (createdValue is DateTime) {
      parsedDate = createdValue;
    } else if (createdValue is String) {
      parsedDate = DateTime.tryParse(createdValue);
    }

    return ExchangeListing(
      id: '${json['id'] ?? ''}',
      ownerId: ownerValue is String ? ownerValue : '',
      name: json['name'] is String ? json['name'] as String : '',
      description: json['description'] is String ? json['description'] as String : '',
      price: parsedPrice,
      imageUrl: imageValue is String ? imageValue : '',
      createdAt: parsedDate ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory ExchangeListing.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final rawPrice = data['price'];
    final parsedPrice = rawPrice is num ? rawPrice.toDouble() : 0.0;

    DateTime parsedDate = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    }

    return ExchangeListing(
      id: documentId,
      ownerId: data['ownerId'] is String ? data['ownerId'] as String : '',
      name: data['name'] is String ? data['name'] as String : '',
      description:
          data['description'] is String ? data['description'] as String : '',
      price: parsedPrice,
      imageUrl: data['imageUrl'] is String ? data['imageUrl'] as String : '',
      createdAt: parsedDate,
    );
  }
}

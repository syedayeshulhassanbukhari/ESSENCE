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
}

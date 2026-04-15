import 'package:flutter/material.dart';

import 'fragella_fragrance.dart';

class MarketplaceProduct {
  const MarketplaceProduct({
    required this.name,
    required this.category,
    required this.priceLabel,
    required this.priceValue,
    required this.bgColor,
    required this.isBestSeller,
    required this.imageUrl,
    this.fragrance,
  });

  final String name;
  final String category;
  final String priceLabel;
  final double priceValue;
  final Color bgColor;
  final bool isBestSeller;
  final String imageUrl;
  final FragellaFragrance? fragrance;
}

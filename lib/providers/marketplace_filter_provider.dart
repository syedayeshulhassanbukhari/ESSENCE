import 'package:flutter/foundation.dart';
import '../models/marketplace_product.dart';

class MarketplaceFilterProvider extends ChangeNotifier {
  static const List<String> categories = [
    'All Scents',
    'Floral',
    'Woody',
    'Oriental',
    'Fresh',
  ];

  static const List<String> intensities = [
    'Subtle',
    'Strong',
    'Vibrant',
    'Heavy',
  ];

  static const List<String> sortOptions = [
    'Newest First',
    'Price: Low-High',
    'Most Intense',
  ];

  String _selectedCategory = 'All Scents';
  String _selectedIntensity = 'Subtle';
  double _priceRange = 500;
  String _sortBy = 'Newest First';

  String get selectedCategory => _selectedCategory;
  String get selectedIntensity => _selectedIntensity;
  double get priceRange => _priceRange;
  String get sortBy => _sortBy;

  List<MarketplaceProduct> applyFilters(List<MarketplaceProduct> products) {
    var filtered = products;

    if (_selectedCategory != 'All Scents') {
      final categoryToken = _selectedCategory.toLowerCase();
      filtered = filtered
          .where(
            (product) => product.category.toLowerCase().contains(categoryToken),
          )
          .toList();
    }

    filtered = filtered
        .where((product) => product.priceValue <= _priceRange)
        .toList();

    if (_sortBy == 'Price: Low-High') {
      filtered.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    }

    return filtered;
  }

  void setSelectedCategory(String value) {
    if (_selectedCategory == value) {
      return;
    }
    _selectedCategory = value;
    notifyListeners();
  }

  void setSelectedIntensity(String value) {
    if (_selectedIntensity == value) {
      return;
    }
    _selectedIntensity = value;
    notifyListeners();
  }

  void setPriceRange(double value) {
    if (_priceRange == value) {
      return;
    }
    _priceRange = value;
    notifyListeners();
  }

  void setSortBy(String value) {
    if (_sortBy == value) {
      return;
    }
    _sortBy = value;
    notifyListeners();
  }
}

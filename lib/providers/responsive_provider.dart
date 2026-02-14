import 'package:flutter/foundation.dart';

enum ScreenSize {
  small,
  medium,
  large,
}

class ResponsiveProvider extends ChangeNotifier {
  ResponsiveProvider({
    this.smallMaxWidth = 599,
    this.mediumMaxWidth = 1023,
  });

  final double smallMaxWidth;
  final double mediumMaxWidth;

  ScreenSize _size = ScreenSize.large;
  double _width = 0;

  ScreenSize get size => _size;
  bool get isSmall => _size == ScreenSize.small;
  bool get isMedium => _size == ScreenSize.medium;
  bool get isLarge => _size == ScreenSize.large;

  void updateWidth(double width) {
    if (width == _width) {
      return;
    }

    _width = width;
    final ScreenSize nextSize;
    if (width <= smallMaxWidth) {
      nextSize = ScreenSize.small;
    } else if (width <= mediumMaxWidth) {
      nextSize = ScreenSize.medium;
    } else {
      nextSize = ScreenSize.large;
    }

    if (nextSize != _size) {
      _size = nextSize;
      notifyListeners();
    }
  }
}

import 'package:flutter/services.dart';

class PkrInputFormatter extends TextInputFormatter {
  PkrInputFormatter({
    this.maxIntegerDigits = 7,
    this.maxDecimalDigits = 2,
  });

  final int maxIntegerDigits;
  final int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return newValue;
    }

    final normalized = raw.replaceAll(',', '');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(normalized)) {
      return oldValue;
    }

    final dotCount = '.'.allMatches(normalized).length;
    if (dotCount > 1) {
      return oldValue;
    }

    final parts = normalized.split('.');
    final integerPart = parts.first;
    final decimalPart = parts.length > 1 ? parts[1] : '';

    if (integerPart.length > maxIntegerDigits) {
      return oldValue;
    }
    if (decimalPart.length > maxDecimalDigits) {
      return oldValue;
    }

    final formatted = normalized.startsWith('.') ? '0$normalized' : normalized;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

// ===== NEO BUTTON =====
class NeoButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final bool isFullWidth;
  final bool italic;
  final bool isLoading;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const NeoButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.isFullWidth = false,
    this.italic = false,
    this.isLoading = false,
    this.textStyle,
    this.padding,
    super.key,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final bgColor = widget.backgroundColor ?? colors.primaryYellow;
    final textColor = widget.textColor ?? colors.black;
    // Discover.html: neo-border is black; dark neo-border is primary yellow
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;

    final shadow =
      _isPressed ? <BoxShadow>[] : [AppTheme.neoShadow(colors, brightness)];
    final offset = _isPressed ? Offset(2, 2) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: AppTheme.borderWidth),
            boxShadow: shadow,
          ),
          child: Padding(
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: textColor),
                    )
                  : Text(
                      widget.label.toUpperCase(),
                      style: (widget.textStyle ??
                              Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(
                        color: textColor,
                        fontStyle:
                            widget.italic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== NEO CARD =====
class NeoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool shadow;
  final double shadowOffset;
  final EdgeInsets padding;

  const NeoCard({
    required this.child,
    this.backgroundColor,
    this.shadow = true,
    this.shadowOffset = AppTheme.shadowMedium,
    this.padding = const EdgeInsets.all(AppTheme.spacing4),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    // Discover.html: neo-border is black; dark neo-border is primary yellow
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor = backgroundColor ??
      (brightness == Brightness.light ? colors.white : colors.zinc900);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: shadow
          ? [AppTheme.neoShadow(colors, brightness, offset: shadowOffset)]
          : [],
      ),
      padding: padding,
      child: child,
    );
  }
}

// ===== NEO INPUT =====
class NeoInput extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const NeoInput({
    required this.label,
    required this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    super.key,
  });

  @override
  State<NeoInput> createState() => _NeoInputState();
}

class _NeoInputState extends State<NeoInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    // Discover.html: neo-border is black; dark neo-border is primary yellow
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor =
      brightness == Brightness.light ? colors.white : colors.zinc900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: AppTheme.spacing2),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: AppTheme.borderWidth),
            boxShadow: _focusNode.hasFocus
                ? [
                    AppTheme.neoShadow(
                      colors,
                      brightness,
                      offset: AppTheme.shadowSmall,
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacing4),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ===== NEO BADGE =====
class NeoBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const NeoBadge({
    required this.label,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    // Discover.html: neo-border is black; dark neo-border is primary yellow
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryYellow,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? colors.black,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ===== NEO ICON BUTTON =====
class NeoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  const NeoIconButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    super.key,
  });

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    // In dark mode, outlines use the primary yellow neo-border.
    final borderColor =
      brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor = widget.backgroundColor ?? colors.white;
    final iconColor = widget.iconColor ??
      (brightness == Brightness.light ? colors.black : colors.white);

    final shadow = _isPressed
        ? <BoxShadow>[]
        : [
            AppTheme.neoShadow(
              colors,
              brightness,
              offset: AppTheme.shadowSmall,
            )
          ];
    final offset = _isPressed ? const Offset(1, 1) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: AppTheme.borderWidth),
            boxShadow: shadow,
          ),
          child: Center(
            child: Icon(widget.icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }
}

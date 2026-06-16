import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class PerfumeImageCard extends StatefulWidget {
  const PerfumeImageCard({
    super.key,
    required this.imageUrl,
    required this.isDark,
    required this.colors,
    this.imageFallbacks = const [],
  });

  final String imageUrl;
  final bool isDark;
  final ThemeColors colors;
  final List<String> imageFallbacks;

  @override
  State<PerfumeImageCard> createState() => _PerfumeImageCardState();
}

class _PerfumeImageCardState extends State<PerfumeImageCard> {
  late List<String> _imageUrls;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeImageUrls();
  }

  void _initializeImageUrls() {
    _imageUrls = [];
    
    // Add primary image if available
    if (widget.imageUrl.isNotEmpty) {
      _imageUrls.add(widget.imageUrl);
    }
    
    // Add fallback images
    _imageUrls.addAll(
      widget.imageFallbacks.where((url) => url.isNotEmpty && url != widget.imageUrl),
    );
    
    print('[PerfumeImageCard] Initialized with ${_imageUrls.length} image URLs');
  }

  void _onImageError() {
    print('[PerfumeImageCard] Image failed to load at index $_currentImageIndex');
    if (mounted && _currentImageIndex < _imageUrls.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4.w),
      decoration: BoxDecoration(
        color: widget.colors.white,
        border: Border.all(
          color: widget.isDark ? widget.colors.white : widget.colors.black,
          width: AppTheme.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.colors.black,
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageUrls.isEmpty) {
      return _placeholder();
    }

    final currentUrl = _imageUrls[_currentImageIndex];
    
    print('[PerfumeImageCard] Loading image: $currentUrl (index $_currentImageIndex of ${_imageUrls.length})');

    return Image.network(
      currentUrl,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('[PerfumeImageCard] Error loading image: $error');
        if (_currentImageIndex < _imageUrls.length - 1) {
          Future.microtask(_onImageError);
          return const Center(child: CircularProgressIndicator());
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: widget.isDark ? widget.colors.zinc900 : widget.colors.white,
      child: Icon(
        Icons.local_florist,
        size: 64.sp,
        color: widget.colors.gray400,
      ),
    );
  }
}

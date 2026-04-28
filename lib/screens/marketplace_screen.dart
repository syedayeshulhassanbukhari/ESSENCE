import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/exchange_listing.dart';
import '../providers/exchange_listing_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';
import '../services/exchange_marketplace_service.dart';
import '../theme/app_theme.dart';
import '../utils/pkr_input_formatter.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key, this.header, this.footer});

  final Widget? header;
  final Widget? footer;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  bool _queuedInitialLoad = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ExchangeMarketplaceService()),
        ChangeNotifierProvider(
          create: (context) => ExchangeListingProvider(
            service: context.read<ExchangeMarketplaceService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final exchangeProvider = context.watch<ExchangeListingProvider>();
          if (!_queuedInitialLoad) {
            _queuedInitialLoad = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              context.read<ExchangeListingProvider>().ensureLoaded();
            });
          }

          final brightness = Theme.of(context).brightness;
          final colors = context.watch<ThemeProvider>().colors;
          final responsive = context.watch<ResponsiveProvider>();
          final isSmall = responsive.isSmall;
          final isMedium = responsive.isMedium;

          final bgColor = brightness == Brightness.light
              ? colors.backgroundLight
              : colors.backgroundDark;

          return Scaffold(
            backgroundColor: bgColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  widget.header ?? const AppHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing6.w,
                      vertical: AppTheme.spacing6.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopSection(context, exchangeProvider, isSmall),
                        SizedBox(height: AppTheme.spacing6.h),
                        _buildListingsGrid(
                          context,
                          exchangeProvider,
                          isSmall: isSmall,
                          isMedium: isMedium,
                        ),
                      ],
                    ),
                  ),
                  widget.footer ?? const AppFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    ExchangeListingProvider exchangeProvider,
    bool isSmall,
  ) {
    final colors = context.watch<ThemeProvider>().colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marketplace Exchange',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppTheme.spacing2.h),
        Text(
          'Only user-uploaded perfumes are shown here. Upload yours and start exchanging.',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Wrap(
          spacing: AppTheme.spacing4.w,
          runSpacing: AppTheme.spacing2.h,
          children: [
            NeoButton(
              label: 'Add Your Perfume',
              onPressed: () => _showAddPerfumeDialog(context, exchangeProvider),
              height: isSmall ? 52.h : 56.h,
              textStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            NeoButton(
              label: 'Refresh Listings',
              onPressed: exchangeProvider.refreshListings,
              backgroundColor: colors.white,
              textColor: colors.black,
              height: isSmall ? 52.h : 56.h,
              textStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListingsGrid(
    BuildContext context,
    ExchangeListingProvider exchangeProvider, {
    required bool isSmall,
    required bool isMedium,
  }) {
    final theme = Theme.of(context);

    if (exchangeProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (exchangeProvider.errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Text(
          exchangeProvider.errorMessage,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (exchangeProvider.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Text(
          'No uploaded perfumes yet.',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmall ? 1 : (isMedium ? 2 : 3),
        mainAxisSpacing: AppTheme.spacing6.h,
        crossAxisSpacing: AppTheme.spacing6.w,
        mainAxisExtent: isSmall ? 460.h : 500.h,
      ),
      itemCount: exchangeProvider.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _ExchangeListingCard(listing: exchangeProvider.items[index]);
      },
    );
  }

  Future<void> _showAddPerfumeDialog(
    BuildContext context,
    ExchangeListingProvider exchangeProvider,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final picker = ImagePicker();
    XFile? selectedImage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Upload Your Perfume'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Perfume Name'),
                    ),
                    SizedBox(height: AppTheme.spacing4.h),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        PkrInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Price (PKR)',
                        prefixText: 'PKR ',
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4.h),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(height: AppTheme.spacing4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedImage == null
                                ? 'No image selected'
                                : selectedImage!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing2.w),
                        TextButton(
                          onPressed: () async {
                            final file = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (file != null) {
                              setState(() {
                                selectedImage = file;
                              });
                            }
                          },
                          child: const Text('Choose Image'),
                        ),
                      ],
                    ),
                    if (exchangeProvider.errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: AppTheme.spacing2.h),
                        child: Text(
                          exchangeProvider.errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: exchangeProvider.isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: exchangeProvider.isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final description = descriptionController.text.trim();
                          final price = priceController.text.trim();

                          if (name.isEmpty || description.isEmpty || price.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Name, description, and valid PKR price are required.'),
                              ),
                            );
                            return;
                          }

                          if (selectedImage == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an image.'),
                              ),
                            );
                            return;
                          }

                          final success = await exchangeProvider.submitListing(
                            name: name,
                            description: description,
                            price: price,
                            image: selectedImage!,
                          );

                          if (success && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your perfume is listed for exchange.'),
                              ),
                            );
                          }
                        },
                  child: exchangeProvider.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExchangeListingCard extends StatelessWidget {
  const _ExchangeListingCard({required this.listing});

  final ExchangeListing listing;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isSmall = context.select<ResponsiveProvider, bool>(
      (provider) => provider.isSmall,
    );

    return NeoCard(
      backgroundColor: colors.white,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              width: double.infinity,
              child: Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colors.gray400,
                    alignment: Alignment.center,
                    child: Text(
                      'Image unavailable',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing2.w),
                      Text(
                        listing.priceLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing2.h),
                  Expanded(
                    child: Text(
                      listing.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2.h),
                  NeoButton(
                    label: 'Request Exchange',
                    onPressed: () {},
                    height: isSmall ? 44.h : 48.h,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

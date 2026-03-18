import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/fragella_fragrance.dart';
import '../models/resolved_notes.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/individual_perfume/widgets.dart';

class IndividualPerfumeDetails extends StatelessWidget {
  const IndividualPerfumeDetails({super.key, this.fragrance});

  final FragellaFragrance? fragrance;

  static const Color _primary = Color(0xFFFAC638);
  static const Color _bgLight = Color(0xFFF8F8F5);
  static const Color _bgDark = Color(0xFF231E0F);
  static const Color _accentCyan = Color(0xFF00F0FF);

  @override
  Widget build(BuildContext context) {
    final data = fragrance ??
        ModalRoute.of(context)?.settings.arguments as FragellaFragrance?;

    if (data == null) {
      return Scaffold(
        backgroundColor: _bgLight,
        body: Center(
          child: Text(
            'No perfume selected.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final colors = context.watch<ThemeProvider>().colors;
    final nameParts = _splitName(data.name);
    final notes = _resolveNotes(data);
    final description = _buildDescription(data);
    final rating = data.rating.isNotEmpty ? data.rating : '4.9';

    return Scaffold(
      backgroundColor: isDark ? _bgDark : _bgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: DetailsHeader(isDark: isDark, colors: colors),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing6.w,
              vertical: AppTheme.spacing6.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  PerfumeTopSection(
                    data: data,
                    nameParts: nameParts,
                    description: description,
                    isDark: isDark,
                    colors: colors,
                    primary: _primary,
                    accentCyan: _accentCyan,
                  ),
                  SizedBox(height: AppTheme.spacing8.h),
                  PerfumeNotesSection(
                    notes: notes,
                    isDark: isDark,
                    colors: colors,
                    primary: _primary,
                    accentCyan: _accentCyan,
                  ),
                  SizedBox(height: AppTheme.spacing8.h),
                  PerfumeReviewsSection(
                    rating: rating,
                    isDark: isDark,
                    colors: colors,
                    primary: _primary,
                  ),
                  SizedBox(height: AppTheme.spacing8.h),
                  PerfumeCtaSection(
                    isDark: isDark,
                    colors: colors,
                    accentCyan: _accentCyan,
                  ),
                  SizedBox(height: AppTheme.spacing8.h),
                  PerfumeFooterSection(
                    isDark: isDark,
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _splitName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length <= 1) {
      return [name];
    }
    if (parts.length == 2) {
      return parts;
    }
    return [parts.first, parts.sublist(1).join(' ')];
  }

  String _buildDescription(FragellaFragrance data) {
    final accords = data.mainAccords.take(3).join(', ');
    final country = data.country.isNotEmpty ? data.country : 'Global';
    final year = data.year.isNotEmpty ? data.year : 'Unknown year';
    return 'A sensory exploration of $accords. Crafted in $country, launched in $year.';
  }

  ResolvedNotes _resolveNotes(FragellaFragrance data) {
    if (data.notes.top.isNotEmpty ||
        data.notes.middle.isNotEmpty ||
        data.notes.base.isNotEmpty) {
      return ResolvedNotes(
        top: _noteNames(data.notes.top),
        middle: _noteNames(data.notes.middle),
        base: _noteNames(data.notes.base),
      );
    }

    final general = data.generalNotes.isNotEmpty
        ? data.generalNotes
        : const ['Bergamot', 'Amber', 'Cedar'];
    final third = (general.length / 3).ceil();
    return ResolvedNotes(
      top: general.take(third).toList(),
      middle: general.skip(third).take(third).toList(),
      base: general.skip(third * 2).toList(),
    );
  }

  List<String> _noteNames(List<FragellaNote> notes) {
    return notes.map((note) => note.name).where((name) => name.isNotEmpty).toList();
  }
}
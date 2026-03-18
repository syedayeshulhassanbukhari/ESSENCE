import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/resolved_notes.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class PerfumeNotesSection extends StatelessWidget {
  const PerfumeNotesSection({
    super.key,
    required this.notes,
    required this.isDark,
    required this.colors,
    required this.primary,
    required this.accentCyan,
  });

  final ResolvedNotes notes;
  final bool isDark;
  final ThemeColors colors;
  final Color primary;
  final Color accentCyan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Notes',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? colors.white : colors.black,
              width: AppTheme.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.black,
                offset: const Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 900;
              return isStacked
                  ? Column(
                      children: [
                        _NoteColumn(
                          title: 'Top Notes',
                          items: notes.top,
                          background: primary,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        _NoteColumn(
                          title: 'Heart Notes',
                          items: notes.middle,
                          background: accentCyan,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        _NoteColumn(
                          title: 'Base Notes',
                          items: notes.base,
                          background: isDark ? colors.zinc900 : colors.white,
                          borderSide: BorderSide(
                            color: isDark ? colors.white : colors.black,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _NoteColumn(
                            title: 'Top Notes',
                            items: notes.top,
                            background: primary,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _NoteColumn(
                            title: 'Heart Notes',
                            items: notes.middle,
                            background: accentCyan,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _NoteColumn(
                            title: 'Base Notes',
                            items: notes.base,
                            background: isDark ? colors.zinc900 : colors.white,
                            borderSide: BorderSide(
                              color: isDark ? colors.white : colors.black,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}

class _NoteColumn extends StatelessWidget {
  const _NoteColumn({
    required this.title,
    required this.items,
    required this.background,
    required this.borderSide,
  });

  final String title;
  final List<String> items;
  final Color background;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          right: BorderSide.none,
          bottom: borderSide,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationThickness: 4,
            ),
          ),
          SizedBox(height: AppTheme.spacing4.h),
          ...items.map(
            (note) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacing2.h),
              child: Text(
                '- $note',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

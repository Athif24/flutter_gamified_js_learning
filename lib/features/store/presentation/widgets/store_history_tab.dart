import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/themes/theme_provider.dart';
import '../../../../shared/widgets/error_body.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../data/models/store_model.dart';
import '../providers/store_provider.dart';
import '../widgets/store_skeleton.dart';
import '../widgets/store_empty_state.dart';

const _sourceBadgeColors = <String, Color>{
  'lesson': Color(0xFF22C55E),
  'quiz': Color(0xFF3B82F6),
  'badge': Color(0xFFF59E0B),
  'level_up': Color(0xFF8B5CF6),
  'event': Color(0xFFEC4899),
  'store': Color(0xFFEF4444),
  'admin': Color(0xFF6B7280),
  'mystery_box': Color(0xFFA855F7),
};

class StoreHistoryTab extends ConsumerStatefulWidget {
  const StoreHistoryTab({super.key});

  @override
  ConsumerState<StoreHistoryTab> createState() => _StoreHistoryTabState();
}

class _StoreHistoryTabState extends ConsumerState<StoreHistoryTab> {
  String _sourceFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(currentThemeProvider);
    final histAsync = ref.watch(jewelHistoryProvider);

    final allTx = histAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <JewelTransaction>[],
    );
    final filtered = _sourceFilter == 'all'
        ? allTx
        : allTx.where((tx) => tx.source == _sourceFilter).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        S.scale(context, 20),
        S.scale(context, 20),
        S.scale(context, 20),
        0,
      ),
      child: Column(
        children: [
          // Dropdown filter
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: S.scale(context, 16),
                color: t.mutedText,
              ),
              SizedBox(width: S.scale(context, 6)),
              Text(
                'Filter:',
                style: GoogleFonts.nunito(
                  color: t.mutedText,
                  fontWeight: FontWeight.w600,
                  fontSize: S.scale(context, 13),
                ),
              ),
              SizedBox(width: S.scale(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: S.scale(context, 12)),
                decoration: BoxDecoration(
                  color: t.bgSurface,
                  borderRadius: BorderRadius.circular(S.scale(context, 12)),
                  border: Border.all(
                    color: t.textPrimary,
                    width: S.scale(context, 1.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sourceFilter,
                    isDense: true,
                    dropdownColor: t.bgSurface,
                    style: GoogleFonts.nunito(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: S.scale(context, 13),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua Source'),
                      ),
                      ...jewelSourceLabels.entries.map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sourceFilter = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: S.scale(context, 16)),

          // Table
          Expanded(
            child: histAsync.when(
              loading: () => StoreSkeleton(t: t, tabId: 2),
              error: (_, __) => ErrorBody(t: t, title: 'Belum ada riwayat'),
              data: (list) {
                if (list.isEmpty) {
                  return StoreEmptyState(
                    t: t,
                    emoji: '📜',
                    title: 'Belum ada riwayat transaksi',
                    subtitle: 'Transaksi jewels kamu akan muncul di sini',
                  );
                }
                if (filtered.isEmpty) {
                  return StoreEmptyState(
                    t: t,
                    emoji: '🔍',
                    title: 'Tidak ada transaksi',
                    subtitle: '',
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.bgSurface,
                        borderRadius: BorderRadius.circular(
                          S.scale(context, 16),
                        ),
                        border: Border.all(
                          color: t.textPrimary,
                          width: S.scale(context, 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.textPrimary,
                            offset: Offset(
                              S.scale(context, 3),
                              S.scale(context, 3),
                            ),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(t.bgSurface2),
                        columnSpacing: S.scale(context, 24),
                        dataRowMinHeight: S.scale(context, 44),
                        dataRowMaxHeight: S.scale(context, 56),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Tanggal',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: S.scale(context, 12),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Source',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: S.scale(context, 12),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Amount',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: S.scale(context, 12),
                              ),
                            ),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(
                              'Balance After',
                              style: GoogleFonts.nunito(
                                color: t.mutedText,
                                fontWeight: FontWeight.w700,
                                fontSize: S.scale(context, 12),
                              ),
                            ),
                            numeric: true,
                          ),
                        ],
                        rows: filtered.map((tx) {
                          final isEarn = tx.amount >= 0;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  formatDate(tx.createdAt),
                                  style: GoogleFonts.nunito(
                                    color: t.textPrimary,
                                    fontSize: S.scale(context, 12),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: S.scale(context, 6),
                                    vertical: S.scale(context, 2),
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (_sourceBadgeColors[tx.source] ??
                                                t.mutedText)
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                      S.scale(context, 4),
                                    ),
                                  ),
                                  child: Text(
                                    jewelSourceLabels[tx.source] ?? tx.source,
                                    style: GoogleFonts.nunito(
                                      color:
                                          _sourceBadgeColors[tx.source] ??
                                          t.mutedText,
                                      fontSize: S.scale(context, 11),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${isEarn ? '+' : ''}${formatNumber(tx.amount)}',
                                  style: GoogleFonts.nunito(
                                    color: isEarn ? t.success : t.error,
                                    fontWeight: FontWeight.w900,
                                    fontSize: S.scale(context, 13),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.diamond,
                                      size: S.scale(context, 14),
                                      color: t.info,
                                    ),
                                    SizedBox(width: S.scale(context, 4)),
                                    Text(
                                      formatNumber(tx.balanceAfter ?? 0),
                                      style: GoogleFonts.nunito(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: S.scale(context, 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
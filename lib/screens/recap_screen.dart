import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/budget_models.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({
    super.key,
    required this.monthLabel,
    required this.year,
    required this.rows,
    required this.totalExpenses,
    required this.onDeleteEntry,
  });

  final String monthLabel;
  final int year;
  final List<ExpenseRowData> rows;
  final double totalExpenses;
  final void Function(ExpenseRowData row) onDeleteEntry;

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  final Set<String> _expandedCategories = {};
  final Set<String> _expandedSubCategories = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  String _localizedMonthLabel(String month) {
    switch (month) {
      case 'Janvier':
        return l10n.monthJanuary;
      case 'Février':
        return l10n.monthFebruary;
      case 'Mars':
        return l10n.monthMarch;
      case 'Avril':
        return l10n.monthApril;
      case 'Mai':
        return l10n.monthMay;
      case 'Juin':
        return l10n.monthJune;
      case 'Juillet':
        return l10n.monthJuly;
      case 'Août':
        return l10n.monthAugust;
      case 'Septembre':
        return l10n.monthSeptember;
      case 'Octobre':
        return l10n.monthOctober;
      case 'Novembre':
        return l10n.monthNovember;
      case 'Décembre':
        return l10n.monthDecember;
      default:
        return month;
    }
  }

  Map<String, Map<String, List<ExpenseRowData>>> _groupedRows(
    List<ExpenseRowData> rows,
  ) {
    final sortedRows = [...rows]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, Map<String, List<ExpenseRowData>>> grouped = {};

    for (final row in sortedRows) {
      final categoryMap = grouped.putIfAbsent(row.categoryName, () => {});
      final subCategoryList =
          categoryMap.putIfAbsent(row.subCategoryName, () => []);
      subCategoryList.add(row);
    }

    return grouped;
  }

  double _subCategoryTotal(List<ExpenseRowData> rows) {
    return rows.fold<double>(0, (sum, row) => sum + row.amount);
  }

  double _categoryTotal(Map<String, List<ExpenseRowData>> subGroups) {
    return subGroups.values.fold<double>(
      0,
      (sum, rows) => sum + _subCategoryTotal(rows),
    );
  }

  int _categoryOperationCount(Map<String, List<ExpenseRowData>> subGroups) {
    return subGroups.values.fold<int>(
      0,
      (sum, rows) => sum + rows.length,
    );
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      if (_expandedCategories.contains(categoryName)) {
        _expandedCategories.remove(categoryName);
      } else {
        _expandedCategories.add(categoryName);
      }
    });
  }

  void _toggleSubCategory(String categoryName, String subCategoryName) {
    final key = '$categoryName|||$subCategoryName';

    setState(() {
      if (_expandedSubCategories.contains(key)) {
        _expandedSubCategories.remove(key);
      } else {
        _expandedSubCategories.add(key);
      }
    });
  }

  bool _isCategoryExpanded(String categoryName) {
    return _expandedCategories.contains(categoryName);
  }

  bool _isSubCategoryExpanded(String categoryName, String subCategoryName) {
    final key = '$categoryName|||$subCategoryName';
    return _expandedSubCategories.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedRows(widget.rows);
    final categoryEntries = grouped.entries.toList()
      ..sort((a, b) {
        final totalA = _categoryTotal(a.value);
        final totalB = _categoryTotal(b.value);
        return totalB.compareTo(totalA);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.recapDetailOperationsTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334F46E5),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recapTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_localizedMonthLabel(widget.monthLabel)} ${widget.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _headerMetric(
                          title: l10n.recapOperations,
                          value: widget.rows.length.toString(),
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFFA78BFA),
                        ),
                        _headerMetric(
                          title: l10n.recapTotalExpenses,
                          value: _formatAmount(widget.totalExpenses),
                          icon: Icons.payments_rounded,
                          color: const Color(0xFFFB7185),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: categoryEntries.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        _EmptyDetailCard(
                          title: l10n.recapEmptyTitle,
                          message: l10n.recapEmptyMessage,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: categoryEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final categoryEntry = categoryEntries[index];
                        final categoryName = categoryEntry.key;
                        final subGroups = categoryEntry.value;
                        final categoryExpanded =
                            _isCategoryExpanded(categoryName);
                        final categoryTotal = _categoryTotal(subGroups);
                        final categoryCount =
                            _categoryOperationCount(subGroups);

                        final subEntries = subGroups.entries.toList()
                          ..sort((a, b) {
                            final totalA = _subCategoryTotal(a.value);
                            final totalB = _subCategoryTotal(b.value);
                            return totalB.compareTo(totalA);
                          });

                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFFAFBFF)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE3E8F2)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x100F172A),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => _toggleCategory(categoryName),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.folder_open_rounded,
                                          color: Color(0xFF4338CA),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              categoryName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                _tag(
                                                  l10n.recapOperationsCount(
                                                    categoryCount,
                                                  ),
                                                  const Color(0xFFF3F4F6),
                                                  const Color(0xFF374151),
                                                ),
                                                _tag(
                                                  _formatAmount(categoryTotal),
                                                  const Color(0xFFFFF1F2),
                                                  const Color(0xFFBE123C),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        categoryExpanded
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        color: const Color(0xFF667085),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (categoryExpanded)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Column(
                                    children: subEntries.map((subEntry) {
                                      final subCategoryName = subEntry.key;
                                      final rows = subEntry.value;
                                      final subExpanded =
                                          _isSubCategoryExpanded(
                                        categoryName,
                                        subCategoryName,
                                      );
                                      final subTotal = _subCategoryTotal(rows);

                                      return Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () => _toggleSubCategory(
                                                categoryName,
                                                subCategoryName,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFFFF1F2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                      ),
                                                      child: const Icon(
                                                        Icons.label_rounded,
                                                        color:
                                                            Color(0xFFBE123C),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            subCategoryName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Wrap(
                                                            spacing: 8,
                                                            runSpacing: 8,
                                                            children: [
                                                              _tag(
                                                                l10n.recapOperationsCount(
                                                                  rows.length,
                                                                ),
                                                                const Color(
                                                                  0xFFF3F4F6,
                                                                ),
                                                                const Color(
                                                                  0xFF374151,
                                                                ),
                                                              ),
                                                              _tag(
                                                                _formatAmount(
                                                                  subTotal,
                                                                ),
                                                                const Color(
                                                                  0xFFEEF2FF,
                                                                ),
                                                                const Color(
                                                                  0xFF4338CA,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      subExpanded
                                                          ? Icons
                                                              .expand_less_rounded
                                                          : Icons
                                                              .expand_more_rounded,
                                                      color: const Color(
                                                        0xFF667085,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (subExpanded)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  10,
                                                  0,
                                                  10,
                                                  10,
                                                ),
                                                child: Column(
                                                  children: rows.map((row) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        top: 10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFE5E7EB,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(14),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 44,
                                                              height: 44,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                  0xFFEF4444,
                                                                ).withValues(
                                                                  alpha: 0.10,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  14,
                                                                ),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .receipt_long_rounded,
                                                                color: Color(
                                                                  0xFFEF4444,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    _formatDate(
                                                                      row.createdAt,
                                                                    ),
                                                                    style:
                                                                        const TextStyle(
                                                                      color:
                                                                          Color(
                                                                        0xFF667085,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          const Color(
                                                                        0xFFEF4444,
                                                                      ).withValues(
                                                                        alpha:
                                                                            0.10,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        999,
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      _formatAmount(
                                                                        row.amount,
                                                                      ),
                                                                      style:
                                                                          const TextStyle(
                                                                        color:
                                                                            Color(
                                                                          0xFFEF4444,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            IconButton(
                                                              onPressed: () =>
                                                                  widget
                                                                      .onDeleteEntry(
                                                                row,
                                                              ),
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline_rounded,
                                                              ),
                                                              color: Colors
                                                                  .redAccent,
                                                              tooltip: l10n
                                                                  .recapDelete,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyDetailCard extends StatelessWidget {
  const _EmptyDetailCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E9F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Icon(
            Icons.inbox_outlined,
            size: 44,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

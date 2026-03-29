import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/budget_models.dart';
import '../monetization/budget_familial_monetization_scope.dart';
import '../monetization/paywall_screen.dart';
import '../services/budget_export_service.dart';

enum AnalysisPeriodMode { month, year }

enum AnalysisView { summary, categories, subCategories, evolution, tips }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.appBudget,
    required this.initialMonth,
    required this.initialYear,
    required this.months,
    required this.years,
  });

  final AppBudgetData appBudget;
  final String initialMonth;
  final int initialYear;
  final List<String> months;
  final List<int> years;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late String _selectedMonth;
  late int _selectedYear;
  AnalysisPeriodMode _periodMode = AnalysisPeriodMode.month;
  AnalysisView _selectedView = AnalysisView.summary;
  bool _isExporting = false;

  _AnalysisI18n get txt => _AnalysisI18n.of(context);

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  String get _currentPeriodKey => '$_selectedYear-$_selectedMonth';

  Future<bool> _ensurePremiumAccess({
    required String blockedMessage,
  }) async {
    final monetization = BudgetFamilialMonetizationScope.of(context);

    if (monetization.isPremium) {
      return true;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(controller: monetization),
      ),
    );

    if (!mounted) return false;

    if (!monetization.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockedMessage),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _handleViewSelection(AnalysisView view) async {
    if (view == AnalysisView.tips) {
      final allowed = await _ensurePremiumAccess(
        blockedMessage: txt.tipsTabPremiumOnly,
      );

      if (!allowed || !mounted) return;
    }

    setState(() {
      _selectedView = view;
    });
  }

  Future<void> _openPremiumFromLockedBlock({
    required String blockedMessage,
  }) async {
    await _ensurePremiumAccess(blockedMessage: blockedMessage);
  }

  Future<void> _exportCurrentPeriodToExcel() async {
    final allowed = await _ensurePremiumAccess(
      blockedMessage: txt.excelExportPremiumOnly,
    );

    if (!allowed || !mounted) return;

    if (_periodMode != AnalysisPeriodMode.month) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txt.excelExportMonthOnly),
        ),
      );
      return;
    }

    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final file = await BudgetExportService().exportPeriodToExcel(
        appBudget: widget.appBudget,
        periodKey: _currentPeriodKey,
      );

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: txt.excelExportShareText(_currentPeriodKey),
        subject: txt.excelExportShareSubject(_currentPeriodKey),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            txt.excelFileReady(file.path.split('/').last),
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txt.excelExportError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  double _incomeForMonth(String month, int year) {
    return widget.appBudget.incomeTotalForPeriod('$year-$month');
  }

  double _expensesForMonth(String month, int year) {
    return widget.appBudget.expenseTotalForPeriod('$year-$month');
  }

  double _savingsForMonth(String month, int year) {
    return widget.appBudget.savingTotalForPeriod('$year-$month');
  }

  double _balanceForMonth(String month, int year) {
    return widget.appBudget.balanceForPeriod('$year-$month');
  }

  int _operationCountForMonth(String month, int year) {
    return widget.appBudget.getExpenseRowsForPeriod('$year-$month').length;
  }

  double _incomeForYear(int year) {
    return widget.months.fold<double>(
      0,
      (sum, month) => sum + _incomeForMonth(month, year),
    );
  }

  double _expensesForYear(int year) {
    return widget.months.fold<double>(
      0,
      (sum, month) => sum + _expensesForMonth(month, year),
    );
  }

  double _savingsForYear(int year) {
    return widget.months.fold<double>(
      0,
      (sum, month) => sum + _savingsForMonth(month, year),
    );
  }

  double _balanceForYear(int year) {
    return widget.months.fold<double>(
      0,
      (sum, month) => sum + _balanceForMonth(month, year),
    );
  }

  int _operationCountForYear(int year) {
    return widget.months.fold<int>(
      0,
      (sum, month) => sum + _operationCountForMonth(month, year),
    );
  }

  double get _currentIncome {
    return _periodMode == AnalysisPeriodMode.month
        ? _incomeForMonth(_selectedMonth, _selectedYear)
        : _incomeForYear(_selectedYear);
  }

  double get _currentExpenses {
    return _periodMode == AnalysisPeriodMode.month
        ? _expensesForMonth(_selectedMonth, _selectedYear)
        : _expensesForYear(_selectedYear);
  }

  double get _currentSavings {
    return _periodMode == AnalysisPeriodMode.month
        ? _savingsForMonth(_selectedMonth, _selectedYear)
        : _savingsForYear(_selectedYear);
  }

  double get _currentBalance {
    return _periodMode == AnalysisPeriodMode.month
        ? _balanceForMonth(_selectedMonth, _selectedYear)
        : _balanceForYear(_selectedYear);
  }

  int get _currentOperationCount {
    return _periodMode == AnalysisPeriodMode.month
        ? _operationCountForMonth(_selectedMonth, _selectedYear)
        : _operationCountForYear(_selectedYear);
  }

  double get _averageExpensePerOperation {
    if (_currentOperationCount == 0) return 0;
    return _currentExpenses / _currentOperationCount;
  }

  Map<String, double> _categoryTotalsForCurrentScope() {
    final Map<String, double> totals = {};

    for (final category in widget.appBudget.expenseTemplate.categories) {
      double value = 0;

      if (_periodMode == AnalysisPeriodMode.month) {
        value = widget.appBudget.expenseCategoryTotalForPeriod(
          _currentPeriodKey,
          category,
        );
      } else {
        for (final month in widget.months) {
          value += widget.appBudget.expenseCategoryTotalForPeriod(
            '$_selectedYear-$month',
            category,
          );
        }
      }

      if (value > 0) {
        totals[category.name] = value;
      }
    }

    return totals;
  }

  Map<String, double> _subCategoryTotalsForCurrentScope() {
    final Map<String, double> totals = {};

    for (final category in widget.appBudget.expenseTemplate.categories) {
      for (final subCategory in category.subCategories) {
        double value = 0;

        if (_periodMode == AnalysisPeriodMode.month) {
          value = widget.appBudget.expenseSubCategoryTotalForPeriod(
            _currentPeriodKey,
            subCategory.id,
          );
        } else {
          for (final month in widget.months) {
            value += widget.appBudget.expenseSubCategoryTotalForPeriod(
              '$_selectedYear-$month',
              subCategory.id,
            );
          }
        }

        if (value > 0) {
          totals['${category.name} > ${subCategory.name}'] = value;
        }
      }
    }

    return totals;
  }

  List<_MonthlyStat> _monthlyEvolutionForSelectedYear() {
    return widget.months.map((month) {
      return _MonthlyStat(
        label: txt.monthShort(month),
        income: _incomeForMonth(month, _selectedYear),
        expenses: _expensesForMonth(month, _selectedYear),
        savings: _savingsForMonth(month, _selectedYear),
        balance: _balanceForMonth(month, _selectedYear),
      );
    }).toList();
  }

  PeriodComparisonData? _expenseComparisonForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return null;
    return widget.appBudget.expenseComparisonForPeriod(_currentPeriodKey);
  }

  PeriodComparisonData? _incomeComparisonForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return null;
    return widget.appBudget.incomeComparisonForPeriod(_currentPeriodKey);
  }

  PeriodComparisonData? _savingComparisonForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return null;
    return widget.appBudget.savingComparisonForPeriod(_currentPeriodKey);
  }

  PeriodComparisonData? _balanceComparisonForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return null;
    return widget.appBudget.balanceComparisonForPeriod(_currentPeriodKey);
  }

  List<BudgetAlertData> _alertsForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return [];

    return widget.appBudget.generateAlertsForPeriod(
      _currentPeriodKey,
      highExpenseAmountThreshold: 1000,
      strongIncreasePercentThreshold: 30,
      lowBalanceThreshold: 0,
    );
  }

  List<ExpenseSubCategoryInsight> _topExpenseInsightsForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return [];

    return widget.appBudget.highestExpenseSubCategoriesForPeriod(
      _currentPeriodKey,
      limit: 5,
      excludeZeroAmounts: true,
    );
  }

  List<ExpenseSubCategoryInsight> _topIncreaseInsightsForCurrentScope() {
    if (_periodMode != AnalysisPeriodMode.month) return [];

    return widget.appBudget.mostIncreasedSubCategoriesForPeriod(
      _currentPeriodKey,
      limit: 5,
      minCurrentAmount: 1,
    );
  }

  List<_AdviceItem> _buildAdviceItems({
    required Map<String, double> categoryTotals,
    required Map<String, double> subCategoryTotals,
    required List<_MonthlyStat> monthlyStats,
    required List<BudgetAlertData> alerts,
    required List<ExpenseSubCategoryInsight> topExpenseInsights,
    required List<ExpenseSubCategoryInsight> topIncreaseInsights,
  }) {
    final List<_AdviceItem> items = [];

    final totalIncome = _currentIncome;
    final totalExpenses = _currentExpenses;
    final totalSavings = _currentSavings;
    final balance = _currentBalance;
    final operationCount = _currentOperationCount;

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedSubCategories = subCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (totalExpenses == 0) {
      items.add(
        _AdviceItem(
          title: txt.noExpenseRecordedTitle,
          message: txt.noExpenseRecordedMessage,
          color: Colors.blueGrey,
          icon: Icons.info_outline,
        ),
      );
      return items;
    }

    if (_periodMode == AnalysisPeriodMode.month && alerts.isNotEmpty) {
      final criticalCount =
          alerts.where((a) => a.level == BudgetAlertLevel.critical).length;
      final warningCount =
          alerts.where((a) => a.level == BudgetAlertLevel.warning).length;

      if (criticalCount > 0) {
        items.add(
          _AdviceItem(
            title: txt.criticalAlertDetectedTitle,
            message: txt.criticalAlertDetectedMessage(
              criticalCount,
              warningCount,
            ),
            color: Colors.red,
            icon: Icons.error_outline,
          ),
        );
      } else {
        items.add(
          _AdviceItem(
            title: txt.watchPointsDetectedTitle,
            message: txt.watchPointsDetectedMessage(warningCount),
            color: Colors.orange,
            icon: Icons.notification_important_outlined,
          ),
        );
      }
    }

    if (balance < 0) {
      items.add(
        _AdviceItem(
          title: txt.expensesHigherThanAvailableTitle,
          message: txt.expensesHigherThanAvailableMessage(
            _scopeLabel().toLowerCase(),
          ),
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        ),
      );
    } else {
      items.add(
        _AdviceItem(
          title: txt.positiveBalanceTitle,
          message: txt.positiveBalanceMessage(_scopeLabel().toLowerCase()),
          color: Colors.teal,
          icon: Icons.check_circle_outline,
        ),
      );
    }

    if (sortedCategories.isNotEmpty) {
      final biggestCategory = sortedCategories.first;
      final ratio =
          totalExpenses == 0 ? 0.0 : (biggestCategory.value / totalExpenses);

      items.add(
        _AdviceItem(
          title: txt.mainCategoryTitle,
          message: txt.mainCategoryMessage(
            biggestCategory.key,
            (ratio * 100).toStringAsFixed(1),
            _formatCurrency(biggestCategory.value),
          ),
          color: Colors.deepOrange,
          icon: Icons.pie_chart_outline,
        ),
      );
    }

    if (sortedSubCategories.isNotEmpty) {
      final biggestSubCategory = sortedSubCategories.first;
      final ratio =
          totalExpenses == 0 ? 0.0 : (biggestSubCategory.value / totalExpenses);

      items.add(
        _AdviceItem(
          title: txt.subCategoryToWatchTitle,
          message: txt.subCategoryToWatchMessage(
            biggestSubCategory.key,
            _formatCurrency(biggestSubCategory.value),
            (ratio * 100).toStringAsFixed(1),
          ),
          color: Colors.indigo,
          icon: Icons.bar_chart_rounded,
        ),
      );
    }

    if (_periodMode == AnalysisPeriodMode.month &&
        topIncreaseInsights.isNotEmpty) {
      final topIncrease = topIncreaseInsights.first;
      if (topIncrease.difference > 0) {
        items.add(
          _AdviceItem(
            title: txt.biggestIncreaseOfMonthTitle,
            message: txt.biggestIncreaseOfMonthMessage(
              topIncrease.subCategoryName,
              _formatCurrency(topIncrease.difference),
              topIncrease.previousAmount > 0
                  ? ' (${topIncrease.percentChange.toStringAsFixed(1)} %)'
                  : '',
            ),
            color: Colors.redAccent,
            icon: Icons.trending_up_rounded,
          ),
        );
      }
    }

    if (_periodMode == AnalysisPeriodMode.month &&
        topExpenseInsights.isNotEmpty) {
      final topExpense = topExpenseInsights.first;
      items.add(
        _AdviceItem(
          title: txt.heaviestItemOfMonthTitle,
          message: txt.heaviestItemOfMonthMessage(
            topExpense.subCategoryName,
            _formatCurrency(topExpense.currentAmount),
            topExpense.entryCount,
          ),
          color: Colors.brown,
          icon: Icons.account_balance_wallet_outlined,
        ),
      );
    }

    if (operationCount >= 12 && _averageExpensePerOperation < 50) {
      items.add(
        _AdviceItem(
          title: txt.manySmallOperationsTitle,
          message: txt.manySmallOperationsMessage(
            operationCount,
            _formatCurrency(_averageExpensePerOperation),
          ),
          color: Colors.purple,
          icon: Icons.shopping_cart_outlined,
        ),
      );
    }

    if (totalSavings == 0 && totalIncome > 0) {
      items.add(
        _AdviceItem(
          title: txt.noSavingsRecordedTitle,
          message: txt.noSavingsRecordedMessage,
          color: Colors.blue,
          icon: Icons.savings_outlined,
        ),
      );
    }

    if (_periodMode == AnalysisPeriodMode.year) {
      final expenseMonths = monthlyStats.where((e) => e.expenses > 0).toList();

      if (expenseMonths.isNotEmpty) {
        final averageMonthlyExpenses = expenseMonths.fold<double>(
              0.0,
              (sum, item) => sum + item.expenses,
            ) /
            expenseMonths.length;

        final peakMonth = expenseMonths.reduce(
          (a, b) => a.expenses >= b.expenses ? a : b,
        );

        if (peakMonth.expenses > averageMonthlyExpenses * 1.25) {
          items.add(
            _AdviceItem(
              title: txt.monthHigherThanAverageTitle,
              message: txt.monthHigherThanAverageMessage(peakMonth.label),
              color: Colors.redAccent,
              icon: Icons.insights_outlined,
            ),
          );
        }
      }
    }

    if (sortedCategories.length >= 2) {
      final top2 = sortedCategories.take(2).toList();
      final combined = top2.fold<double>(0.0, (sum, item) => sum + item.value);
      final ratio = totalExpenses == 0 ? 0.0 : (combined / totalExpenses);

      if (ratio >= 0.60) {
        items.add(
          _AdviceItem(
            title: txt.twoItemsDominateBudgetTitle,
            message: txt.twoItemsDominateBudgetMessage(
              top2[0].key,
              top2[1].key,
              (ratio * 100).toStringAsFixed(1),
            ),
            color: Colors.brown,
            icon: Icons.filter_2_rounded,
          ),
        );
      }
    }

    return items;
  }

  String _formatCurrency(double value) {
    return txt.currency(value);
  }

  String _scopeLabel() {
    return _periodMode == AnalysisPeriodMode.month
        ? '${txt.monthFull(_selectedMonth)} $_selectedYear'
        : txt.yearLabel(_selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final monetization = BudgetFamilialMonetizationScope.of(context);

    final categoryTotals = _categoryTotalsForCurrentScope();
    final subCategoryTotals = _subCategoryTotalsForCurrentScope();
    final monthlyStats = _monthlyEvolutionForSelectedYear();
    final alerts = _alertsForCurrentScope();
    final expenseComparison = _expenseComparisonForCurrentScope();
    final incomeComparison = _incomeComparisonForCurrentScope();
    final savingComparison = _savingComparisonForCurrentScope();
    final balanceComparison = _balanceComparisonForCurrentScope();
    final topExpenseInsights = _topExpenseInsightsForCurrentScope();
    final topIncreaseInsights = _topIncreaseInsightsForCurrentScope();

    final adviceItems = _buildAdviceItems(
      categoryTotals: categoryTotals,
      subCategoryTotals: subCategoryTotals,
      monthlyStats: monthlyStats,
      alerts: alerts,
      topExpenseInsights: topExpenseInsights,
      topIncreaseInsights: topIncreaseInsights,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          txt.analysisTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: monetization.canAccessExcelExport()
                  ? (_periodMode == AnalysisPeriodMode.month
                      ? txt.exportExcel
                      : txt.availableInMonthMode)
                  : txt.premiumExcelExport,
              onPressed: _isExporting ? null : _exportCurrentPeriodToExcel,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(
                      monetization.canAccessExcelExport()
                          ? Icons.table_view_rounded
                          : Icons.workspace_premium_rounded,
                      color: _periodMode == AnalysisPeriodMode.month
                          ? null
                          : Colors.grey,
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x100F172A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 520;

                  return Column(
                    children: [
                      if (isCompact) ...[
                        DropdownButtonFormField<int>(
                          initialValue: _selectedYear,
                          items: widget.years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedYear = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: txt.yearField,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMonth,
                          items: widget.months
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(txt.monthFull(month)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedMonth = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: txt.monthField,
                          ),
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedYear,
                                items: widget.years
                                    .map(
                                      (year) => DropdownMenuItem(
                                        value: year,
                                        child: Text(year.toString()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: txt.yearField,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedMonth,
                                items: widget.months
                                    .map(
                                      (month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(txt.monthFull(month)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: txt.monthField,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(txt.monthMode),
                              selected: _periodMode == AnalysisPeriodMode.month,
                              onSelected: (_) {
                                setState(() {
                                  _periodMode = AnalysisPeriodMode.month;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(txt.yearMode),
                              selected: _periodMode == AnalysisPeriodMode.year,
                              onSelected: (_) {
                                setState(() {
                                  _periodMode = AnalysisPeriodMode.year;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _viewChip(
                              label: txt.summaryTab,
                              view: AnalysisView.summary,
                            ),
                            const SizedBox(width: 8),
                            _viewChip(
                              label: txt.categoriesTab,
                              view: AnalysisView.categories,
                            ),
                            const SizedBox(width: 8),
                            _viewChip(
                              label: txt.subCategoriesTab,
                              view: AnalysisView.subCategories,
                            ),
                            const SizedBox(width: 8),
                            _viewChip(
                              label: txt.evolutionTab,
                              view: AnalysisView.evolution,
                            ),
                            const SizedBox(width: 8),
                            _viewChip(
                              label: monetization.isPremium
                                  ? txt.tipsTab
                                  : txt.tipsTabLocked,
                              view: AnalysisView.tips,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildSelectedView(
                  categoryTotals: categoryTotals,
                  subCategoryTotals: subCategoryTotals,
                  monthlyStats: monthlyStats,
                  adviceItems: adviceItems,
                  alerts: alerts,
                  incomeComparison: incomeComparison,
                  expenseComparison: expenseComparison,
                  savingComparison: savingComparison,
                  balanceComparison: balanceComparison,
                  topExpenseInsights: topExpenseInsights,
                  topIncreaseInsights: topIncreaseInsights,
                  isPremium: monetization.isPremium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewChip({
    required String label,
    required AnalysisView view,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedView == view,
      onSelected: (_) {
        _handleViewSelection(view);
      },
    );
  }

  Widget _buildSelectedView({
    required Map<String, double> categoryTotals,
    required Map<String, double> subCategoryTotals,
    required List<_MonthlyStat> monthlyStats,
    required List<_AdviceItem> adviceItems,
    required List<BudgetAlertData> alerts,
    required PeriodComparisonData? incomeComparison,
    required PeriodComparisonData? expenseComparison,
    required PeriodComparisonData? savingComparison,
    required PeriodComparisonData? balanceComparison,
    required List<ExpenseSubCategoryInsight> topExpenseInsights,
    required List<ExpenseSubCategoryInsight> topIncreaseInsights,
    required bool isPremium,
  }) {
    switch (_selectedView) {
      case AnalysisView.summary:
        return _SummaryView(
          key: const ValueKey('summary'),
          scopeLabel: _scopeLabel(),
          income: _currentIncome,
          expenses: _currentExpenses,
          savings: _currentSavings,
          balance: _currentBalance,
          operationCount: _currentOperationCount,
          averageExpensePerOperation: _averageExpensePerOperation,
          formatCurrency: _formatCurrency,
          alerts: alerts,
          incomeComparison: incomeComparison,
          expenseComparison: expenseComparison,
          savingComparison: savingComparison,
          balanceComparison: balanceComparison,
          topExpenseInsights: topExpenseInsights,
          topIncreaseInsights: topIncreaseInsights,
          periodMode: _periodMode,
          isPremium: isPremium,
          onUnlockPremium: () => _openPremiumFromLockedBlock(
            blockedMessage: txt.smartAnalysisPremiumOnly,
          ),
        );
      case AnalysisView.categories:
        return _CategoriesView(
          key: const ValueKey('categories'),
          scopeLabel: _scopeLabel(),
          totals: categoryTotals,
          totalExpenses: _currentExpenses,
          formatCurrency: _formatCurrency,
        );
      case AnalysisView.subCategories:
        return _SubCategoriesView(
          key: const ValueKey('subcategories'),
          scopeLabel: _scopeLabel(),
          totals: subCategoryTotals,
          formatCurrency: _formatCurrency,
          smartInsights: topExpenseInsights,
          increaseInsights: topIncreaseInsights,
          periodMode: _periodMode,
          isPremium: isPremium,
          onUnlockPremium: () => _openPremiumFromLockedBlock(
            blockedMessage: txt.advancedInsightsPremiumOnly,
          ),
        );
      case AnalysisView.evolution:
        return _EvolutionView(
          key: const ValueKey('evolution'),
          year: _selectedYear,
          stats: monthlyStats,
          formatCurrency: _formatCurrency,
        );
      case AnalysisView.tips:
        return _TipsView(
          key: const ValueKey('tips'),
          scopeLabel: _scopeLabel(),
          items: adviceItems,
        );
    }
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    super.key,
    required this.scopeLabel,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.balance,
    required this.operationCount,
    required this.averageExpensePerOperation,
    required this.formatCurrency,
    required this.alerts,
    required this.incomeComparison,
    required this.expenseComparison,
    required this.savingComparison,
    required this.balanceComparison,
    required this.topExpenseInsights,
    required this.topIncreaseInsights,
    required this.periodMode,
    required this.isPremium,
    required this.onUnlockPremium,
  });

  final String scopeLabel;
  final double income;
  final double expenses;
  final double savings;
  final double balance;
  final int operationCount;
  final double averageExpensePerOperation;
  final String Function(double value) formatCurrency;
  final List<BudgetAlertData> alerts;
  final PeriodComparisonData? incomeComparison;
  final PeriodComparisonData? expenseComparison;
  final PeriodComparisonData? savingComparison;
  final PeriodComparisonData? balanceComparison;
  final List<ExpenseSubCategoryInsight> topExpenseInsights;
  final List<ExpenseSubCategoryInsight> topIncreaseInsights;
  final AnalysisPeriodMode periodMode;
  final bool isPremium;
  final VoidCallback onUnlockPremium;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    final localIncomeComparison = incomeComparison;
    final localExpenseComparison = expenseComparison;
    final localSavingComparison = savingComparison;
    final localBalanceComparison = balanceComparison;

    final criticalAlerts =
        alerts.where((a) => a.level == BudgetAlertLevel.critical).toList();
    final warningAlerts =
        alerts.where((a) => a.level == BudgetAlertLevel.warning).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        _HeaderCard(title: txt.summaryTab, subtitle: scopeLabel),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: txt.incomeLabel,
              value: formatCurrency(income),
              color: const Color(0xFF16A34A),
            ),
            _MetricCard(
              title: txt.expensesLabel,
              value: formatCurrency(expenses),
              color: const Color(0xFFEF4444),
            ),
            _MetricCard(
              title: txt.savingsLabel,
              value: formatCurrency(savings),
              color: const Color(0xFF2563EB),
            ),
            _MetricCard(
              title: txt.balanceLabel,
              value: formatCurrency(balance),
              color: balance >= 0
                  ? const Color(0xFF14B8A6)
                  : const Color(0xFFF59E0B),
            ),
            _MetricCard(
              title: txt.operationsLabel,
              value: operationCount.toString(),
              color: const Color(0xFF7C3AED),
            ),
            _MetricCard(
              title: txt.averagePerOperationLabel,
              value: formatCurrency(averageExpensePerOperation),
              color: const Color(0xFF4F46E5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (periodMode == AnalysisPeriodMode.month) ...[
          if (isPremium) ...[
            _SmartComparisonSection(
              title: txt.comparisonPreviousMonthTitle,
              comparisons: [
                if (localIncomeComparison != null)
                  _ComparisonDisplayData(
                    label: txt.incomeLabel,
                    comparison: localIncomeComparison,
                    color: const Color(0xFF16A34A),
                    reverseMeaning: false,
                  ),
                if (localExpenseComparison != null)
                  _ComparisonDisplayData(
                    label: txt.expensesLabel,
                    comparison: localExpenseComparison,
                    color: const Color(0xFFEF4444),
                    reverseMeaning: true,
                  ),
                if (localSavingComparison != null)
                  _ComparisonDisplayData(
                    label: txt.savingsLabel,
                    comparison: localSavingComparison,
                    color: const Color(0xFF2563EB),
                    reverseMeaning: false,
                  ),
                if (localBalanceComparison != null)
                  _ComparisonDisplayData(
                    label: txt.balanceLabel,
                    comparison: localBalanceComparison,
                    color: const Color(0xFF14B8A6),
                    reverseMeaning: false,
                  ),
              ],
              formatCurrency: formatCurrency,
            ),
            const SizedBox(height: 16),
            _AlertsCard(alerts: alerts),
            const SizedBox(height: 16),
            if (topExpenseInsights.isNotEmpty)
              _InsightListCard(
                title: txt.highestSubCategoriesTitle,
                items: topExpenseInsights
                    .map(
                      (e) => _InsightLineData(
                        label: '${e.categoryName} > ${e.subCategoryName}',
                        value: e.currentAmount,
                        extra: txt.operationsCount(e.entryCount),
                      ),
                    )
                    .toList(),
                formatCurrency: formatCurrency,
              ),
            if (topExpenseInsights.isNotEmpty) const SizedBox(height: 16),
            if (topIncreaseInsights.isNotEmpty)
              _InsightListCard(
                title: txt.biggestIncreasesTitle,
                items: topIncreaseInsights
                    .where((e) => e.difference > 0)
                    .map(
                      (e) => _InsightLineData(
                        label: '${e.categoryName} > ${e.subCategoryName}',
                        value: e.difference,
                        extra: e.previousAmount > 0
                            ? '${e.percentChange.toStringAsFixed(1)} %'
                            : txt.newOrNotPresentBefore,
                      ),
                    )
                    .toList(),
                formatCurrency: formatCurrency,
              ),
            if (criticalAlerts.isNotEmpty || warningAlerts.isNotEmpty)
              const SizedBox(height: 16),
          ] else ...[
            _PremiumLockedCard(
              title: txt.premiumSmartAnalysisTitle,
              message: txt.premiumSmartAnalysisMessage,
              buttonLabel: txt.unlockPremium,
              onPressed: onUnlockPremium,
            ),
            const SizedBox(height: 16),
          ],
        ],
        _SimpleComparisonChart(
          title: txt.overviewTitle,
          values: [
            _ChartValue(txt.incomeLabel, income, const Color(0xFF16A34A)),
            _ChartValue(txt.expensesLabel, expenses, const Color(0xFFEF4444)),
            _ChartValue(txt.savingsLabel, savings, const Color(0xFF2563EB)),
            _ChartValue(
              txt.balanceLabel,
              balance.abs(),
              balance >= 0 ? const Color(0xFF14B8A6) : const Color(0xFFF59E0B),
            ),
          ],
          formatCurrency: formatCurrency,
        ),
      ],
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView({
    super.key,
    required this.scopeLabel,
    required this.totals,
    required this.totalExpenses,
    required this.formatCurrency,
  });

  final String scopeLabel;
  final Map<String, double> totals;
  final double totalExpenses;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        _HeaderCard(title: txt.categoriesTab, subtitle: scopeLabel),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          _EmptyCard(
            message: txt.noExpenseForThisView,
          )
        else ...[
          _DistributionCard(
            title: txt.categoryDistributionTitle,
            items: sorted
                .map(
                  (e) => _DistributionItem(
                    label: e.key,
                    value: e.value,
                    ratio: totalExpenses <= 0 ? 0.0 : (e.value / totalExpenses),
                  ),
                )
                .toList(),
            formatCurrency: formatCurrency,
          ),
          const SizedBox(height: 16),
          _TopListCard(
            title: txt.categoryRankingTitle,
            entries: sorted,
            total: totalExpenses,
            formatCurrency: formatCurrency,
          ),
        ],
      ],
    );
  }
}

class _SubCategoriesView extends StatelessWidget {
  const _SubCategoriesView({
    super.key,
    required this.scopeLabel,
    required this.totals,
    required this.formatCurrency,
    required this.smartInsights,
    required this.increaseInsights,
    required this.periodMode,
    required this.isPremium,
    required this.onUnlockPremium,
  });

  final String scopeLabel;
  final Map<String, double> totals;
  final String Function(double value) formatCurrency;
  final List<ExpenseSubCategoryInsight> smartInsights;
  final List<ExpenseSubCategoryInsight> increaseInsights;
  final AnalysisPeriodMode periodMode;
  final bool isPremium;
  final VoidCallback onUnlockPremium;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.take(10).toList();
    final double maxValue = top.isEmpty ? 0.0 : top.first.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        _HeaderCard(title: txt.subCategoriesTab, subtitle: scopeLabel),
        const SizedBox(height: 12),
        if (periodMode == AnalysisPeriodMode.month &&
            isPremium &&
            smartInsights.isNotEmpty) ...[
          _InsightListCard(
            title: txt.heaviestSubCategoriesTitle,
            items: smartInsights
                .map(
                  (e) => _InsightLineData(
                    label: '${e.categoryName} > ${e.subCategoryName}',
                    value: e.currentAmount,
                    extra: txt.operationsCount(e.entryCount),
                  ),
                )
                .toList(),
            formatCurrency: formatCurrency,
          ),
          const SizedBox(height: 16),
        ],
        if (periodMode == AnalysisPeriodMode.month &&
            isPremium &&
            increaseInsights.any((e) => e.difference > 0)) ...[
          _InsightListCard(
            title: txt.subCategoriesRisingTitle,
            items: increaseInsights
                .where((e) => e.difference > 0)
                .map(
                  (e) => _InsightLineData(
                    label: '${e.categoryName} > ${e.subCategoryName}',
                    value: e.difference,
                    extra: e.previousAmount > 0
                        ? '${e.percentChange.toStringAsFixed(1)} %'
                        : txt.newOrNotPresentBefore,
                  ),
                )
                .toList(),
            formatCurrency: formatCurrency,
          ),
          const SizedBox(height: 16),
        ],
        if (periodMode == AnalysisPeriodMode.month && !isPremium) ...[
          _PremiumLockedCard(
            title: txt.premiumAdvancedInsightsTitle,
            message: txt.premiumAdvancedInsightsMessage,
            buttonLabel: txt.unlockPremium,
            onPressed: onUnlockPremium,
          ),
          const SizedBox(height: 16),
        ],
        if (top.isEmpty)
          _EmptyCard(
            message: txt.noSubCategoryExpenseForView,
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: top.map((entry) {
                  final double ratio =
                      maxValue == 0 ? 0.0 : (entry.value / maxValue);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(entry.key)),
                            const SizedBox(width: 12),
                            Text(
                              formatCurrency(entry.value),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _EvolutionView extends StatelessWidget {
  const _EvolutionView({
    super.key,
    required this.year,
    required this.stats,
    required this.formatCurrency,
  });

  final int year;
  final List<_MonthlyStat> stats;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    final double maxExpenses = stats.fold<double>(
      0.0,
      (max, item) => item.expenses > max ? item.expenses : max,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        _HeaderCard(
          title: txt.evolutionTab,
          subtitle: txt.yearLabel(year),
        ),
        const SizedBox(height: 12),
        if (stats
            .every((e) => e.income == 0 && e.expenses == 0 && e.savings == 0))
          _EmptyCard(
            message: txt.noDataForYear,
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: stats.map((stat) {
                  final double ratio =
                      maxExpenses == 0 ? 0.0 : (stat.expenses / maxExpenses);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 42,
                              child: Text(
                                stat.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 12,
                                  color: const Color(0xFFEF4444),
                                  backgroundColor: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 90,
                              child: Text(
                                formatCurrency(stat.expenses),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniPill(
                              label: txt.shortIncome,
                              value: formatCurrency(stat.income),
                              color: const Color(0xFF16A34A),
                            ),
                            _MiniPill(
                              label: txt.shortExpenses,
                              value: formatCurrency(stat.expenses),
                              color: const Color(0xFFEF4444),
                            ),
                            _MiniPill(
                              label: txt.shortSavings,
                              value: formatCurrency(stat.savings),
                              color: const Color(0xFF2563EB),
                            ),
                            _MiniPill(
                              label: txt.shortBalance,
                              value: formatCurrency(stat.balance),
                              color: stat.balance >= 0
                                  ? const Color(0xFF14B8A6)
                                  : const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _TipsView extends StatelessWidget {
  const _TipsView({
    super.key,
    required this.scopeLabel,
    required this.items,
  });

  final String scopeLabel;
  final List<_AdviceItem> items;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        _HeaderCard(title: txt.tipsTab, subtitle: scopeLabel),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4E9F2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumLockedCard extends StatelessWidget {
  const _PremiumLockedCard({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7D6)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E8F2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF4338CA),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.circle, size: 14, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleComparisonChart extends StatelessWidget {
  const _SimpleComparisonChart({
    required this.title,
    required this.values,
    required this.formatCurrency,
  });

  final String title;
  final List<_ChartValue> values;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final double maxValue = values.fold<double>(
      0.0,
      (max, item) => item.value > max ? item.value : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...values.map((item) {
              final double ratio =
                  maxValue == 0 ? 0.0 : (item.value / maxValue);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.label)),
                        Text(
                          formatCurrency(item.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 12,
                        color: item.color,
                        backgroundColor: item.color.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SmartComparisonSection extends StatelessWidget {
  const _SmartComparisonSection({
    required this.title,
    required this.comparisons,
    required this.formatCurrency,
  });

  final String title;
  final List<_ComparisonDisplayData> comparisons;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    if (comparisons.isEmpty) {
      return _EmptyCard(
        message: txt.noComparisonAvailable,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...comparisons.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            formatCurrency(item.comparison.currentValue),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: item.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        txt.previousMonthValue(
                          formatCurrency(item.comparison.previousValue),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DeltaPill(
                        comparison: item.comparison,
                        reverseMeaning: item.reverseMeaning,
                        formatCurrency: formatCurrency,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({
    required this.alerts,
  });

  final List<BudgetAlertData> alerts;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    if (alerts.isEmpty) {
      return _EmptyCard(
        message: txt.noAlertsForMonth,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    txt.smartAlertsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map(
              (alert) {
                final _AlertVisuals visuals = _alertVisuals(alert.level);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: visuals.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: visuals.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(visuals.icon, color: visuals.foreground),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: visuals.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
                              style: const TextStyle(
                                color: Color(0xFF475467),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _AlertVisuals _alertVisuals(BudgetAlertLevel level) {
    switch (level) {
      case BudgetAlertLevel.critical:
        return const _AlertVisuals(
          foreground: Color(0xFFB42318),
          background: Color(0xFFFEF3F2),
          border: Color(0xFFFECACA),
          icon: Icons.error_outline,
        );
      case BudgetAlertLevel.warning:
        return const _AlertVisuals(
          foreground: Color(0xFFB54708),
          background: Color(0xFFFFFAEB),
          border: Color(0xFFFDE68A),
          icon: Icons.warning_amber_rounded,
        );
      case BudgetAlertLevel.info:
        return const _AlertVisuals(
          foreground: Color(0xFF175CD3),
          background: Color(0xFFEFF8FF),
          border: Color(0xFFBFDBFE),
          icon: Icons.info_outline,
        );
    }
  }
}

class _InsightListCard extends StatelessWidget {
  const _InsightListCard({
    required this.title,
    required this.items,
    required this.formatCurrency,
  });

  final String title;
  final List<_InsightLineData> items;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (item.extra != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.extra!,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatCurrency(item.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.comparison,
    required this.reverseMeaning,
    required this.formatCurrency,
  });

  final PeriodComparisonData comparison;
  final bool reverseMeaning;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final txt = _AnalysisI18n.of(context);

    final isPositiveDirection = comparison.difference >= 0;
    final isGood = reverseMeaning ? !isPositiveDirection : isPositiveDirection;

    final Color color = comparison.isStable
        ? const Color(0xFF475467)
        : isGood
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626);

    final IconData icon = comparison.isStable
        ? Icons.horizontal_rule_rounded
        : isGood
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded;

    final String sign = comparison.difference > 0 ? '+' : '';
    final String percentText =
        '${comparison.percentChange >= 0 ? '+' : ''}${comparison.percentChange.toStringAsFixed(1)} %';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              comparison.isStable
                  ? txt.stable
                  : '$sign${formatCurrency(comparison.difference.abs())} • $percentText',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.title,
    required this.items,
    required this.formatCurrency,
  });

  final String title;
  final List<_DistributionItem> items;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.label)),
                        Text(
                          '${(item.ratio * 100).toStringAsFixed(1)} %',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatCurrency(item.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.ratio,
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TopListCard extends StatelessWidget {
  const _TopListCard({
    required this.title,
    required this.entries,
    required this.total,
    required this.formatCurrency,
  });

  final String title;
  final List<MapEntry<String, double>> entries;
  final double total;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final double ratio = total <= 0 ? 0.0 : (entry.value / total);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${(ratio * 100).toStringAsFixed(1)} %',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatCurrency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$label : $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
        ),
      ),
    );
  }
}

class _ChartValue {
  const _ChartValue(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _DistributionItem {
  const _DistributionItem({
    required this.label,
    required this.value,
    required this.ratio,
  });

  final String label;
  final double value;
  final double ratio;
}

class _MonthlyStat {
  const _MonthlyStat({
    required this.label,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.balance,
  });

  final String label;
  final double income;
  final double expenses;
  final double savings;
  final double balance;
}

class _AdviceItem {
  const _AdviceItem({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;
}

class _ComparisonDisplayData {
  const _ComparisonDisplayData({
    required this.label,
    required this.comparison,
    required this.color,
    required this.reverseMeaning,
  });

  final String label;
  final PeriodComparisonData comparison;
  final Color color;
  final bool reverseMeaning;
}

class _InsightLineData {
  const _InsightLineData({
    required this.label,
    required this.value,
    this.extra,
  });

  final String label;
  final double value;
  final String? extra;
}

class _AlertVisuals {
  const _AlertVisuals({
    required this.foreground,
    required this.background,
    required this.border,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final Color border;
  final IconData icon;
}

class _AnalysisI18n {
  const _AnalysisI18n._(this.languageCode);

  final String languageCode;

  static _AnalysisI18n of(BuildContext context) {
    return _AnalysisI18n._(Localizations.localeOf(context).languageCode);
  }

  bool get isNl => languageCode == 'nl';
  bool get isEn => languageCode == 'en';
  bool get isFr => !isEn && !isNl;

  String currency(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  String monthFull(String month) {
    switch (month) {
      case 'Janvier':
        return isEn
            ? 'January'
            : isNl
                ? 'Januari'
                : 'Janvier';
      case 'Février':
        return isEn
            ? 'February'
            : isNl
                ? 'Februari'
                : 'Février';
      case 'Mars':
        return isEn
            ? 'March'
            : isNl
                ? 'Maart'
                : 'Mars';
      case 'Avril':
        return isEn
            ? 'April'
            : isNl
                ? 'April'
                : 'Avril';
      case 'Mai':
        return isEn
            ? 'May'
            : isNl
                ? 'Mei'
                : 'Mai';
      case 'Juin':
        return isEn
            ? 'June'
            : isNl
                ? 'Juni'
                : 'Juin';
      case 'Juillet':
        return isEn
            ? 'July'
            : isNl
                ? 'Juli'
                : 'Juillet';
      case 'Août':
        return isEn
            ? 'August'
            : isNl
                ? 'Augustus'
                : 'Août';
      case 'Septembre':
        return isEn
            ? 'September'
            : isNl
                ? 'September'
                : 'Septembre';
      case 'Octobre':
        return isEn
            ? 'October'
            : isNl
                ? 'Oktober'
                : 'Octobre';
      case 'Novembre':
        return isEn
            ? 'November'
            : isNl
                ? 'November'
                : 'Novembre';
      case 'Décembre':
        return isEn
            ? 'December'
            : isNl
                ? 'December'
                : 'Décembre';
      default:
        return month;
    }
  }

  String monthShort(String month) {
    switch (month) {
      case 'Janvier':
        return isEn
            ? 'Jan'
            : isNl
                ? 'Jan'
                : 'Jan';
      case 'Février':
        return isEn
            ? 'Feb'
            : isNl
                ? 'Feb'
                : 'Fév';
      case 'Mars':
        return isEn
            ? 'Mar'
            : isNl
                ? 'Mrt'
                : 'Mar';
      case 'Avril':
        return isEn
            ? 'Apr'
            : isNl
                ? 'Apr'
                : 'Avr';
      case 'Mai':
        return isEn
            ? 'May'
            : isNl
                ? 'Mei'
                : 'Mai';
      case 'Juin':
        return isEn
            ? 'Jun'
            : isNl
                ? 'Jun'
                : 'Jui';
      case 'Juillet':
        return isEn
            ? 'Jul'
            : isNl
                ? 'Jul'
                : 'Jul';
      case 'Août':
        return isEn
            ? 'Aug'
            : isNl
                ? 'Aug'
                : 'Aoû';
      case 'Septembre':
        return isEn
            ? 'Sep'
            : isNl
                ? 'Sep'
                : 'Sep';
      case 'Octobre':
        return isEn
            ? 'Oct'
            : isNl
                ? 'Okt'
                : 'Oct';
      case 'Novembre':
        return isEn
            ? 'Nov'
            : isNl
                ? 'Nov'
                : 'Nov';
      case 'Décembre':
        return isEn
            ? 'Dec'
            : isNl
                ? 'Dec'
                : 'Déc';
      default:
        return month.length <= 3 ? month : month.substring(0, 3);
    }
  }

  String yearLabel(int year) => isEn
      ? 'Year $year'
      : isNl
          ? 'Jaar $year'
          : 'Année $year';

  String get analysisTitle => isEn
      ? 'Analysis'
      : isNl
          ? 'Analyse'
          : 'Analyse';
  String get exportExcel => isEn
      ? 'Export Excel'
      : isNl
          ? 'Excel exporteren'
          : 'Exporter Excel';
  String get availableInMonthMode => isEn
      ? 'Available in Month mode'
      : isNl
          ? 'Beschikbaar in maandmodus'
          : 'Disponible en mode Mois';
  String get premiumExcelExport => isEn
      ? 'Premium Excel export'
      : isNl
          ? 'Premium Excel-export'
          : 'Export Excel Premium';

  String get yearField => isEn
      ? 'Year'
      : isNl
          ? 'Jaar'
          : 'Année';
  String get monthField => isEn
      ? 'Month'
      : isNl
          ? 'Maand'
          : 'Mois';
  String get monthMode => isEn
      ? 'Month'
      : isNl
          ? 'Maand'
          : 'Mois';
  String get yearMode => isEn
      ? 'Year'
      : isNl
          ? 'Jaar'
          : 'Année';

  String get summaryTab => isEn
      ? 'Summary'
      : isNl
          ? 'Samenvatting'
          : 'Résumé';
  String get categoriesTab => isEn
      ? 'Categories'
      : isNl
          ? 'Categorieën'
          : 'Catégories';
  String get subCategoriesTab => isEn
      ? 'Sub-categories'
      : isNl
          ? 'Subcategorieën'
          : 'Sous-catégories';
  String get evolutionTab => isEn
      ? 'Evolution'
      : isNl
          ? 'Evolutie'
          : 'Évolution';
  String get tipsTab => isEn
      ? 'Tips'
      : isNl
          ? 'Advies'
          : 'Conseils';
  String get tipsTabLocked => isEn
      ? 'Tips 🔒'
      : isNl
          ? 'Advies 🔒'
          : 'Conseils 🔒';

  String get tipsTabPremiumOnly => isEn
      ? 'The Tips tab is reserved for Premium users.'
      : isNl
          ? 'Het tabblad Advies is alleen voor Premium-gebruikers.'
          : 'L’onglet Conseils est réservé aux utilisateurs Premium.';
  String get excelExportPremiumOnly => isEn
      ? 'Excel export is reserved for Premium users.'
      : isNl
          ? 'Excel-export is alleen voor Premium-gebruikers.'
          : 'L’export Excel est réservé aux utilisateurs Premium.';
  String get excelExportMonthOnly => isEn
      ? 'Excel export is currently available only in Month mode.'
      : isNl
          ? 'Excel-export is momenteel alleen beschikbaar in maandmodus.'
          : 'L’export Excel est disponible uniquement en mode Mois pour le moment.';
  String excelExportShareText(String period) => isEn
      ? 'Budget Excel export - $period'
      : isNl
          ? 'Budget Excel-export - $period'
          : 'Export Excel du budget - $period';
  String excelExportShareSubject(String period) => 'Budget $period';
  String excelFileReady(String fileName) => isEn
      ? 'Excel file ready: $fileName'
      : isNl
          ? 'Excel-bestand klaar: $fileName'
          : 'Fichier Excel prêt : $fileName';
  String excelExportError(String error) => isEn
      ? 'Error while exporting Excel: $error'
      : isNl
          ? 'Fout bij Excel-export: $error'
          : 'Erreur lors de l’export Excel : $error';

  String get smartAnalysisPremiumOnly => isEn
      ? 'Smart analysis is reserved for Premium users.'
      : isNl
          ? 'Slimme analyses zijn alleen voor Premium-gebruikers.'
          : 'Les analyses intelligentes sont réservées aux utilisateurs Premium.';
  String get advancedInsightsPremiumOnly => isEn
      ? 'Advanced insights are reserved for Premium users.'
      : isNl
          ? 'Geavanceerde inzichten zijn alleen voor Premium-gebruikers.'
          : 'Les insights avancés sont réservés aux utilisateurs Premium.';

  String get incomeLabel => isEn
      ? 'Income'
      : isNl
          ? 'Inkomsten'
          : 'Rentrées';
  String get expensesLabel => isEn
      ? 'Expenses'
      : isNl
          ? 'Uitgaven'
          : 'Dépenses';
  String get savingsLabel => isEn
      ? 'Savings'
      : isNl
          ? 'Spaargeld'
          : 'Économies';
  String get balanceLabel => isEn
      ? 'Balance'
      : isNl
          ? 'Saldo'
          : 'Solde';
  String get operationsLabel => isEn
      ? 'Operations'
      : isNl
          ? 'Bewerkingen'
          : 'Opérations';
  String get averagePerOperationLabel => isEn
      ? 'Average / operation'
      : isNl
          ? 'Gemiddelde / bewerking'
          : 'Moyenne / opération';

  String get comparisonPreviousMonthTitle => isEn
      ? 'Comparison with previous month'
      : isNl
          ? 'Vergelijking met vorige maand'
          : 'Comparaison avec le mois précédent';
  String get highestSubCategoriesTitle => isEn
      ? 'Highest sub-categories'
      : isNl
          ? 'Hoogste subcategorieën'
          : 'Sous-catégories les plus élevées';
  String get biggestIncreasesTitle => isEn
      ? 'Biggest increases'
      : isNl
          ? 'Sterkste stijgingen'
          : 'Plus fortes hausses';
  String get overviewTitle => isEn
      ? 'Overview'
      : isNl
          ? 'Overzicht'
          : 'Vue d’ensemble';
  String operationsCount(int count) => isEn
      ? '$count operation(s)'
      : isNl
          ? '$count bewerking(en)'
          : '$count opération(s)';
  String get newOrNotPresentBefore => isEn
      ? 'New or not present before'
      : isNl
          ? 'Nieuw of eerder niet aanwezig'
          : 'Nouveau ou non présent avant';

  String get premiumSmartAnalysisTitle => isEn
      ? 'Premium smart analysis'
      : isNl
          ? 'Premium slimme analyses'
          : 'Analyses intelligentes Premium';
  String get premiumSmartAnalysisMessage => isEn
      ? 'Unlock comparison with the previous month, smart alerts and advanced insights.'
      : isNl
          ? 'Ontgrendel vergelijking met de vorige maand, slimme waarschuwingen en geavanceerde inzichten.'
          : 'Débloque la comparaison avec le mois précédent, les alertes intelligentes et les insights avancés.';
  String get unlockPremium => isEn
      ? 'Unlock Premium'
      : isNl
          ? 'Premium ontgrendelen'
          : 'Débloquer Premium';

  String get categoryDistributionTitle => isEn
      ? 'Distribution by category'
      : isNl
          ? 'Verdeling per categorie'
          : 'Répartition par catégorie';
  String get categoryRankingTitle => isEn
      ? 'Category ranking'
      : isNl
          ? 'Categorieklassement'
          : 'Classement des catégories';
  String get noExpenseForThisView => isEn
      ? 'No expenses recorded for this view.'
      : isNl
          ? 'Geen uitgaven geregistreerd voor deze weergave.'
          : 'Aucune dépense enregistrée pour cette vue.';

  String get heaviestSubCategoriesTitle => isEn
      ? 'Heaviest sub-categories'
      : isNl
          ? 'Zwaarste subcategorieën'
          : 'Sous-catégories les plus lourdes';
  String get subCategoriesRisingTitle => isEn
      ? 'Rising sub-categories'
      : isNl
          ? 'Stijgende subcategorieën'
          : 'Sous-catégories en hausse';
  String get premiumAdvancedInsightsTitle => isEn
      ? 'Premium advanced insights'
      : isNl
          ? 'Premium geavanceerde inzichten'
          : 'Insights avancés Premium';
  String get premiumAdvancedInsightsMessage => isEn
      ? 'Unlock the heaviest sub-categories, increases and advanced insights.'
      : isNl
          ? 'Ontgrendel de zwaarste subcategorieën, stijgingen en geavanceerde inzichten.'
          : 'Débloque les sous-catégories les plus lourdes, les hausses et les insights avancés.';
  String get noSubCategoryExpenseForView => isEn
      ? 'No sub-category with expenses for this view.'
      : isNl
          ? 'Geen subcategorie met uitgaven voor deze weergave.'
          : 'Aucune sous-catégorie avec dépenses pour cette vue.';

  String get noDataForYear => isEn
      ? 'No data available for this year.'
      : isNl
          ? 'Geen gegevens beschikbaar voor dit jaar.'
          : 'Aucune donnée disponible sur cette année.';
  String get shortIncome => 'R';
  String get shortExpenses => isEn
      ? 'E'
      : isNl
          ? 'U'
          : 'D';
  String get shortSavings => isEn
      ? 'S'
      : isNl
          ? 'S'
          : 'É';
  String get shortBalance => 'S';

  String get premiumUnlocksSummary => isEn
      ? 'Premium unlocks monthly comparison, smart alerts and advanced insights.'
      : isNl
          ? 'Premium ontgrendelt maandelijkse vergelijking, slimme waarschuwingen en geavanceerde inzichten.'
          : 'Premium débloque la comparaison mensuelle, les alertes intelligentes et les insights avancés.';
  String get categoriesFreeView => isEn
      ? 'The Categories view stays available for free.'
      : isNl
          ? 'De categorieënweergave blijft gratis beschikbaar.'
          : 'La vue Catégories reste disponible gratuitement.';
  String get premiumUnlocksSubCategories => isEn
      ? 'Premium unlocks the heaviest sub-categories and monthly increases.'
      : isNl
          ? 'Premium ontgrendelt de zwaarste subcategorieën en maandelijkse stijgingen.'
          : 'Premium débloque les sous-catégories les plus lourdes et les hausses du mois.';
  String get evolutionFreeView => isEn
      ? 'The Evolution view stays available for free.'
      : isNl
          ? 'De evolutieweergave blijft gratis beschikbaar.'
          : 'La vue Évolution reste disponible gratuitement.';
  String get premiumUnlocksTips => isEn
      ? 'Premium unlocks automatic tips and smart assistance.'
      : isNl
          ? 'Premium ontgrendelt automatisch advies en slimme hulp.'
          : 'Premium débloque les conseils automatiques et l’aide intelligente.';

  String get unlockSmartAnalysis => isEn
      ? 'Unlock smart analysis'
      : isNl
          ? 'Slimme analyses ontgrendelen'
          : 'Débloquer les analyses smart';
  String get seePremium => isEn
      ? 'See Premium'
      : isNl
          ? 'Bekijk Premium'
          : 'Voir Premium';
  String get unlockInsights => isEn
      ? 'Unlock insights'
      : isNl
          ? 'Inzichten ontgrendelen'
          : 'Débloquer les insights';
  String get unlockTips => isEn
      ? 'Unlock tips'
      : isNl
          ? 'Advies ontgrendelen'
          : 'Débloquer les conseils';

  String get comparisonsAlertsPremiumOnly => isEn
      ? 'Comparisons and smart alerts are reserved for Premium users.'
      : isNl
          ? 'Vergelijkingen en slimme waarschuwingen zijn alleen voor Premium-gebruikers.'
          : 'Les comparaisons et alertes intelligentes sont réservées aux utilisateurs Premium.';
  String get premiumFunctionsPremiumOnly => isEn
      ? 'Premium functions are reserved for Premium users.'
      : isNl
          ? 'Premiumfuncties zijn alleen voor Premium-gebruikers.'
          : 'Les fonctions premium sont réservées aux utilisateurs Premium.';
  String get automaticTipsPremiumOnly => isEn
      ? 'Automatic tips are reserved for Premium users.'
      : isNl
          ? 'Automatisch advies is alleen voor Premium-gebruikers.'
          : 'Les conseils automatiques sont réservés aux utilisateurs Premium.';

  String activePlanLabel(String plan) => isEn
      ? '$plan active'
      : isNl
          ? '$plan actief'
          : '$plan actif';
  String get premiumFeaturesAvailable => isEn
      ? 'Premium features available'
      : isNl
          ? 'Premiumfuncties beschikbaar'
          : 'Fonctions premium disponibles';
  String get premiumUnlockedDescription => isEn
      ? 'Excel export, tips and advanced analysis are unlocked.'
      : isNl
          ? 'Excel-export, advies en geavanceerde analyses zijn ontgrendeld.'
          : 'Export Excel, conseils et analyses avancées sont déverrouillés.';
  String get premiumModeStillDependsSelectedMode => isEn
      ? 'Premium is active. Some options still depend on the selected mode.'
      : isNl
          ? 'Premium is actief. Sommige opties hangen nog af van de geselecteerde modus.'
          : 'Premium actif. Certaines options dépendent encore du mode sélectionné.';

  String get noComparisonAvailable => isEn
      ? 'No comparison available for this period.'
      : isNl
          ? 'Geen vergelijking beschikbaar voor deze periode.'
          : 'Aucune comparaison disponible pour cette période.';
  String previousMonthValue(String value) => isEn
      ? 'Previous month: $value'
      : isNl
          ? 'Vorige maand: $value'
          : 'Mois précédent : $value';
  String get smartAlertsTitle => isEn
      ? 'Smart alerts'
      : isNl
          ? 'Slimme waarschuwingen'
          : 'Alertes intelligentes';
  String get noAlertsForMonth => isEn
      ? 'No alerts detected for this month.'
      : isNl
          ? 'Geen waarschuwingen gedetecteerd voor deze maand.'
          : 'Aucune alerte détectée pour ce mois.';
  String get stable => isEn
      ? 'Stable'
      : isNl
          ? 'Stabiel'
          : 'Stable';

  String get noExpenseRecordedTitle => isEn
      ? 'No expense recorded'
      : isNl
          ? 'Geen uitgaven geregistreerd'
          : 'Aucune dépense enregistrée';
  String get noExpenseRecordedMessage => isEn
      ? 'There are no expenses yet for this period. Tips will appear once you enter a few operations.'
      : isNl
          ? 'Er zijn nog geen uitgaven voor deze periode. Adviezen verschijnen zodra je enkele bewerkingen invoert.'
          : 'Il n’y a pas encore de dépense sur cette période. Les conseils apparaîtront dès que tu auras saisi quelques opérations.';

  String get criticalAlertDetectedTitle => isEn
      ? 'Critical alert detected'
      : isNl
          ? 'Kritieke waarschuwing gedetecteerd'
          : 'Alerte critique détectée';
  String criticalAlertDetectedMessage(int critical, int warning) => isEn
      ? '$critical critical alert(s) and $warning warning alert(s) were detected for this month. Start by handling the balance and the biggest increases.'
      : isNl
          ? '$critical kritieke waarschuwing(en) en $warning waarschuwing(en) zijn gedetecteerd voor deze maand. Begin met het saldo en de grootste stijgingen.'
          : '$critical alerte critique et $warning alerte(s) de vigilance ont été détectées pour ce mois. Commence par traiter le solde et les plus grosses hausses.';
  String get watchPointsDetectedTitle => isEn
      ? 'Watch points detected'
      : isNl
          ? 'Aandachtspunten gedetecteerd'
          : 'Points de vigilance détectés';
  String watchPointsDetectedMessage(int warning) => isEn
      ? '$warning alert(s) were detected this month. Comparing them with the previous month helps spot differences quickly.'
      : isNl
          ? '$warning waarschuwing(en) zijn deze maand gedetecteerd. Vergelijken met de vorige maand helpt verschillen snel te zien.'
          : '$warning alerte(s) ont été détectées sur ce mois. Les comparer au mois précédent permet de repérer vite les écarts.';

  String get expensesHigherThanAvailableTitle => isEn
      ? 'Expenses higher than available funds'
      : isNl
          ? 'Uitgaven hoger dan beschikbaar'
          : 'Dépenses supérieures au disponible';
  String expensesHigherThanAvailableMessage(String scope) => isEn
      ? 'The balance is negative for $scope. Expenses and savings exceed income. Start by reviewing the heaviest items.'
      : isNl
          ? 'Het saldo is negatief voor $scope. Uitgaven en spaargeld zijn hoger dan de inkomsten. Bekijk eerst de zwaarste posten.'
          : 'Le solde est négatif sur $scope. Les dépenses et économies dépassent les rentrées. Il faut d’abord regarder les postes les plus lourds.';
  String get positiveBalanceTitle => isEn
      ? 'Positive balance'
      : isNl
          ? 'Positief saldo'
          : 'Solde positif';
  String positiveBalanceMessage(String scope) => isEn
      ? 'The balance remains positive for $scope. You can still improve your budget by optimizing the biggest items.'
      : isNl
          ? 'Het saldo blijft positief voor $scope. Je kunt je budget nog verbeteren door de grootste posten te optimaliseren.'
          : 'Le solde reste positif sur $scope. Tu peux encore améliorer ton budget en optimisant les postes les plus importants.';

  String get mainCategoryTitle => isEn
      ? 'Main category'
      : isNl
          ? 'Hoofdcategorie'
          : 'Catégorie principale';
  String mainCategoryMessage(String category, String percent, String amount) => isEn
      ? '$category represents $percent% of expenses, i.e. $amount. This is the most strategic item to analyze.'
      : isNl
          ? '$category vertegenwoordigt $percent% van de uitgaven, dus $amount. Dit is de meest strategische post om te analyseren.'
          : '$category représente $percent % des dépenses, soit $amount. C’est le poste le plus stratégique à analyser.';

  String get subCategoryToWatchTitle => isEn
      ? 'Sub-category to watch'
      : isNl
          ? 'Subcategorie om te volgen'
          : 'Sous-catégorie à surveiller';
  String subCategoryToWatchMessage(
    String subCategory,
    String amount,
    String percent,
  ) =>
      isEn
          ? '$subCategory totals $amount, i.e. $percent% of expenses. Looking for an alternative here can have a quick impact.'
          : isNl
              ? '$subCategory bedraagt $amount, oftewel $percent% van de uitgaven. Hier een alternatief zoeken kan snel effect hebben.'
              : '$subCategory totalise $amount, soit $percent % des dépenses. Chercher une alternative ici peut avoir un effet rapide.';

  String get biggestIncreaseOfMonthTitle => isEn
      ? 'Biggest increase of the month'
      : isNl
          ? 'Grootste stijging van de maand'
          : 'Plus forte hausse du mois';
  String biggestIncreaseOfMonthMessage(
    String subCategory,
    String difference,
    String extra,
  ) =>
      isEn
          ? '$subCategory increases by $difference compared with the previous month$extra. This is the first item to compare with history.'
          : isNl
              ? '$subCategory stijgt met $difference ten opzichte van de vorige maand$extra. Dit is de eerste post om met de historiek te vergelijken.'
              : '$subCategory augmente de $difference par rapport au mois précédent$extra. C’est le premier poste à comparer avec l’historique.';

  String get heaviestItemOfMonthTitle => isEn
      ? 'Heaviest item of the month'
      : isNl
          ? 'Zwaarste post van de maand'
          : 'Poste le plus lourd du mois';
  String heaviestItemOfMonthMessage(
    String subCategory,
    String amount,
    int count,
  ) =>
      isEn
          ? '$subCategory is the highest sub-category with $amount spread over $count operation(s).'
          : isNl
              ? '$subCategory is de hoogste subcategorie met $amount verdeeld over $count bewerking(en).'
              : '$subCategory est la sous-catégorie la plus élevée avec $amount répartis sur $count opération(s).';

  String get manySmallOperationsTitle => isEn
      ? 'Many small operations'
      : isNl
          ? 'Veel kleine bewerkingen'
          : 'Beaucoup de petites opérations';
  String manySmallOperationsMessage(int count, String avg) => isEn
      ? 'The number of operations is high ($count) with an average of $avg. Grouping some purchases can help avoid impulse spending.'
      : isNl
          ? 'Het aantal bewerkingen is hoog ($count) met een gemiddelde van $avg. Sommige aankopen groeperen kan kleine extra-uitgaven vermijden.'
          : 'Le nombre d’opérations est élevé ($count) avec une moyenne de $avg. Regrouper certains achats peut éviter les dépenses d’appoint.';

  String get noSavingsRecordedTitle => isEn
      ? 'No savings recorded'
      : isNl
          ? 'Geen spaargeld geregistreerd'
          : 'Aucune économie enregistrée';
  String get noSavingsRecordedMessage => isEn
      ? 'No savings are recorded for this period. Setting a small regular amount can already improve budget stability.'
      : isNl
          ? 'Er is geen spaargeld geregistreerd voor deze periode. Een klein regelmatig bedrag kan de stabiliteit van het budget al verbeteren.'
          : 'Aucune économie n’est renseignée sur cette période. Fixer un petit montant régulier peut déjà améliorer la stabilité du budget.';

  String get monthHigherThanAverageTitle => isEn
      ? 'Month higher than average'
      : isNl
          ? 'Maand hoger dan gemiddeld'
          : 'Mois plus élevé que la moyenne';
  String monthHigherThanAverageMessage(String monthLabel) => isEn
      ? '$monthLabel is clearly above the average monthly expenses. It is worth reviewing that month in detail to spot the differences.'
      : isNl
          ? '$monthLabel ligt duidelijk boven de gemiddelde maandelijkse uitgaven. Het loont om die maand in detail te bekijken om verschillen te vinden.'
          : '$monthLabel dépasse nettement la moyenne mensuelle des dépenses. Ça vaut le coup de revoir ce mois en détail pour repérer les écarts.';

  String get twoItemsDominateBudgetTitle => isEn
      ? 'Two items dominate the budget'
      : isNl
          ? 'Twee posten domineren het budget'
          : 'Deux postes dominent le budget';
  String twoItemsDominateBudgetMessage(
    String first,
    String second,
    String percent,
  ) =>
      isEn
          ? '$first and $second together represent $percent% of expenses. This is where the greatest savings potential lies.'
          : isNl
              ? '$first en $second vertegenwoordigen samen $percent% van de uitgaven. Hier ligt het grootste besparingspotentieel.'
              : '$first et $second représentent ensemble $percent % des dépenses. C’est là que le plus gros potentiel d’économie se trouve.';
}

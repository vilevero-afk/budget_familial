import 'package:flutter/material.dart';

class BudgetColumnTemplate {
  BudgetColumnTemplate({
    required this.id,
    required this.name,
  });

  final String id;
  String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory BudgetColumnTemplate.fromJson(Map<String, dynamic> json) {
    return BudgetColumnTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class BudgetSectionTemplate {
  BudgetSectionTemplate({
    required this.title,
    required this.color,
    List<BudgetColumnTemplate>? columns,
  }) : columns = columns ?? [];

  final String title;
  final Color color;
  final List<BudgetColumnTemplate> columns;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.toARGB32(),
      'columns': columns.map((e) => e.toJson()).toList(),
    };
  }

  factory BudgetSectionTemplate.fromJson(Map<String, dynamic> json) {
    return BudgetSectionTemplate(
      title: json['title'] as String,
      color: Color(json['color'] as int),
      columns: (json['columns'] as List<dynamic>? ?? [])
          .map((e) => BudgetColumnTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseEntry {
  ExpenseEntry({
    required this.id,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  double amount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) {
    return ExpenseEntry(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ExpenseSubCategoryTemplate {
  ExpenseSubCategoryTemplate({
    required this.id,
    required this.name,
  });

  final String id;
  String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory ExpenseSubCategoryTemplate.fromJson(Map<String, dynamic> json) {
    return ExpenseSubCategoryTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class ExpenseCategoryTemplate {
  ExpenseCategoryTemplate({
    required this.id,
    required this.name,
    List<ExpenseSubCategoryTemplate>? subCategories,
  }) : subCategories = subCategories ?? [];

  final String id;
  String name;
  final List<ExpenseSubCategoryTemplate> subCategories;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  factory ExpenseCategoryTemplate.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      subCategories: (json['subCategories'] as List<dynamic>? ?? [])
          .map(
            (e) => ExpenseSubCategoryTemplate.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class ExpenseSectionTemplate {
  ExpenseSectionTemplate({
    required this.title,
    required this.color,
    List<ExpenseCategoryTemplate>? categories,
  }) : categories = categories ?? [];

  final String title;
  final Color color;
  final List<ExpenseCategoryTemplate> categories;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.toARGB32(),
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  factory ExpenseSectionTemplate.fromJson(Map<String, dynamic> json) {
    return ExpenseSectionTemplate(
      title: json['title'] as String,
      color: Color(json['color'] as int),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map(
            (e) => ExpenseCategoryTemplate.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class PeriodBudgetData {
  PeriodBudgetData({
    required this.periodKey,
    Map<String, double>? incomeAmounts,
    Map<String, double>? savingAmounts,
    Map<String, List<ExpenseEntry>>? expenseEntriesBySubCategoryId,
  })  : incomeAmounts = incomeAmounts ?? {},
        savingAmounts = savingAmounts ?? {},
        expenseEntriesBySubCategoryId = expenseEntriesBySubCategoryId ?? {};

  final String periodKey;
  final Map<String, double> incomeAmounts;
  final Map<String, double> savingAmounts;
  final Map<String, List<ExpenseEntry>> expenseEntriesBySubCategoryId;

  double getIncomeAmount(String columnId) {
    return incomeAmounts[columnId] ?? 0;
  }

  double getSavingAmount(String columnId) {
    return savingAmounts[columnId] ?? 0;
  }

  List<ExpenseEntry> getExpenseEntries(String subCategoryId) {
    return expenseEntriesBySubCategoryId[subCategoryId] ?? [];
  }

  double getExpenseSubCategoryTotal(String subCategoryId) {
    return getExpenseEntries(
      subCategoryId,
    ).fold(0, (sum, item) => sum + item.amount);
  }

  int getExpenseSubCategoryEntryCount(String subCategoryId) {
    return getExpenseEntries(subCategoryId).length;
  }

  void setIncomeAmount(String columnId, double amount) {
    incomeAmounts[columnId] = amount;
  }

  void setSavingAmount(String columnId, double amount) {
    savingAmounts[columnId] = amount;
  }

  void addExpenseEntry(String subCategoryId, ExpenseEntry entry) {
    final entries = expenseEntriesBySubCategoryId.putIfAbsent(
      subCategoryId,
          () => [],
    );
    entries.add(entry);
  }

  void removeExpenseEntry(String subCategoryId, String entryId) {
    final entries = expenseEntriesBySubCategoryId[subCategoryId];
    if (entries == null) return;
    entries.removeWhere((item) => item.id == entryId);
  }

  void clearExpenseSubCategory(String subCategoryId) {
    expenseEntriesBySubCategoryId.remove(subCategoryId);
  }

  Map<String, dynamic> toJson() {
    return {
      'periodKey': periodKey,
      'incomeAmounts': incomeAmounts,
      'savingAmounts': savingAmounts,
      'expenseEntriesBySubCategoryId': expenseEntriesBySubCategoryId.map(
            (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
    };
  }

  factory PeriodBudgetData.fromJson(Map<String, dynamic> json) {
    final incomeRaw = json['incomeAmounts'] as Map<String, dynamic>? ?? {};
    final savingRaw = json['savingAmounts'] as Map<String, dynamic>? ?? {};
    final expenseRaw =
        json['expenseEntriesBySubCategoryId'] as Map<String, dynamic>? ?? {};

    return PeriodBudgetData(
      periodKey: json['periodKey'] as String,
      incomeAmounts: incomeRaw.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      savingAmounts: savingRaw.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      expenseEntriesBySubCategoryId: expenseRaw.map(
            (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => ExpenseEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
    );
  }
}

class ExpenseRowData {
  ExpenseRowData({
    required this.periodKey,
    required this.categoryName,
    required this.subCategoryName,
    required this.amount,
    required this.createdAt,
    required this.subCategoryId,
    required this.entryId,
  });

  final String periodKey;
  final String categoryName;
  final String subCategoryName;
  final double amount;
  final DateTime createdAt;
  final String subCategoryId;
  final String entryId;
}

class PeriodComparisonData {
  PeriodComparisonData({
    required this.currentPeriodKey,
    required this.previousPeriodKey,
    required this.currentValue,
    required this.previousValue,
  });

  final String currentPeriodKey;
  final String? previousPeriodKey;
  final double currentValue;
  final double previousValue;

  double get difference => currentValue - previousValue;

  double get percentChange {
    if (previousValue == 0) {
      return currentValue == 0 ? 0 : 100;
    }
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  bool get hasPreviousData => previousPeriodKey != null;

  bool get isIncrease => difference > 0;
  bool get isDecrease => difference < 0;
  bool get isStable => difference == 0;
}

class ExpenseSubCategoryInsight {
  ExpenseSubCategoryInsight({
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.currentAmount,
    required this.previousAmount,
    required this.entryCount,
  });

  final String categoryId;
  final String categoryName;
  final String subCategoryId;
  final String subCategoryName;
  final double currentAmount;
  final double previousAmount;
  final int entryCount;

  double get difference => currentAmount - previousAmount;

  double get percentChange {
    if (previousAmount == 0) {
      return currentAmount == 0 ? 0 : 100;
    }
    return ((currentAmount - previousAmount) / previousAmount) * 100;
  }

  bool get isIncrease => difference > 0;
  bool get isDecrease => difference < 0;
  bool get isStable => difference == 0;
}

class BudgetAlertData {
  BudgetAlertData({
    required this.title,
    required this.message,
    required this.level,
    this.categoryName,
    this.subCategoryName,
    this.amount,
    this.deltaAmount,
    this.deltaPercent,
  });

  final String title;
  final String message;
  final BudgetAlertLevel level;
  final String? categoryName;
  final String? subCategoryName;
  final double? amount;
  final double? deltaAmount;
  final double? deltaPercent;
}

enum BudgetAlertLevel {
  info,
  warning,
  critical,
}

class _ParsedPeriodKey {
  _ParsedPeriodKey({
    required this.year,
    required this.month,
  });

  final int year;
  final int month;
}

class AppBudgetData {
  AppBudgetData({
    required this.incomeTemplate,
    required this.expenseTemplate,
    required this.savingTemplate,
    Map<String, PeriodBudgetData>? periods,
  }) : periods = periods ?? {};

  final BudgetSectionTemplate incomeTemplate;
  final ExpenseSectionTemplate expenseTemplate;
  final BudgetSectionTemplate savingTemplate;
  final Map<String, PeriodBudgetData> periods;

  static const Map<String, int> _frenchMonthToNumber = {
    'janvier': 1,
    'février': 2,
    'fevrier': 2,
    'mars': 3,
    'avril': 4,
    'mai': 5,
    'juin': 6,
    'juillet': 7,
    'août': 8,
    'aout': 8,
    'septembre': 9,
    'octobre': 10,
    'novembre': 11,
    'décembre': 12,
    'decembre': 12,
  };

  static const Map<int, String> _numberToFrenchMonth = {
    1: 'Janvier',
    2: 'Février',
    3: 'Mars',
    4: 'Avril',
    5: 'Mai',
    6: 'Juin',
    7: 'Juillet',
    8: 'Août',
    9: 'Septembre',
    10: 'Octobre',
    11: 'Novembre',
    12: 'Décembre',
  };

  PeriodBudgetData getOrCreatePeriod(String periodKey) {
    return periods.putIfAbsent(
      periodKey,
          () => PeriodBudgetData(periodKey: periodKey),
    );
  }

  bool hasPeriod(String periodKey) {
    return periods.containsKey(periodKey);
  }

  double incomeTotalForPeriod(String periodKey) {
    final period = getOrCreatePeriod(periodKey);
    return incomeTemplate.columns.fold(
      0,
          (sum, item) => sum + period.getIncomeAmount(item.id),
    );
  }

  double savingTotalForPeriod(String periodKey) {
    final period = getOrCreatePeriod(periodKey);
    return savingTemplate.columns.fold(
      0,
          (sum, item) => sum + period.getSavingAmount(item.id),
    );
  }

  double expenseCategoryTotalForPeriod(
      String periodKey,
      ExpenseCategoryTemplate category,
      ) {
    final period = getOrCreatePeriod(periodKey);
    return category.subCategories.fold(
      0,
          (sum, item) => sum + period.getExpenseSubCategoryTotal(item.id),
    );
  }

  double expenseSubCategoryTotalForPeriod(
      String periodKey,
      String subCategoryId,
      ) {
    final period = getOrCreatePeriod(periodKey);
    return period.getExpenseSubCategoryTotal(subCategoryId);
  }

  double expenseTotalForPeriod(String periodKey) {
    final period = getOrCreatePeriod(periodKey);
    return expenseTemplate.categories.fold(
      0,
          (sum, category) =>
      sum +
          category.subCategories.fold(
            0,
                (subSum, subCategory) =>
            subSum + period.getExpenseSubCategoryTotal(subCategory.id),
          ),
    );
  }

  double balanceForPeriod(String periodKey) {
    return incomeTotalForPeriod(periodKey) -
        expenseTotalForPeriod(periodKey) -
        savingTotalForPeriod(periodKey);
  }

  List<ExpenseRowData> getExpenseRowsForPeriod(String periodKey) {
    final period = getOrCreatePeriod(periodKey);
    final List<ExpenseRowData> rows = [];

    for (final category in expenseTemplate.categories) {
      for (final subCategory in category.subCategories) {
        final entries = period.getExpenseEntries(subCategory.id);
        for (final entry in entries) {
          rows.add(
            ExpenseRowData(
              periodKey: periodKey,
              categoryName: category.name,
              subCategoryName: subCategory.name,
              amount: entry.amount,
              createdAt: entry.createdAt,
              subCategoryId: subCategory.id,
              entryId: entry.id,
            ),
          );
        }
      }
    }

    return rows;
  }

  String? previousPeriodKey(String periodKey) {
    final parsed = _parsePeriodKey(periodKey);
    if (parsed == null) return null;

    final currentDate = DateTime(parsed.year, parsed.month);
    final previousDate = DateTime(currentDate.year, currentDate.month - 1);

    return _formatPeriodKey(previousDate.year, previousDate.month);
  }

  PeriodComparisonData incomeComparisonForPeriod(String periodKey) {
    final previousKey = previousPeriodKey(periodKey);
    return PeriodComparisonData(
      currentPeriodKey: periodKey,
      previousPeriodKey: previousKey,
      currentValue: incomeTotalForPeriod(periodKey),
      previousValue:
      previousKey != null && hasPeriod(previousKey)
          ? incomeTotalForPeriod(previousKey)
          : 0,
    );
  }

  PeriodComparisonData savingComparisonForPeriod(String periodKey) {
    final previousKey = previousPeriodKey(periodKey);
    return PeriodComparisonData(
      currentPeriodKey: periodKey,
      previousPeriodKey: previousKey,
      currentValue: savingTotalForPeriod(periodKey),
      previousValue:
      previousKey != null && hasPeriod(previousKey)
          ? savingTotalForPeriod(previousKey)
          : 0,
    );
  }

  PeriodComparisonData expenseComparisonForPeriod(String periodKey) {
    final previousKey = previousPeriodKey(periodKey);
    return PeriodComparisonData(
      currentPeriodKey: periodKey,
      previousPeriodKey: previousKey,
      currentValue: expenseTotalForPeriod(periodKey),
      previousValue:
      previousKey != null && hasPeriod(previousKey)
          ? expenseTotalForPeriod(previousKey)
          : 0,
    );
  }

  PeriodComparisonData balanceComparisonForPeriod(String periodKey) {
    final previousKey = previousPeriodKey(periodKey);
    return PeriodComparisonData(
      currentPeriodKey: periodKey,
      previousPeriodKey: previousKey,
      currentValue: balanceForPeriod(periodKey),
      previousValue:
      previousKey != null && hasPeriod(previousKey)
          ? balanceForPeriod(previousKey)
          : 0,
    );
  }

  List<ExpenseSubCategoryInsight> getSubCategoryInsightsForPeriod(
      String periodKey,
      ) {
    final period = getOrCreatePeriod(periodKey);
    final previousKey = previousPeriodKey(periodKey);
    final previousPeriod =
    previousKey != null && hasPeriod(previousKey) ? periods[previousKey] : null;

    final List<ExpenseSubCategoryInsight> insights = [];

    for (final category in expenseTemplate.categories) {
      for (final subCategory in category.subCategories) {
        final currentAmount = period.getExpenseSubCategoryTotal(subCategory.id);
        final previousAmount =
            previousPeriod?.getExpenseSubCategoryTotal(subCategory.id) ?? 0;
        final entryCount = period.getExpenseSubCategoryEntryCount(subCategory.id);

        insights.add(
          ExpenseSubCategoryInsight(
            categoryId: category.id,
            categoryName: category.name,
            subCategoryId: subCategory.id,
            subCategoryName: subCategory.name,
            currentAmount: currentAmount,
            previousAmount: previousAmount,
            entryCount: entryCount,
          ),
        );
      }
    }

    return insights;
  }

  List<ExpenseSubCategoryInsight> highestExpenseSubCategoriesForPeriod(
      String periodKey, {
        int limit = 5,
        bool excludeZeroAmounts = true,
      }) {
    final items = getSubCategoryInsightsForPeriod(periodKey);

    final filtered =
    excludeZeroAmounts
        ? items.where((e) => e.currentAmount > 0).toList()
        : items;

    filtered.sort((a, b) => b.currentAmount.compareTo(a.currentAmount));

    if (filtered.length <= limit) return filtered;
    return filtered.take(limit).toList();
  }

  List<ExpenseSubCategoryInsight> mostIncreasedSubCategoriesForPeriod(
      String periodKey, {
        int limit = 5,
        double minCurrentAmount = 0,
      }) {
    final items =
    getSubCategoryInsightsForPeriod(periodKey)
        .where((e) => e.currentAmount >= minCurrentAmount)
        .toList();

    items.sort((a, b) => b.difference.compareTo(a.difference));

    final increased = items.where((e) => e.difference > 0).toList();

    if (increased.length <= limit) return increased;
    return increased.take(limit).toList();
  }

  List<BudgetAlertData> generateAlertsForPeriod(
      String periodKey, {
        double highExpenseAmountThreshold = 1000,
        double strongIncreasePercentThreshold = 30,
        double lowBalanceThreshold = 0,
      }) {
    final List<BudgetAlertData> alerts = [];

    final balance = balanceForPeriod(periodKey);
    if (balance < lowBalanceThreshold) {
      alerts.add(
        BudgetAlertData(
          title: 'Solde faible',
          message: 'Le solde du mois est négatif ou inférieur au seuil défini.',
          level: BudgetAlertLevel.critical,
          amount: balance,
        ),
      );
    }

    final insights = getSubCategoryInsightsForPeriod(periodKey);

    for (final item in insights) {
      if (item.currentAmount >= highExpenseAmountThreshold) {
        alerts.add(
          BudgetAlertData(
            title: 'Dépense élevée',
            message:
            '${item.subCategoryName} atteint ${item.currentAmount.toStringAsFixed(2)} € sur la période.',
            level: BudgetAlertLevel.warning,
            categoryName: item.categoryName,
            subCategoryName: item.subCategoryName,
            amount: item.currentAmount,
          ),
        );
      }

      if (item.previousAmount > 0 &&
          item.percentChange >= strongIncreasePercentThreshold) {
        alerts.add(
          BudgetAlertData(
            title: 'Hausse importante',
            message:
            '${item.subCategoryName} augmente de ${item.percentChange.toStringAsFixed(1)} % par rapport au mois précédent.',
            level: BudgetAlertLevel.warning,
            categoryName: item.categoryName,
            subCategoryName: item.subCategoryName,
            amount: item.currentAmount,
            deltaAmount: item.difference,
            deltaPercent: item.percentChange,
          ),
        );
      }
    }

    alerts.sort((a, b) {
      final levelOrder = {
        BudgetAlertLevel.critical: 3,
        BudgetAlertLevel.warning: 2,
        BudgetAlertLevel.info: 1,
      };
      return (levelOrder[b.level] ?? 0).compareTo(levelOrder[a.level] ?? 0);
    });

    return alerts;
  }

  Map<String, dynamic> toJson() {
    return {
      'incomeTemplate': incomeTemplate.toJson(),
      'expenseTemplate': expenseTemplate.toJson(),
      'savingTemplate': savingTemplate.toJson(),
      'periods': periods.map(
            (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory AppBudgetData.fromJson(Map<String, dynamic> json) {
    final periodsRaw = json['periods'] as Map<String, dynamic>? ?? {};

    return AppBudgetData(
      incomeTemplate: BudgetSectionTemplate.fromJson(
        json['incomeTemplate'] as Map<String, dynamic>,
      ),
      expenseTemplate: ExpenseSectionTemplate.fromJson(
        json['expenseTemplate'] as Map<String, dynamic>,
      ),
      savingTemplate: BudgetSectionTemplate.fromJson(
        json['savingTemplate'] as Map<String, dynamic>,
      ),
      periods: periodsRaw.map(
            (key, value) => MapEntry(
          key,
          PeriodBudgetData.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  _ParsedPeriodKey? _parsePeriodKey(String periodKey) {
    final parts = periodKey.split('-');
    if (parts.length != 2) return null;

    final year = int.tryParse(parts[0].trim());
    final monthRaw = parts[1].trim().toLowerCase();

    if (year == null) return null;

    final month = _frenchMonthToNumber[monthRaw];
    if (month == null) return null;

    return _ParsedPeriodKey(year: year, month: month);
  }

  String _formatPeriodKey(int year, int month) {
    final monthName = _numberToFrenchMonth[month] ?? 'Janvier';
    return '$year-$monthName';
  }
}
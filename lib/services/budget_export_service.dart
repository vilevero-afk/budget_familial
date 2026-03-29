import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/budget_models.dart';

class BudgetExportService {
  static const List<String> _monthOrder = <String>[
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  Future<File> exportPeriodToExcel({
    required AppBudgetData appBudget,
    required String periodKey,
  }) async {
    final excel = Excel.createExcel();

    final expenseRows = appBudget.getExpenseRowsForPeriod(periodKey).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final previousPeriodKey = _getPreviousPeriodKey(periodKey);
    final previousExpenseRows = previousPeriodKey == null
        ? <ExpenseRowData>[]
        : (appBudget.getExpenseRowsForPeriod(previousPeriodKey).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

    _buildSummarySheet(
      excel: excel,
      appBudget: appBudget,
      periodKey: periodKey,
      expenseRows: expenseRows,
      previousPeriodKey: previousPeriodKey,
      previousExpenseRows: previousExpenseRows,
    );

    _buildAnalysisSheet(
      excel: excel,
      appBudget: appBudget,
      periodKey: periodKey,
      expenseRows: expenseRows,
      previousPeriodKey: previousPeriodKey,
      previousExpenseRows: previousExpenseRows,
    );

    _buildExpensesSheet(
      excel: excel,
      expenseRows: expenseRows,
    );

    _buildCategoriesSheet(
      excel: excel,
      expenseRows: expenseRows,
    );

    _buildSubCategoriesSheet(
      excel: excel,
      expenseRows: expenseRows,
    );

    excel.setDefaultSheet('Résumé');

    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null &&
        defaultSheet != 'Résumé' &&
        defaultSheet != 'Analyse' &&
        defaultSheet != 'Dépenses' &&
        defaultSheet != 'Catégories' &&
        defaultSheet != 'Sous-catégories') {
      excel.delete(defaultSheet);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Impossible de générer le fichier Excel.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final safePeriodKey = _sanitizeFileName(periodKey);
    final file = File('${directory.path}/budget_$safePeriodKey.xlsx');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _buildSummarySheet({
    required Excel excel,
    required AppBudgetData appBudget,
    required String periodKey,
    required List<ExpenseRowData> expenseRows,
    required String? previousPeriodKey,
    required List<ExpenseRowData> previousExpenseRows,
  }) {
    final sheet = excel['Résumé'];
    _configureSummarySheet(sheet);

    final income = appBudget.incomeTotalForPeriod(periodKey);
    final expenses = appBudget.expenseTotalForPeriod(periodKey);
    final savings = appBudget.savingTotalForPeriod(periodKey);
    final balance = appBudget.balanceForPeriod(periodKey);
    final operations = expenseRows.length;
    final averageExpense = operations > 0 ? expenses / operations : 0.0;
    final savingsRate = income > 0 ? (savings / income) * 100 : 0.0;
    final expenseRate = income > 0 ? (expenses / income) * 100 : 0.0;

    final previousKey = previousPeriodKey;
    final hasPreviousData = previousKey != null &&
        (appBudget.incomeTotalForPeriod(previousKey) != 0 ||
            appBudget.expenseTotalForPeriod(previousKey) != 0 ||
            appBudget.savingTotalForPeriod(previousKey) != 0 ||
            previousExpenseRows.isNotEmpty);

    final previousIncome =
        hasPreviousData ? appBudget.incomeTotalForPeriod(previousKey) : 0.0;
    final previousExpenses =
        hasPreviousData ? appBudget.expenseTotalForPeriod(previousKey) : 0.0;
    final previousSavings =
        hasPreviousData ? appBudget.savingTotalForPeriod(previousKey) : 0.0;
    final previousBalance =
        hasPreviousData ? appBudget.balanceForPeriod(previousKey) : 0.0;
    final previousOperations = hasPreviousData ? previousExpenseRows.length : 0;

    _appendStyledRow(
      sheet,
      [TextCellValue('Budget Familial')],
      styles: [_titleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: 0,
      endColumn: 3,
      endRow: 0,
      style: _titleStyle(),
    );

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Période'),
        TextCellValue(periodKey),
      ],
      styles: [_labelStyle(), _valueTextStyle()],
    );

    if (previousPeriodKey != null) {
      _appendStyledRow(
        sheet,
        [
          TextCellValue('Période précédente'),
          TextCellValue(previousPeriodKey),
        ],
        styles: [_labelStyle(), _valueTextStyle()],
      );
    }

    _appendEmptyRow(sheet, 4);

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Indicateur'),
        TextCellValue('Valeur actuelle'),
        TextCellValue('Valeur précédente'),
        TextCellValue('Écart'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Rentrées',
      currentValue: income,
      previousValue: hasPreviousData ? previousIncome : null,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Dépenses',
      currentValue: expenses,
      previousValue: hasPreviousData ? previousExpenses : null,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Économies',
      currentValue: savings,
      previousValue: hasPreviousData ? previousSavings : null,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Solde',
      currentValue: balance,
      previousValue: hasPreviousData ? previousBalance : null,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Nombre d’opérations',
      currentValue: operations.toDouble(),
      previousValue: hasPreviousData ? previousOperations.toDouble() : null,
      asInteger: true,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Montant moyen par opération',
      currentValue: averageExpense,
      previousValue: hasPreviousData && previousOperations > 0
          ? previousExpenses / previousOperations
          : hasPreviousData
              ? 0.0
              : null,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Taux d’épargne (%)',
      currentValue: savingsRate,
      previousValue: hasPreviousData && previousIncome > 0
          ? (previousSavings / previousIncome) * 100
          : hasPreviousData
              ? 0.0
              : null,
      asPercent: true,
    );

    _appendComparisonRow(
      sheet: sheet,
      label: 'Taux de dépense (%)',
      currentValue: expenseRate,
      previousValue: hasPreviousData && previousIncome > 0
          ? (previousExpenses / previousIncome) * 100
          : hasPreviousData
              ? 0.0
              : null,
      asPercent: true,
    );
  }

  void _buildAnalysisSheet({
    required Excel excel,
    required AppBudgetData appBudget,
    required String periodKey,
    required List<ExpenseRowData> expenseRows,
    required String? previousPeriodKey,
    required List<ExpenseRowData> previousExpenseRows,
  }) {
    final sheet = excel['Analyse'];
    _configureAnalysisSheet(sheet);

    final categoryTotals = _buildCategoryTotals(expenseRows);
    final previousCategoryTotals = _buildCategoryTotals(previousExpenseRows);

    final subCategoryStats = _buildSubCategoryStats(expenseRows);
    final previousSubCategoryStats =
        _buildSubCategoryStats(previousExpenseRows);

    final currentExpenses = appBudget.expenseTotalForPeriod(periodKey);
    final previousExpenses = previousPeriodKey == null
        ? null
        : appBudget.expenseTotalForPeriod(previousPeriodKey);

    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSubCategories = subCategoryStats.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    _appendStyledRow(
      sheet,
      [TextCellValue('Analyse du budget')],
      styles: [_titleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: 0,
      endColumn: 5,
      endRow: 0,
      style: _titleStyle(),
    );

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Période'),
        TextCellValue(periodKey),
      ],
      styles: [_labelStyle(), _valueTextStyle()],
    );

    if (previousPeriodKey != null) {
      _appendStyledRow(
        sheet,
        [
          TextCellValue('Comparée à'),
          TextCellValue(previousPeriodKey),
        ],
        styles: [_labelStyle(), _valueTextStyle()],
      );
    }

    _appendEmptyRow(sheet, 6);

    _appendStyledRow(
      sheet,
      [TextCellValue('Synthèse')],
      styles: [_sectionTitleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: sheet.maxRows - 1,
      endColumn: 4,
      endRow: sheet.maxRows - 1,
      style: _sectionTitleStyle(),
    );

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Indicateur'),
        TextCellValue('Valeur'),
        TextCellValue('Référence'),
        TextCellValue('Écart'),
        TextCellValue('Variation %'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    _appendAnalysisMetricRow(
      sheet: sheet,
      label: 'Dépenses totales',
      currentValue: currentExpenses,
      previousValue: previousExpenses,
    );

    _appendEmptyRow(sheet, 6);

    _appendStyledRow(
      sheet,
      [TextCellValue('Top catégories')],
      styles: [_sectionTitleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: sheet.maxRows - 1,
      endColumn: 4,
      endRow: sheet.maxRows - 1,
      style: _sectionTitleStyle(),
    );

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Rang'),
        TextCellValue('Catégorie'),
        TextCellValue('Total'),
        TextCellValue('Poids dans les dépenses (%)'),
        TextCellValue('Écart vs période précédente'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    if (topCategories.isEmpty) {
      _appendStyledRow(
        sheet,
        [
          TextCellValue('-'),
          TextCellValue('Aucune dépense sur la période'),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
        ],
        styles: [
          _valueTextCenteredStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
        ],
      );
    } else {
      for (var i = 0; i < topCategories.length; i++) {
        final entry = topCategories[i];
        final previousTotal = previousCategoryTotals[entry.key];
        final weight =
            currentExpenses > 0 ? (entry.value / currentExpenses) * 100 : 0.0;
        final delta =
            previousTotal == null ? null : entry.value - previousTotal;

        _appendStyledRow(
          sheet,
          [
            IntCellValue(i + 1),
            TextCellValue(entry.key),
            DoubleCellValue(entry.value),
            DoubleCellValue(weight),
            delta == null ? TextCellValue('N/A') : DoubleCellValue(delta),
          ],
          styles: [
            _integerStyle(),
            _valueTextStyle(),
            _currencyStyle(),
            _percentStyle(),
            delta == null ? _naStyle() : _deltaCurrencyStyle(delta),
          ],
        );
      }
    }

    _appendEmptyRow(sheet, 6);

    _appendStyledRow(
      sheet,
      [TextCellValue('Top sous-catégories')],
      styles: [_sectionTitleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: sheet.maxRows - 1,
      endColumn: 5,
      endRow: sheet.maxRows - 1,
      style: _sectionTitleStyle(),
    );

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Rang'),
        TextCellValue('Catégorie'),
        TextCellValue('Sous-catégorie'),
        TextCellValue('Total'),
        TextCellValue('Nb opérations'),
        TextCellValue('Écart vs période précédente'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    if (topSubCategories.isEmpty) {
      _appendStyledRow(
        sheet,
        [
          TextCellValue('-'),
          TextCellValue('Aucune dépense sur la période'),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
        ],
        styles: [
          _valueTextCenteredStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
        ],
      );
    } else {
      for (var i = 0; i < topSubCategories.length; i++) {
        final stat = topSubCategories[i];
        final previousKey = '${stat.categoryName}|||${stat.subCategoryName}';
        final previousStat = previousSubCategoryStats[previousKey];
        final delta =
            previousStat == null ? null : stat.total - previousStat.total;

        _appendStyledRow(
          sheet,
          [
            IntCellValue(i + 1),
            TextCellValue(stat.categoryName),
            TextCellValue(stat.subCategoryName),
            DoubleCellValue(stat.total),
            IntCellValue(stat.count),
            delta == null ? TextCellValue('N/A') : DoubleCellValue(delta),
          ],
          styles: [
            _integerStyle(),
            _valueTextStyle(),
            _valueTextStyle(),
            _currencyStyle(),
            _integerStyle(),
            delta == null ? _naStyle() : _deltaCurrencyStyle(delta),
          ],
        );
      }
    }
  }

  void _buildExpensesSheet({
    required Excel excel,
    required List<ExpenseRowData> expenseRows,
  }) {
    final sheet = excel['Dépenses'];
    _configureExpensesSheet(sheet);

    _appendStyledRow(
      sheet,
      [TextCellValue('Détail des dépenses')],
      styles: [_titleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: 0,
      endColumn: 3,
      endRow: 0,
      style: _titleStyle(),
    );

    _appendEmptyRow(sheet, 4);

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Date'),
        TextCellValue('Catégorie'),
        TextCellValue('Sous-catégorie'),
        TextCellValue('Montant'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    for (final row in expenseRows) {
      _appendStyledRow(
        sheet,
        [
          TextCellValue(_formatDate(row.createdAt)),
          TextCellValue(row.categoryName),
          TextCellValue(row.subCategoryName),
          DoubleCellValue(row.amount),
        ],
        styles: [
          _dateStyle(),
          _valueTextStyle(),
          _valueTextStyle(),
          _currencyStyle(),
        ],
      );
    }

    _appendStyledRow(
      sheet,
      [
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('Total'),
        DoubleCellValue(
          expenseRows.fold<double>(0, (sum, row) => sum + row.amount),
        ),
      ],
      styles: [
        _totalStyle(),
        _totalStyle(),
        _totalStyle(),
        _totalCurrencyStyle(),
      ],
    );
  }

  void _buildCategoriesSheet({
    required Excel excel,
    required List<ExpenseRowData> expenseRows,
  }) {
    final sheet = excel['Catégories'];
    _configureCategoriesSheet(sheet);

    final totalsByCategory = _buildCategoryTotals(expenseRows);

    final sortedEntries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpenses =
        sortedEntries.fold<double>(0, (sum, entry) => sum + entry.value);

    _appendStyledRow(
      sheet,
      [TextCellValue('Répartition par catégorie')],
      styles: [_titleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: 0,
      endColumn: 2,
      endRow: 0,
      style: _titleStyle(),
    );

    _appendEmptyRow(sheet, 3);

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Catégorie'),
        TextCellValue('Total'),
        TextCellValue('Poids dans les dépenses (%)'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    for (final entry in sortedEntries) {
      final weight =
          totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;

      _appendStyledRow(
        sheet,
        [
          TextCellValue(entry.key),
          DoubleCellValue(entry.value),
          DoubleCellValue(weight),
        ],
        styles: [
          _valueTextStyle(),
          _currencyStyle(),
          _percentStyle(),
        ],
      );
    }

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Total'),
        DoubleCellValue(totalExpenses),
        const DoubleCellValue(100),
      ],
      styles: [
        _totalStyle(),
        _totalCurrencyStyle(),
        _totalPercentStyle(),
      ],
    );
  }

  void _buildSubCategoriesSheet({
    required Excel excel,
    required List<ExpenseRowData> expenseRows,
  }) {
    final sheet = excel['Sous-catégories'];
    _configureSubCategoriesSheet(sheet);

    final statsBySubCategory = _buildSubCategoryStats(expenseRows);

    final sortedStats = statsBySubCategory.values.toList()
      ..sort((a, b) {
        final categoryCompare = a.categoryName.compareTo(b.categoryName);
        if (categoryCompare != 0) return categoryCompare;
        return b.total.compareTo(a.total);
      });

    final totalExpenses =
        sortedStats.fold<double>(0, (sum, stat) => sum + stat.total);

    _appendStyledRow(
      sheet,
      [TextCellValue('Répartition par sous-catégorie')],
      styles: [_titleStyle()],
    );
    _mergeAndRestyle(
      sheet: sheet,
      startColumn: 0,
      startRow: 0,
      endColumn: 4,
      endRow: 0,
      style: _titleStyle(),
    );

    _appendEmptyRow(sheet, 5);

    _appendStyledRow(
      sheet,
      [
        TextCellValue('Catégorie'),
        TextCellValue('Sous-catégorie'),
        TextCellValue('Nb opérations'),
        TextCellValue('Total'),
        TextCellValue('Poids dans les dépenses (%)'),
      ],
      styles: [
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
        _headerStyle(),
      ],
    );

    for (final stat in sortedStats) {
      final weight =
          totalExpenses > 0 ? (stat.total / totalExpenses) * 100 : 0.0;

      _appendStyledRow(
        sheet,
        [
          TextCellValue(stat.categoryName),
          TextCellValue(stat.subCategoryName),
          IntCellValue(stat.count),
          DoubleCellValue(stat.total),
          DoubleCellValue(weight),
        ],
        styles: [
          _valueTextStyle(),
          _valueTextStyle(),
          _integerStyle(),
          _currencyStyle(),
          _percentStyle(),
        ],
      );
    }

    _appendStyledRow(
      sheet,
      [
        TextCellValue(''),
        TextCellValue('Total'),
        IntCellValue(sortedStats.fold<int>(0, (sum, stat) => sum + stat.count)),
        DoubleCellValue(totalExpenses),
        const DoubleCellValue(100),
      ],
      styles: [
        _totalStyle(),
        _totalStyle(),
        _totalIntegerStyle(),
        _totalCurrencyStyle(),
        _totalPercentStyle(),
      ],
    );
  }

  void _appendComparisonRow({
    required Sheet sheet,
    required String label,
    required double currentValue,
    required double? previousValue,
    bool asInteger = false,
    bool asPercent = false,
  }) {
    final delta = previousValue == null ? null : currentValue - previousValue;

    _appendStyledRow(
      sheet,
      [
        TextCellValue(label),
        asInteger
            ? IntCellValue(currentValue.round())
            : DoubleCellValue(currentValue),
        previousValue == null
            ? TextCellValue('N/A')
            : asInteger
                ? IntCellValue(previousValue.round())
                : DoubleCellValue(previousValue),
        delta == null
            ? TextCellValue('N/A')
            : asInteger
                ? IntCellValue(delta.round())
                : DoubleCellValue(delta),
      ],
      styles: [
        _labelStyle(),
        asInteger
            ? _integerStyle()
            : asPercent
                ? _percentStyle()
                : _currencyStyle(),
        previousValue == null
            ? _naStyle()
            : asInteger
                ? _integerStyle()
                : asPercent
                    ? _percentStyle()
                    : _currencyStyle(),
        delta == null
            ? _naStyle()
            : asInteger
                ? _deltaIntegerStyle(delta)
                : asPercent
                    ? _deltaPercentStyle(delta)
                    : _deltaCurrencyStyle(delta),
      ],
    );
  }

  void _appendAnalysisMetricRow({
    required Sheet sheet,
    required String label,
    required double currentValue,
    required double? previousValue,
  }) {
    final delta = previousValue == null ? null : currentValue - previousValue;
    final variationPercent = previousValue == null || previousValue == 0
        ? null
        : (delta! / previousValue) * 100;

    _appendStyledRow(
      sheet,
      [
        TextCellValue(label),
        DoubleCellValue(currentValue),
        previousValue == null
            ? TextCellValue('N/A')
            : DoubleCellValue(previousValue),
        delta == null ? TextCellValue('N/A') : DoubleCellValue(delta),
        variationPercent == null
            ? TextCellValue('N/A')
            : DoubleCellValue(variationPercent),
      ],
      styles: [
        _labelStyle(),
        _currencyStyle(),
        previousValue == null ? _naStyle() : _currencyStyle(),
        delta == null ? _naStyle() : _deltaCurrencyStyle(delta),
        variationPercent == null
            ? _naStyle()
            : _deltaPercentStyle(variationPercent),
      ],
    );
  }

  Map<String, double> _buildCategoryTotals(List<ExpenseRowData> expenseRows) {
    final totalsByCategory = <String, double>{};

    for (final row in expenseRows) {
      totalsByCategory.update(
        row.categoryName,
        (value) => value + row.amount,
        ifAbsent: () => row.amount,
      );
    }

    return totalsByCategory;
  }

  Map<String, _SubCategoryExportStat> _buildSubCategoryStats(
    List<ExpenseRowData> expenseRows,
  ) {
    final statsBySubCategory = <String, _SubCategoryExportStat>{};

    for (final row in expenseRows) {
      final key = '${row.categoryName}|||${row.subCategoryName}';
      final existing = statsBySubCategory[key];

      if (existing == null) {
        statsBySubCategory[key] = _SubCategoryExportStat(
          categoryName: row.categoryName,
          subCategoryName: row.subCategoryName,
          total: row.amount,
          count: 1,
        );
      } else {
        existing.total += row.amount;
        existing.count += 1;
      }
    }

    return statsBySubCategory;
  }

  String? _getPreviousPeriodKey(String periodKey) {
    final separatorIndex = periodKey.indexOf('-');
    if (separatorIndex <= 0 || separatorIndex >= periodKey.length - 1) {
      return null;
    }

    final yearPart = periodKey.substring(0, separatorIndex).trim();
    final monthPart = periodKey.substring(separatorIndex + 1).trim();

    final year = int.tryParse(yearPart);
    if (year == null) {
      return null;
    }

    final monthIndex = _monthOrder.indexOf(monthPart);
    if (monthIndex == -1) {
      return null;
    }

    if (monthIndex == 0) {
      return '${year - 1}-${_monthOrder.last}';
    }

    return '$year-${_monthOrder[monthIndex - 1]}';
  }

  void _appendStyledRow(
    Sheet sheet,
    List<CellValue> values, {
    List<CellStyle?>? styles,
  }) {
    sheet.appendRow(values);

    final rowIndex = sheet.maxRows - 1;
    for (var col = 0; col < values.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      final style = styles != null && col < styles.length ? styles[col] : null;
      if (style != null) {
        cell.cellStyle = style;
      }
    }
  }

  void _appendEmptyRow(Sheet sheet, int columnCount) {
    _appendStyledRow(
      sheet,
      List<CellValue>.generate(columnCount, (_) => TextCellValue('')),
    );
  }

  void _mergeAndRestyle({
    required Sheet sheet,
    required int startColumn,
    required int startRow,
    required int endColumn,
    required int endRow,
    required CellStyle style,
  }) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: startColumn, rowIndex: startRow),
      CellIndex.indexByColumnRow(columnIndex: endColumn, rowIndex: endRow),
    );

    final mergedCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: startColumn, rowIndex: startRow),
    );
    mergedCell.cellStyle = style;
  }

  void _configureSummarySheet(Sheet sheet) {
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 18);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 18);
  }

  void _configureAnalysisSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 26);
    sheet.setColumnWidth(2, 24);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 22);
    sheet.setColumnWidth(5, 22);
  }

  void _configureExpensesSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 14);
    sheet.setColumnWidth(1, 24);
    sheet.setColumnWidth(2, 24);
    sheet.setColumnWidth(3, 16);
  }

  void _configureCategoriesSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 16);
    sheet.setColumnWidth(2, 24);
  }

  void _configureSubCategoriesSheet(Sheet sheet) {
    sheet.setColumnWidth(0, 24);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 16);
    sheet.setColumnWidth(3, 16);
    sheet.setColumnWidth(4, 24);
  }

  ExcelColor _color(String hex) {
    return ExcelColor.fromHexString(hex);
  }

  Border _border(String hex, {BorderStyle style = BorderStyle.Thin}) {
    return Border(
      borderStyle: style,
      borderColorHex: _color(hex),
    );
  }

  CellStyle _titleStyle() {
    return CellStyle(
      bold: true,
      fontSize: 16,
      fontColorHex: _color('#FFFFFF'),
      backgroundColorHex: _color('#4F46E5'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FF4F46E5'),
      rightBorder: _border('FF4F46E5'),
      topBorder: _border('FF4F46E5'),
      bottomBorder: _border('FF4F46E5'),
    );
  }

  CellStyle _sectionTitleStyle() {
    return CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: _color('#111827'),
      backgroundColorHex: _color('#E0EAFF'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _headerStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#101828'),
      backgroundColorHex: _color('#EAF2FF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _labelStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#344054'),
      backgroundColorHex: _color('#F8FAFC'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _valueTextStyle() {
    return CellStyle(
      fontColorHex: _color('#101828'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _valueTextCenteredStyle() {
    return CellStyle(
      fontColorHex: _color('#101828'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _dateStyle() {
    return CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _currencyStyle() {
    return CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _integerStyle() {
    return CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _percentStyle() {
    return CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _naStyle() {
    return CellStyle(
      italic: true,
      fontColorHex: _color('#667085'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _totalStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#101828'),
      backgroundColorHex: _color('#EEF2F6'),
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _totalCurrencyStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#101828'),
      backgroundColorHex: _color('#EEF2F6'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _totalIntegerStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#101828'),
      backgroundColorHex: _color('#EEF2F6'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _totalPercentStyle() {
    return CellStyle(
      bold: true,
      fontColorHex: _color('#101828'),
      backgroundColorHex: _color('#EEF2F6'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _deltaCurrencyStyle(double delta) {
    return CellStyle(
      bold: true,
      fontColorHex: _color(delta >= 0 ? '#B42318' : '#027A48'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _deltaIntegerStyle(double delta) {
    return CellStyle(
      bold: true,
      fontColorHex: _color(delta >= 0 ? '#B42318' : '#027A48'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  CellStyle _deltaPercentStyle(double delta) {
    return CellStyle(
      bold: true,
      fontColorHex: _color(delta >= 0 ? '#B42318' : '#027A48'),
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: const CustomNumericNumFormat(formatCode: '#,##0.00'),
      leftBorder: _border('FFD0D5DD'),
      rightBorder: _border('FFD0D5DD'),
      topBorder: _border('FFD0D5DD'),
      bottomBorder: _border('FFD0D5DD'),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _sanitizeFileName(String input) {
    final normalized = input
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ç', 'c')
        .replaceAll('/', '-')
        .replaceAll('\\', '-')
        .replaceAll(':', '-')
        .replaceAll('*', '-')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '-');

    return normalized.isEmpty ? 'export' : normalized;
  }
}

class _SubCategoryExportStat {
  _SubCategoryExportStat({
    required this.categoryName,
    required this.subCategoryName,
    required this.total,
    required this.count,
  });

  final String categoryName;
  final String subCategoryName;
  double total;
  int count;
}

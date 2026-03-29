import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/budget_models.dart';

class BudgetSectionCard extends StatelessWidget {
  const BudgetSectionCard({
    super.key,
    required this.section,
    required this.periodKey,
    required this.amountProvider,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onAddColumn,
    required this.onRenameColumn,
    required this.onAmountChanged,
    required this.onDeleteColumn,
  });

  final BudgetSectionTemplate section;
  final String periodKey;
  final double Function(BudgetColumnTemplate column) amountProvider;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onAddColumn;
  final void Function(BudgetColumnTemplate column) onRenameColumn;
  final void Function(BudgetColumnTemplate column, String value)
      onAmountChanged;
  final void Function(BudgetColumnTemplate column) onDeleteColumn;

  Color _softColor(Color color) => color.withValues(alpha: 0.10);
  Color _borderColor(Color color) => color.withValues(alpha: 0.18);

  String _localizedSectionTitle(AppLocalizations l10n) {
    switch (section.title.trim().toLowerCase()) {
      case 'rentrées':
      case 'rentrees':
      case 'income':
        return l10n.dashboardIncome;
      case 'économies':
      case 'economies':
      case 'savings':
        return l10n.dashboardSavings;
      case 'dépenses':
      case 'depenses':
      case 'expenses':
        return l10n.dashboardExpenses;
      default:
        return section.title;
    }
  }

  String _formatAmount(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final total = section.columns.fold<double>(
      0.0,
      (sum, item) => sum + amountProvider(item),
    );

    final localizedTitle = _localizedSectionTitle(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFAFBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE3E8F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onToggleExpanded,
                  borderRadius: BorderRadius.circular(18),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _softColor(section.color),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.keyboard_arrow_right_rounded,
                                    color: section.color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    localizedTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _softColor(section.color),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _borderColor(section.color),
                                    ),
                                  ),
                                  child: Text(
                                    _formatAmount(total),
                                    style: TextStyle(
                                      color: section.color,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: onAddColumn,
                                  icon: const Icon(Icons.add_rounded),
                                  label: Text(l10n.commonAdd),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _softColor(section.color),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_right_rounded,
                                color: section.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizedTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _softColor(section.color),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _borderColor(section.color),
                                ),
                              ),
                              child: Text(
                                _formatAmount(total),
                                style: TextStyle(
                                  color: section.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: onAddColumn,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(l10n.commonAdd),
                            ),
                          ],
                        ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        if (section.columns.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFFE5EAF3)),
                            ),
                            child: Text(
                              l10n.budgetSectionEmpty,
                              style: const TextStyle(color: Color(0xFF667085)),
                            ),
                          ),
                        ...section.columns.map((column) {
                          final amount = amountProvider(column);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(isCompact ? 10 : 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFFE6EBF3)),
                            ),
                            child: isCompact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      InkWell(
                                        onTap: () => onRenameColumn(column),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: const Color(0xFFE1E7F0),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                margin: const EdgeInsets.only(
                                                  top: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: section.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  column.name,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: Color(0xFF667085),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        key: ValueKey(
                                          '$periodKey-${section.title}-${column.id}',
                                        ),
                                        initialValue: amount == 0
                                            ? ''
                                            : amount.toStringAsFixed(2),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: l10n.dashboardAmountLabel,
                                          prefixText: '€ ',
                                          suffixIcon: Icon(
                                            Icons.euro_rounded,
                                            color: section.color,
                                          ),
                                        ),
                                        onChanged: (value) =>
                                            onAmountChanged(column, value),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () =>
                                              onDeleteColumn(column),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: InkWell(
                                          onTap: () => onRenameColumn(column),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: const Color(0xFFE1E7F0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: section.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    column.name,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                  color: Color(0xFF667085),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          key: ValueKey(
                                            '$periodKey-${section.title}-${column.id}',
                                          ),
                                          initialValue: amount == 0
                                              ? ''
                                              : amount.toStringAsFixed(2),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                            decimal: true,
                                          ),
                                          decoration: InputDecoration(
                                            labelText:
                                                l10n.dashboardAmountLabel,
                                            prefixText: '€ ',
                                            suffixIcon: Icon(
                                              Icons.euro_rounded,
                                              color: section.color,
                                            ),
                                          ),
                                          onChanged: (value) =>
                                              onAmountChanged(column, value),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => onDeleteColumn(column),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                        ),
                                        color: Colors.redAccent,
                                      ),
                                    ],
                                  ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _softColor(section.color),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.budgetSectionTotalLabel(
                                _formatAmount(total),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: section.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

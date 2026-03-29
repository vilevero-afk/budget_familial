import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/budget_models.dart';

class BudgetExpenseSectionCard extends StatelessWidget {
  const BudgetExpenseSectionCard({
    super.key,
    required this.section,
    required this.sectionExpanded,
    required this.onToggleSection,
    required this.categoryTotalProvider,
    required this.subCategoryTotalProvider,
    required this.subCategoryEntryCountProvider,
    required this.isCategoryExpanded,
    required this.onToggleCategory,
    required this.onAddCategory,
    required this.onRenameCategory,
    required this.onDeleteCategory,
    required this.onAddSubCategory,
    required this.onRenameSubCategory,
    required this.onDeleteSubCategory,
    required this.onAddEntry,
  });

  final ExpenseSectionTemplate section;
  final bool sectionExpanded;
  final VoidCallback onToggleSection;
  final double Function(ExpenseCategoryTemplate category) categoryTotalProvider;
  final double Function(ExpenseSubCategoryTemplate subCategory)
  subCategoryTotalProvider;
  final int Function(ExpenseSubCategoryTemplate subCategory)
  subCategoryEntryCountProvider;
  final bool Function(ExpenseCategoryTemplate category) isCategoryExpanded;
  final void Function(ExpenseCategoryTemplate category) onToggleCategory;
  final VoidCallback onAddCategory;
  final void Function(ExpenseCategoryTemplate category) onRenameCategory;
  final void Function(ExpenseCategoryTemplate category) onDeleteCategory;
  final void Function(ExpenseCategoryTemplate category) onAddSubCategory;
  final void Function(ExpenseSubCategoryTemplate subCategory)
  onRenameSubCategory;
  final void Function(
      ExpenseCategoryTemplate category,
      ExpenseSubCategoryTemplate subCategory,
      ) onDeleteSubCategory;
  final void Function(ExpenseSubCategoryTemplate subCategory) onAddEntry;

  static const _sectionColor = Color(0xFFEF4444);

  String _formatAmount(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  String _localizedSectionTitle(AppLocalizations l10n) {
    switch (section.title.trim().toLowerCase()) {
      case 'dépenses':
      case 'depenses':
      case 'expenses':
        return l10n.dashboardExpenses;
      default:
        return section.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final total = section.categories.fold<double>(
      0.0,
          (sum, item) => sum + categoryTotalProvider(item),
    );

    final localizedTitle = _localizedSectionTitle(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFFFBFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8DCDC)),
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
                  onTap: onToggleSection,
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
                              color: _sectionColor.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              sectionExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              color: _sectionColor,
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
                              color: _sectionColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _formatAmount(total),
                              style: const TextStyle(
                                color: _sectionColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: onAddCategory,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                              l10n.expenseSectionAddCategoryButton,
                            ),
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
                          color: _sectionColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sectionExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_right_rounded,
                          color: _sectionColor,
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
                          color: _sectionColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _formatAmount(total),
                          style: const TextStyle(
                            color: _sectionColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: onAddCategory,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.expenseSectionAddCategoryButton),
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
                        if (section.categories.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE5EAF3)),
                            ),
                            child: Text(
                              l10n.expenseSectionEmpty,
                              style: const TextStyle(color: Color(0xFF667085)),
                            ),
                          ),
                        ...section.categories.map((category) {
                          final expanded = isCategoryExpanded(category);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: EdgeInsets.all(isCompact ? 10 : 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1D8D8)),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => onToggleCategory(category),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFF0E1E1),
                                      ),
                                    ),
                                    child: isCompact
                                        ? Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              expanded
                                                  ? Icons
                                                  .keyboard_arrow_down_rounded
                                                  : Icons
                                                  .keyboard_arrow_right_rounded,
                                              color: _sectionColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                category.name,
                                                maxLines: 3,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                  FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _sectionColor
                                                    .withValues(
                                                  alpha: 0.10,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(
                                                  999,
                                                ),
                                              ),
                                              child: Text(
                                                _formatAmount(
                                                  categoryTotalProvider(
                                                    category,
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  color: _sectionColor,
                                                  fontWeight:
                                                  FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  onAddSubCategory(
                                                    category,
                                                  ),
                                              icon: const Icon(
                                                Icons.playlist_add,
                                              ),
                                              tooltip: l10n
                                                  .expenseSectionAddSubCategoryTooltip,
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  onRenameCategory(
                                                    category,
                                                  ),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              tooltip: l10n
                                                  .expenseSectionRenameCategoryTooltip,
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  onDeleteCategory(
                                                    category,
                                                  ),
                                              icon: const Icon(
                                                Icons
                                                    .delete_outline_rounded,
                                              ),
                                              color: Colors.redAccent,
                                              tooltip: l10n
                                                  .expenseSectionDeleteCategoryTooltip,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                        : Row(
                                      children: [
                                        Icon(
                                          expanded
                                              ? Icons
                                              .keyboard_arrow_down_rounded
                                              : Icons
                                              .keyboard_arrow_right_rounded,
                                          color: _sectionColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _sectionColor
                                                .withValues(alpha: 0.10),
                                            borderRadius:
                                            BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            _formatAmount(
                                              categoryTotalProvider(
                                                category,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: _sectionColor,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          onPressed: () =>
                                              onAddSubCategory(category),
                                          icon: const Icon(
                                            Icons.playlist_add,
                                          ),
                                          tooltip: l10n
                                              .expenseSectionAddSubCategoryTooltip,
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              onRenameCategory(category),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                          ),
                                          tooltip: l10n
                                              .expenseSectionRenameCategoryTooltip,
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              onDeleteCategory(category),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                          ),
                                          color: Colors.redAccent,
                                          tooltip: l10n
                                              .expenseSectionDeleteCategoryTooltip,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Column(
                                      children: [
                                        if (category.subCategories.isEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              l10n.expenseSectionNoSubCategory,
                                              style: const TextStyle(
                                                color: Color(0xFF667085),
                                              ),
                                            ),
                                          ),
                                        ...category.subCategories
                                            .map((subCategory) {
                                          final entryCount =
                                          subCategoryEntryCountProvider(
                                            subCategory,
                                          );
                                          final subTotal =
                                          subCategoryTotalProvider(
                                            subCategory,
                                          );

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            padding: EdgeInsets.all(
                                              isCompact ? 10 : 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(18),
                                              border: Border.all(
                                                color: const Color(0xFFF1E3E3),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () =>
                                                            onRenameSubCategory(
                                                              subCategory,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Container(
                                                              width: 32,
                                                              height: 32,
                                                              decoration:
                                                              BoxDecoration(
                                                                color:
                                                                _sectionColor
                                                                    .withValues(
                                                                  alpha: 0.08,
                                                                ),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                  10,
                                                                ),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .subdirectory_arrow_right_rounded,
                                                                color:
                                                                _sectionColor,
                                                                size: 18,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                subCategory.name,
                                                                maxLines: 3,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 18,
                                                              color: Color(
                                                                0xFF667085,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          onDeleteSubCategory(
                                                            category,
                                                            subCategory,
                                                          ),
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                      ),
                                                      color: Colors.redAccent,
                                                      tooltip: l10n
                                                          .expenseSectionDeleteSubCategoryTooltip,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                if (isCompact) ...[
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: const Color(
                                                            0xFFF8FAFC,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            999,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          l10n
                                                              .expenseSectionOperationsCount(
                                                            entryCount,
                                                          ),
                                                          style:
                                                          const TextStyle(
                                                            fontWeight:
                                                            FontWeight.w600,
                                                            color: Color(
                                                              0xFF475467,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: _sectionColor
                                                              .withValues(
                                                            alpha: 0.10,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                            999,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          l10n
                                                              .expenseSectionTotalLabel(
                                                            _formatAmount(
                                                              subTotal,
                                                            ),
                                                          ),
                                                          style:
                                                          const TextStyle(
                                                            fontWeight:
                                                            FontWeight.w800,
                                                            color: _sectionColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                    Alignment.centerLeft,
                                                    child: FilledButton.icon(
                                                      onPressed: () =>
                                                          onAddEntry(
                                                            subCategory,
                                                          ),
                                                      icon: const Icon(
                                                        Icons.add_rounded,
                                                      ),
                                                      label: Text(
                                                        l10n
                                                            .expenseSectionAddAmountButton,
                                                      ),
                                                    ),
                                                  ),
                                                ] else
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children: [
                                                            Container(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                              decoration:
                                                              BoxDecoration(
                                                                color:
                                                                const Color(
                                                                  0xFFF8FAFC,
                                                                ),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                  999,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                l10n
                                                                    .expenseSectionOperationsCount(
                                                                  entryCount,
                                                                ),
                                                                style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                                  color: Color(
                                                                    0xFF475467,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                              decoration:
                                                              BoxDecoration(
                                                                color: _sectionColor
                                                                    .withValues(
                                                                  alpha: 0.10,
                                                                ),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                  999,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                l10n
                                                                    .expenseSectionTotalLabel(
                                                                  _formatAmount(
                                                                    subTotal,
                                                                  ),
                                                                ),
                                                                style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                                  color:
                                                                  _sectionColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      FilledButton.icon(
                                                        onPressed: () =>
                                                            onAddEntry(
                                                              subCategory,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.add_rounded,
                                                        ),
                                                        label: Text(
                                                          l10n
                                                              .expenseSectionAddAmountButton,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: expanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 220),
                                ),
                              ],
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _sectionColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.expenseSectionTotalLabel(
                                _formatAmount(total),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _sectionColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: sectionExpanded
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
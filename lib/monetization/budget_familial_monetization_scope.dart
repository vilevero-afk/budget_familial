import 'package:flutter/material.dart';

import 'monetization_controller.dart';

class BudgetFamilialMonetizationScope
    extends InheritedNotifier<MonetizationController> {
  const BudgetFamilialMonetizationScope({
    super.key,
    required MonetizationController controller,
    required super.child,
  }) : super(
          notifier: controller,
        );

  static MonetizationController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BudgetFamilialMonetizationScope>();
    assert(scope != null, 'BudgetFamilialMonetizationScope introuvable.');
    return scope!.notifier!;
  }
}

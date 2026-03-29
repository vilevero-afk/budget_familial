import 'package:flutter/material.dart';

import 'monetization_controller.dart';
import 'paywall_screen.dart';

class PremiumGuard extends StatelessWidget {
  const PremiumGuard({
    super.key,
    required this.controller,
    required this.child,
  });

  final MonetizationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (controller.isPremium) return child;

    return PaywallScreen(controller: controller);
  }
}
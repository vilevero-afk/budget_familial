import 'package:budget_familial/firebase_options.dart';
import 'package:budget_familial/main.dart';
import 'package:budget_familial/monetization/ads_service.dart';
import 'package:budget_familial/monetization/consent_service.dart';
import 'package:budget_familial/monetization/monetization_controller.dart';
import 'package:budget_familial/monetization/subscription_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        rethrow;
      }
    }
  });

  testWidgets('BudgetFamilialApp builds', (WidgetTester tester) async {
    final monetizationController = MonetizationController(
      subscriptionService: SubscriptionService(),
      consentService: ConsentService(),
      adsService: AdsService(),
    );

    await tester.pumpWidget(
      BudgetFamilialApp(
        monetizationController: monetizationController,
      ),
    );

    await tester.pump();

    expect(find.byType(BudgetFamilialApp), findsOneWidget);
  });
}
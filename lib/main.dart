import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'monetization/ads_service.dart';
import 'monetization/budget_familial_monetization_scope.dart';
import 'monetization/consent_service.dart';
import 'monetization/monetization_config.dart';
import 'monetization/monetization_controller.dart';
import 'monetization/paywall_screen.dart';
import 'monetization/subscription_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught async error: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final monetizationController = MonetizationController(
      subscriptionService: SubscriptionService(),
      consentService: ConsentService(),
      adsService: AdsService(),
    );

    runApp(
      BudgetFamilialApp(
        monetizationController: monetizationController,
      ),
    );
  } catch (e, stack) {
    debugPrint('App startup failed: $e');
    debugPrintStack(stackTrace: stack);

    runApp(const _StartupFailureApp());
  }
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Erreur au démarrage de l\'application',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class BudgetFamilialApp extends StatefulWidget {
  const BudgetFamilialApp({
    super.key,
    required this.monetizationController,
  });

  final MonetizationController monetizationController;

  @override
  State<BudgetFamilialApp> createState() => _BudgetFamilialAppState();
}

class _BudgetFamilialAppState extends State<BudgetFamilialApp> {
  static const String _localeStorageKey = 'budget_familial_selected_locale';

  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_localeStorageKey);

      if (!mounted) return;

      if (savedCode == null || savedCode.isEmpty) {
        setState(() {
          _locale = null;
        });
        return;
      }

      setState(() {
        _locale = Locale(savedCode);
      });
    } catch (e) {
      debugPrint('Locale load error: $e');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (locale == null) {
        await prefs.remove(_localeStorageKey);
      } else {
        await prefs.setString(_localeStorageKey, locale.languageCode);
      }

      if (!mounted) return;

      setState(() {
        _locale = locale;
      });
    } catch (e) {
      debugPrint('Locale save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BudgetFamilialMonetizationScope(
      controller: widget.monetizationController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: _AppStartupGate(
          onLocaleChanged: setLocale,
          currentLocale: _locale,
        ),
      ),
    );
  }
}

class _AppStartupGate extends StatefulWidget {
  const _AppStartupGate({
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  final Future<void> Function(Locale? locale) onLocaleChanged;
  final Locale? currentLocale;

  @override
  State<_AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<_AppStartupGate> {
  static const String _welcomeCompletedStorageKey =
      'budget_familial_has_completed_welcome';

  final AuthService _authService = AuthService();

  bool _monetizationInitializationStarted = false;
  bool _isCheckingWelcome = true;
  bool _hasCompletedWelcome = false;

  @override
  void initState() {
    super.initState();
    _loadWelcomeStatus();
  }

  Future<void> _loadWelcomeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_welcomeCompletedStorageKey) ?? false;

      if (!mounted) return;

      setState(() {
        _hasCompletedWelcome = completed;
        _isCheckingWelcome = false;
      });
    } catch (e) {
      debugPrint('Welcome status load error: $e');

      if (!mounted) return;

      setState(() {
        _hasCompletedWelcome = false;
        _isCheckingWelcome = false;
      });
    }
  }

  Future<void> _markWelcomeCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_welcomeCompletedStorageKey, true);

      if (!mounted) return;

      setState(() {
        _hasCompletedWelcome = true;
      });
    } catch (e) {
      debugPrint('Welcome status save error: $e');

      if (!mounted) return;

      setState(() {
        _hasCompletedWelcome = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_monetizationInitializationStarted) return;
    _monetizationInitializationStarted = true;

    final controller = BudgetFamilialMonetizationScope.of(context);

    Future<void>.microtask(() async {
      try {
        await controller.initialize(
          appUserId: MonetizationConfig.localAppUserIdOverride,
        );
      } catch (e) {
        debugPrint('Monetization init error: $e');
      }
    });
  }

  Future<void> _openLoginScreen({required bool startInSignupMode}) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          authService: _authService,
          initialIsLoginMode: !startInSignupMode,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPremiumScreenFromWelcome() async {
    if (!mounted) return;

    final monetization = BudgetFamilialMonetizationScope.of(context);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(controller: monetization),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingWelcome) {
      return const _LoadingScreen();
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = _authService.currentUser;

        if (user != null) {
          if (!_hasCompletedWelcome) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _markWelcomeCompleted();
            });
          }

          if (!user.emailVerified) {
            return const _EmailVerificationRequiredScreen();
          }

          return DashboardScreen(
            onLocaleChanged: widget.onLocaleChanged,
            currentLocale: widget.currentLocale,
          );
        }

        if (!_hasCompletedWelcome) {
          return WelcomeScreen(
            onCreateAccount: () => _openLoginScreen(startInSignupMode: true),
            onSignIn: () => _openLoginScreen(startInSignupMode: false),
            onOpenPremium: _openPremiumScreenFromWelcome,
            onLocaleChanged: widget.onLocaleChanged,
            currentLocale: widget.currentLocale,
          );
        }

        return LoginScreen(
          authService: _authService,
          initialIsLoginMode: true,
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmailVerificationRequiredScreen extends StatelessWidget {
  const _EmailVerificationRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Veuillez vérifier votre email.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

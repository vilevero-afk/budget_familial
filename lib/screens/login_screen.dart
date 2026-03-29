import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    this.initialIsLoginMode = true,
  });

  final AuthService authService;
  final bool initialIsLoginMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _isLoginMode;
  bool _isSubmitting = false;
  bool _isResettingPassword = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialIsLoginMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _closeIfPresentedModally() async {
    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        await widget.authService.signIn(
          email: email,
          password: password,
        );

        await _closeIfPresentedModally();
      } else {
        await widget.authService.signUp(
          email: email,
          password: password,
        );
        await widget.authService.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.loginAccountCreatedVerificationSent(email),
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }

        await _closeIfPresentedModally();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    FocusScope.of(context).unfocus();

    if (_isResettingPassword || _isSubmitting) return;

    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);

    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
      });
      return;
    }

    setState(() {
      _isResettingPassword = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.loginPasswordResetSent(email),
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResettingPassword = false;
        });
      }
    }
  }

  void _toggleMode() {
    if (_isSubmitting || _isResettingPassword) return;

    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.loginEnterEmail;
    if (!email.contains('@') || !email.contains('.')) {
      return l10n.loginInvalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return l10n.loginEnterPassword;
    if (password.length < 6) {
      return l10n.loginPasswordMinLength;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLoginMode ? l10n.loginTitle : l10n.signupTitle;
    final subtitle =
    _isLoginMode ? l10n.loginSubtitle : l10n.signupSubtitle;
    final primaryButtonLabel =
    _isLoginMode ? l10n.loginPrimaryButton : l10n.signupPrimaryButton;
    final secondaryLabel = _isLoginMode
        ? l10n.loginSwitchToSignup
        : l10n.loginSwitchToSignin;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.account_circle_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginFirebaseSecure,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                labelText: l10n.loginEmailLabel,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: l10n.loginPasswordLabel,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            if (_isLoginMode) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                  (_isSubmitting || _isResettingPassword)
                                      ? null
                                      : _sendPasswordResetEmail,
                                  child: Text(
                                    _isResettingPassword
                                        ? l10n.loginSending
                                        : l10n.loginForgotPassword,
                                  ),
                                ),
                              ),
                            ],
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFECDD3),
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFBE123C),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed:
                              (_isSubmitting || _isResettingPassword)
                                  ? null
                                  : _submit,
                              child: Text(
                                _isSubmitting
                                    ? l10n.loginProcessing
                                    : primaryButtonLabel,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed:
                              (_isSubmitting || _isResettingPassword)
                                  ? null
                                  : _toggleMode,
                              child: Text(secondaryLabel),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../firebase/firebase_auth_service.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const String routeName = "/forget-password";
  final FirebaseAuthService? authService;

  const ForgetPasswordScreen({super.key, this.authService});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    String? errorCode;
    bool failed = false;
    try {
      await (widget.authService ?? FirebaseAuthService()).forgetPassword(
        _emailController.text.trim(),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'user-not-found') {
        failed = true;
        errorCode = error.code;
      }
    } catch (_) {
      failed = true;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    final locale = AppLocalizations.of(context)!;
    final message = !failed
        ? locale.passwordResetSent
        : switch (errorCode) {
            'invalid-email' => locale.invalidEmailFormat,
            'network-request-failed' => locale.passwordResetNetworkError,
            'too-many-requests' => locale.passwordResetTooManyRequests,
            _ => locale.passwordResetFailed,
          };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final provider = context.watch<AppConfig>();
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.forgetPasswordTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              Image.asset(
                "assets/images/change-setting_${provider.themeMode == ThemeMode.light ? "light" : "dark"}.png",
              ),
              TextFormField(
                controller: _emailController,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                validator: (value) =>
                    Validator().emailValidation(value, locale),
                onFieldSubmitted: (_) => _resetPassword(),
                decoration: InputDecoration(
                  hintText: locale.enterYourEmail,
                  prefixIcon: const Icon(EvaIcons.email_outline),
                ),
              ),
              FilledButton(
                onPressed: _sending ? null : _resetPassword,
                child: _sending
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: locale.sendingPasswordReset,
                        ),
                      )
                    : Text(locale.resetPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../firebase/auth_service.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = "/signup";

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController passwordConfirmationController =
      TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> _signInWithGoogle(AppLocalizations locale) async {
    try {
      setState(() {
        isLoading = true;
      });
      final user = await authService.signInWithGoogle();
      if (!mounted || user == null) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${locale.googleSignInFailed}\n$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfig>(context);
    var locale = AppLocalizations.of(context)!;
    var validator = Validator();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              spacing: 24,
              crossAxisAlignment: .start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/app_logo_${provider.themeMode == ThemeMode.light ? "light" : "dark"}.png",
                    width: MediaQuery.sizeOf(context).width * .4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  locale.createYourAccount,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  autovalidateMode: .onUserInteraction,
                  controller: nameController,
                  validator: (input) => validator.nameValidation(input, locale),
                  decoration: InputDecoration(
                    hint: Text(locale.enterYourName),
                    prefixIcon: Icon(Iconsax.user_outline),
                  ),
                ),
                TextFormField(
                  autovalidateMode: .onUserInteraction,
                  controller: emailController,
                  validator: (input) =>
                      validator.emailValidation(input, locale),
                  decoration: InputDecoration(
                    hint: Text(locale.enterYourEmail),
                    prefixIcon: Icon(EvaIcons.email_outline),
                  ),
                ),
                TextFormField(
                  autovalidateMode: .onUserInteraction,
                  controller: passwordController,

                  validator: (input) =>
                      validator.passwordValidation(input, locale),
                  decoration: InputDecoration(
                    hint: Text(locale.enterYourPassword),
                    prefixIcon: Icon(Iconsax.lock_outline),
                    suffixIcon: Icon(Iconsax.eye_slash_outline),
                  ),
                ),
                TextFormField(
                  autovalidateMode: .onUserInteraction,
                  controller: passwordConfirmationController,

                  validator: (input) =>
                      validator.passwordConfirmationValidation(
                        input,
                        passwordController.text,
                        locale,
                      ),
                  decoration: InputDecoration(
                    hint: Text(locale.confirmYourPassword),
                    prefixIcon: Icon(Iconsax.user_outline),
                    suffixIcon: Icon(Iconsax.eye_slash_outline),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        var user = await authService
                            .createAccountWithEmailAndPassword(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                            );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Account created successfully. ${user?.displayName}",
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        if (e.code == 'weak-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "The password provided is too weak.",
                              ),
                            ),
                          );
                        } else if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "The account already exists for that email.",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.surface,
                        )
                      : Text(locale.signUp),
                ),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text(locale.dontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(locale.login),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(locale.or),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                OutlinedButton(
                  onPressed: isLoading ? null : () => _signInWithGoogle(locale),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Image.asset("assets/images/google_logo.png", scale: 1.4),
                      SizedBox(width: 16),
                      Text(locale.signUpWithGoogle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

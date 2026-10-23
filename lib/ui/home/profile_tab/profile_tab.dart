import 'package:assignment_6/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/firebase_auth_service.dart';
import '../../login/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final user = FirebaseAuthService().getUserData();
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final panel = config.isDark()
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 56),
          Center(
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text(
                'ROUTE',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.displayName ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8B8B8B)),
          ),
          const SizedBox(height: 40),
          Material(
            color: panel,
            borderRadius: BorderRadius.circular(8),
            child: SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                l10n.darkMode,
                style: TextStyle(
                  fontSize: 14,
                  color: config.isDark()
                      ? Colors.white
                      : const Color(0xFF1C1C1C),
                ),
              ),
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF23C26B),
              inactiveTrackColor: const Color(0xFFE5E8EF),
              inactiveThumbColor: Colors.white,
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              value: config.isDark(),
              onChanged: (value) =>
                  config.changeTheme(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: panel,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 14,
                  color: config.isDark()
                      ? Colors.white
                      : const Color(0xFF1C1C1C),
                ),
              ),
              trailing: Icon(Icons.chevron_right, size: 22, color: primary),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(l10n.englishNative),
                        trailing: config.isEn()
                            ? Icon(Icons.check, color: primary)
                            : null,
                        onTap: () {
                          config.changeLocale('en');
                          Navigator.pop(sheetContext);
                        },
                      ),
                      ListTile(
                        title: Text(l10n.arabicNative),
                        trailing: !config.isEn()
                            ? Icon(Icons.check, color: primary)
                            : null,
                        onTap: () {
                          config.changeLocale('ar');
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: panel,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                l10n.logout,
                style: TextStyle(
                  fontSize: 14,
                  color: config.isDark()
                      ? Colors.white
                      : const Color(0xFF1C1C1C),
                ),
              ),
              trailing: Icon(
                Icons.logout,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () async {
                try {
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.routeName,
                    (_) => false,
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.operationFailed(error.toString())),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

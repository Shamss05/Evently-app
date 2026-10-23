import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import 'screen_data.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => currentIndex == onboardingPages.length - 1;

  Future<void> _finishOnboarding() async {
    await context.read<AppConfig>().completeOnboarding();
    if (!mounted) return;
    final route = FirebaseAuth.instance.currentUser == null
        ? LoginScreen.routeName
        : HomeScreen.routeName;
    Navigator.pushReplacementNamed(context, route);
  }

  void _nextPage() {
    if (_isLastPage) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppConfig>();
    final locale = AppLocalizations.of(context)!;
    final isLight = provider.themeMode == ThemeMode.light;
    final colors = isLight ? LightAppColors() : DarkAppColors();
    final page = onboardingPages[currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _OnboardingHeader(
                showBack: currentIndex > 0,
                showSkip: !_isLastPage,
                skipLabel: locale.skip,
                onBack: _previousPage,
                onSkip: _finishOnboarding,
                logoAsset:
                    'assets/images/app_logo_${isLight ? 'light' : 'dark'}.png',
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final item = onboardingPages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Image.asset(
                        item.imageFor(isLight),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    );
                  },
                ),
              ),
              _PageIndicator(
                count: onboardingPages.length,
                currentIndex: currentIndex,
                activeColor: colors.mainColor,
                inactiveColor: colors.mainColor.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  page.title(locale),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.mainColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                page.description(locale),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colors.secondaryTextColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _nextPage,
                child: Text(_isLastPage ? locale.getStarted : locale.next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  final bool showBack;
  final bool showSkip;
  final String skipLabel;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final String logoAsset;

  const _OnboardingHeader({
    required this.showBack,
    required this.showSkip,
    required this.skipLabel,
    required this.onBack,
    required this.onSkip,
    required this.logoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(logoAsset, height: 28, fit: BoxFit.contain),
          Row(
            children: [
              if (showBack)
                _HeaderChip(
                  onPressed: onBack,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                )
              else
                const SizedBox(width: 40),
              const Spacer(),
              if (showSkip)
                _HeaderChip(
                  onPressed: onSkip,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Text(skipLabel),
                )
              else
                const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets padding;

  const _HeaderChip({
    required this.onPressed,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = isLight ? LightAppColors() : DarkAppColors();

    return Material(
      color: colors.inputColor,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Container(
          padding: padding,
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: colors.mainColor, width: 1.2),
            ),
          ),
          child: IconTheme(
            data: IconThemeData(color: colors.mainColor, size: 16),
            child: DefaultTextStyle(
              style: TextStyle(
                color: colors.mainColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: isActive ? 22 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

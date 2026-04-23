import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../auth/providers/auth_provider.dart';
import '../../../app/router.dart';

enum SlideDirection { left, right, bottom, top }

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int index;
  final SlideDirection direction;

  const _AnimatedSection({
    required this.child,
    required this.index,
    this.direction = SlideDirection.bottom,
  });

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideAnimation2;
  late Animation<double> _fadeAnimation;

  Offset get _beginOffset {
    switch (widget.direction) {
      case SlideDirection.left:
        return const Offset(-1, 0);
      case SlideDirection.right:
        return const Offset(1, 0);
      case SlideDirection.bottom:
        return const Offset(0, 0.3);
      case SlideDirection.top:
        return const Offset(0, -0.3);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('section_${widget.index}'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction > 0.15) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Landing Page Mobile ──────────────────────────────────
class LandingPageMobile extends ConsumerWidget {
  const LandingPageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    Widget buildStep(String number, String title, String description) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    )),
                const SizedBox(height: 6),
                Text(description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo (no animation) ──────────────────
                Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/aemo-logo.png', height: 80),
                ),

                const SizedBox(height: 24),

                // ── Hero text ────────────────────────────
                _AnimatedSection(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Easy Online Loans\nfor Your Future",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Designed for simplicity. Built for speed. Get the funds you need in just a few clicks.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Buttons ──────────────────────────────
                _AnimatedSection(
                  index: 1,
                  child: Column(
                    children: [
                      CustomButton(
                        label: 'Apply Now',
                        onPressed: () => context.push(AppRoutes.login),
                        width: double.infinity,
                        height: 70,
                        buttonStyle: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Calculate Payment',
                        height: 70,
                        textStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                        buttonStyle: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              color: Color.fromARGB(255, 183, 194, 211),
                              width: 2),
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => context.go(AppRoutes.calculator),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Why Choose Us ────────────────────────
                _AnimatedSection(
                  index: 2,
                  child: Text(
                    "Why Choose ${AppStrings.appName}?",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF747779),
                          fontSize: 28,
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                _AnimatedSection(
                  direction: SlideDirection.right,
                  index: 3,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFE8ECF0), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.devices_outlined,
                              color: Color(0xFF1E2A3B), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fully Online',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: const Color(0xFF444749),
                                        fontSize: 30)),
                            const SizedBox(height: 8),
                            Text(
                                'Complete your application\nfrom the comfort of your home',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontSize: 16,
                                        color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _AnimatedSection(
                  direction: SlideDirection.right,
                  index: 4,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFE8ECF0), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bolt_outlined,
                              color: Color(0xFF1E2A3B), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Review',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: const Color(0xFF444749),
                                        fontSize: 30)),
                            const SizedBox(height: 8),
                            Text(
                                'Streamlined application\nprocess with fast decisions.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontSize: 16,
                                        color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _AnimatedSection(
                  direction: SlideDirection.left,
                  index: 5,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFE8ECF0), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user_outlined,
                              color: Color(0xFF1E2A3B), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Secure and Reliable',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: const Color(0xFF444749),
                                        fontSize: 30)),
                            const SizedBox(height: 8),
                            Text(
                                'Bank Grade encryption ensures your\ndata is safe.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontSize: 16,
                                        color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // ── How It Works ─────────────────────────
                _AnimatedSection(
                  index: 6,
                  child: Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 30,
                        ),
                  ),
                ),

                const SizedBox(height: 40),

                _AnimatedSection(
                  direction: SlideDirection.right,
                  index: 7,
                  child: buildStep('1', 'Apply Online',
                      'Fill out our secure 5-minute application form with your business details.'),
                ),

                const SizedBox(height: 32),

                _AnimatedSection(
                  direction: SlideDirection.left,
                  index: 8,
                  child: buildStep('2', 'Get Approved',
                      'Our expert team reviews your application and provides a tailored offer.'),
                ),

                const SizedBox(height: 32),

                _AnimatedSection(
                  direction: SlideDirection.right,
                  index: 9,
                  child: buildStep('3', 'Receive Funding',
                      'Funds are deposited directly into your account within 24 hours.'),
                ),

                const SizedBox(height: 60),

                // ── CTA ──────────────────────────────────
                _AnimatedSection(
                  direction: SlideDirection.bottom,
                  index: 10,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ready to redefine your financial horizon?',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.white,
                                    fontSize: 30,
                                  ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Join thousands of forward thinking individuals building their future with AEMO',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryLightShade,
                                    fontSize: 18,
                                  ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B2F5E),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ───────────────────────────────
                _AnimatedSection(
                  index: 11,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 60, horizontal: 40),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFooterColumn(context, 'SOLUTIONS', [
                                'Personal Loans',
                                'Business Credit',
                                'Mortgage Refinance',
                                'Student Loans',
                              ]),
                            ),
                            Expanded(
                              child: _buildFooterColumn(context, 'COMPANY', [
                                'About Us',
                                'Careers',
                                'Press Room',
                                'Impact',
                              ]),
                            ),
                            Expanded(
                              child: _buildFooterColumn(context, 'COMPLIANCE', [
                                'Privacy Policy',
                                'Terms of Service',
                                'Cookie Settings',
                                'Security',
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          '© 2024 ${AppStrings.appName} Inc. All rights reserved.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
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

Widget _buildFooterColumn(
    BuildContext context, String title, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E2A3B),
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 16),
      ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              item,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
            ),
          )),
    ],
  );
}

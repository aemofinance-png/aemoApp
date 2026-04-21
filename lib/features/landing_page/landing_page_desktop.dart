import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../auth/providers/auth_provider.dart';
import '../../../app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TopNavBar()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
              _HeroSection(),
              _WhyChooseSection(),
              _HowItWorksSection(),
              _FinalCTASection(),
              _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      color: Colors.white.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AEMO FINANCE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              _NavButton('Portfolio'),
              const SizedBox(width: 30),
              _NavButton('Insights'),
              const SizedBox(width: 30),
              _NavButton('Markets'),
              const SizedBox(width: 30),
              _NavButton('Reports'),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(
                  'Log In',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _NavButton(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'NEXT-GEN LENDING ARCHITECTURE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideX(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 32),
                Text(
                  'Easy Online Loans\nfor Your Future',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -2,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 32),
                Text(
                  'Aemo Finance provides a clinical approach to digital credit. Minimal friction, Maximum transparency. Designed for the architectural precision of your financial life.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 48),
                SizedBox(
                  width: 420,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Apply Now',
                          height: 56,
                          onPressed: () => context.go(AppRoutes.login),
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          label: 'Calculate Payment',
                          height: 56,
                          onPressed: () => context.go(AppRoutes.calculator),
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD6E3FE),
                            foregroundColor: const Color(0xFF58657C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFzaM8Viuv658zq-WDOD2VCnV133UNDpJeml-nfjSeWcZZC4m1QSTQ7FmH6LlFQ151mdUvzzOueoHIywc2Ns7N79B_IyuZ-8LwzDinCsETUZ3otLxe9cB_Wuo1BKkN9V5TW3tubFfbihVuTBd7C-vjldl3Lohlrzffw8B08bEFyvSXhpZROM7_NVh-4PbMtYvuiAjNRl8WhyloIng0uolUlfUT-6hffLr3LpXfFLf8G0zdWeumjhHlV_sVA2wVX9fU9Ip4G2pylbv'),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 32,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CURRENT RATE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 40),
                            Text(
                              '+0.02%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3A5F94),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '4.25% APR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 1200.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                ),
              ],
            ).animate().fadeIn(duration: 1000.ms, delay: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }
}

class _WhyChooseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 120),
      color: const Color(0xFFECEEF0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose Aemo Finance?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -1,
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: false)).fadeIn(duration: 800.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().scaleX(begin: 0, end: 1, duration: 600.ms, delay: 400.ms),
          const SizedBox(height: 60),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _FeatureCardLarge(
                  number: '01',
                  icon: Icons.cloud_done,
                  title: 'Fully Online',
                  description:
                      'No physical branches, no paperwork queues. Access our entire lending suite from any device, anywhere in the world. Your time is valuable; we treat it that way.',
                ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _FeatureCardDark(
                  number: '02',
                  icon: Icons.bolt,
                  title: 'Quick Review',
                  description:
                      'Instant algorithmic analysis provides a decision in minutes, not days. Seamless execution is our standard.',
                ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FeatureCardFull(
            number: '03',
            icon: Icons.shield_outlined,
            title: 'Secure and Reliable',
            description:
                'Bank-grade encryption and decentralized data protocols ensure your financial identity remains private and protected. We build the vault around your assets.',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDWr-aUuGCUPgmzVRu4ltt0GihBQO4XuQX6dfRd-HFyaxvIVUfoSxZQEq_IK8JyDrg2wOn0fkrgjJyB2a82tYl-ukvlFRhE0NDrkJETW7NV6_EU9XCVOu0CH8_bmUGfeE2X208aXhbM-VNnvM-5C13FqvYYYEg1Q8I9x29s0rPafBdkHUq1eyno-bxR19hTnPiYP5RdBS3VT4yTWWkZxsPn46qGlpANrR81J54FErC6LGIvH-7wpTS0KTNob8S97ghI-lAzIafWHFVr',
          ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _FeatureCardLarge extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCardLarge({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withOpacity(0.05),
                letterSpacing: -5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardDark extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCardDark({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.05),
                letterSpacing: -5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardFull extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final String imageUrl;

  const _FeatureCardFull({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 48, color: AppColors.primary),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 120),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -1,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            'Three steps to redefine your financial horizon.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 80),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 40,
                left: 100,
                right: 100,
                child: Container(
                  height: 1,
                  color: AppColors.border,
                ).animate().scaleX(begin: 0, end: 1, duration: 1000.ms, delay: 600.ms),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StepItem(
                    number: '1',
                    title: 'Configure Loan',
                    description:
                        'Select your desired amount and term using our intuitive interface.',
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),
                  _StepItem(
                    number: '2',
                    title: 'Submit Verification',
                    description:
                        'Upload basic documentation via our secure, encrypted portal.',
                  ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(),
                  _StepItem(
                    number: '3',
                    title: 'Execute Funding',
                    description:
                        'Receive approval and enjoy instant disbursement to your account.',
                    isHighlighted: true,
                  ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).scale(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isHighlighted;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF7F9FB), width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              )
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isHighlighted ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 240,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalCTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(60),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            'Ready to redefine your financial horizon?',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Join thousands of architects of their own future. Experience lending as it should be.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 240,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create My Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AEMO FINANCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  _FooterLink('Privacy Policy'),
                  const SizedBox(width: 40),
                  _FooterLink('Terms of Service'),
                  const SizedBox(width: 40),
                  _FooterLink('Security'),
                  const SizedBox(width: 40),
                  _FooterLink('Contact Support'),
                ],
              ),
              Text(
                '© 2024 Aemo Finance. All rights reserved.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1200.ms, delay: 400.ms);
  }

  Widget _FooterLink(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}

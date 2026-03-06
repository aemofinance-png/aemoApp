import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/register_screen.dart';
import '../../../app/router.dart';
import 'package:go_router/go_router.dart';

class LandingPageMobile extends ConsumerWidget {
  const LandingPageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    Widget _buildStep(
        BuildContext context, String number, String title, String description) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.5,
                  ),
                ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Logo
                Image.asset('assets/images/aemo-logo.png', height: 80),

                const SizedBox(height: 24),

                // App Name
                Text(
                  "Easy Online Loans\nfor Your Future",
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 40),
                ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  AppStrings.tagline,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Login Button
                CustomButton(
                  label: 'Apply Now',
                  onPressed: () => context.push(AppRoutes.login),
                  width: double.infinity,
                  height: 70,
                  buttonStyle: ElevatedButton.styleFrom(
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

                // Register Button
                CustomButton(
                  // width: 170,
                  label: 'Calculate Payment',
                  height: 70,
                  textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                  buttonStyle: ElevatedButton.styleFrom(
                    side: BorderSide(
                        color: const Color.fromARGB(255, 183, 194, 211),
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
                SizedBox(height: 48),

                Container(
                  width: double.infinity,
                  height: 220,
                  child: Image.asset(
                    'assets/images/computer.png',
                    fit: BoxFit.fill,
                  ),
                ),

                SizedBox(height: 48),

                Text("Why Choose ${AppStrings.appName}?",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                        )),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE8ECF0), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.devices_outlined,
                          color: Color(0xFF1E2A3B),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fully Online',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            'Complete your application\nfrom the comfort of your home',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE8ECF0), width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon box
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F2F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.bolt_outlined,
                              color: Color(0xFF1E2A3B),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Review',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              Text(
                                'Streamlined application\nprocess with fast decisions.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE8ECF0), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.devices_outlined,
                          color: Color(0xFF1E2A3B),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fully Online',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            'Complete your application\nfrom the comfort of your home',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B2F5E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'How It Works',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildStep(context, '1', 'Apply Online',
                          'Fill out our secure 5-minute application form with your business details.'),
                      const SizedBox(height: 32),
                      _buildStep(context, '2', 'Get Approved',
                          'Our expert team reviews your application and provides a tailored offer.'),
                      const SizedBox(height: 32),
                      _buildStep(context, '3', 'Receive Funding',
                          'Funds are deposited directly into your  account within 24 hours.'),

                      const SizedBox(height: 40),

                      // Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(
                            'Start Your Application',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

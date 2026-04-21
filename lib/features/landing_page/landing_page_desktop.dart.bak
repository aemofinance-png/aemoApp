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

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget _buildFooterColumn(
      BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
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

  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Center(
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: authState.isLoading,
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Fast & Secure Financing",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                      SizedBox(height: 12),
                                      Text(
                                        "Easy Online Loans for\nYour Future",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(fontSize: 40),
                                      ),
                                      SizedBox(height: 17),
                                      Text(
                                        "Experience the Future of Lending\nWith fast Approvals and Competitive Rates,\nAemo Loan is Your Trusted Partner for Financial Success.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomButton(
                                              width: 120,
                                              label: 'Apply Now',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.white,
                                                  ),
                                              onPressed: () =>
                                                  context.go(AppRoutes.login),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: CustomButton(
                                              width: 165,
                                              label: 'Calculate Payment',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                              buttonStyle:
                                                  ElevatedButton.styleFrom(
                                                side: BorderSide(
                                                    color: const Color.fromARGB(
                                                        255, 183, 194, 211),
                                                    width: 2),
                                                shadowColor: Colors.transparent,
                                                elevation: 0,
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor:
                                                    AppColors.white,
                                                minimumSize: const Size(
                                                    double.infinity, 52),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () => context
                                                  .go(AppRoutes.calculator),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // const SizedBox(height: 16),
                                      // CustomButton(
                                      //   label: 'Register',
                                      //   onPressed: () => Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (_) => const RegisterScreen()),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  child: Container(
                                    width: 380,
                                    height: 270,
                                    child: Image.asset(
                                      'assets/images/computer.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Why Choose ${AppStrings.appName}?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontSize: 28,
                                        )),
                                const SizedBox(height: 18),
                                Text(
                                  "We've built the Future of Lending with You in Mind",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: 24),
                                IntrinsicHeight(
                                  child: Row(
                                    spacing: 16,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Color(0xFFE8ECF0),
                                                width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.devices_outlined,
                                                  color: Color(0xFF1E2A3B),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Fully Online',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Complete your entire application\nfrom the comfort of your home. ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Color(0xFFE8ECF0),
                                                width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.bolt_outlined,
                                                  color: Color(0xFF1E2A3B),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Quick Review',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Your application review starts immediatley ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 200,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Color(0xFFE8ECF0),
                                                width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.verified_user_outlined,
                                                  color: Color(0xFF1E2A3B),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Secure & Reliable',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Bank Grade encryption ensures your\ndata is safe.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // const SizedBox(height: 16),
                                // CustomButton(
                                //   label: 'Register',
                                //   onPressed: () => Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => const RegisterScreen()),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("How it works",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontSize: 28,
                                        )),
                                const SizedBox(height: 18),
                                Text(
                                  "Simple Steps to Get You Fundedr",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: 24),
                                IntrinsicHeight(
                                  child: Row(
                                    spacing: 16,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.zero,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Image.asset(
                                                    'assets/images/step_1.png'),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Create your account in minutes ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.zero,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Image.asset(
                                                    'assets/images/step_2.png'),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Fill out Application',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Fill out and submit your application online.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.zero,
                                            border: Border.all(
                                                color: Colors.transparent,
                                                width: 0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Icon box
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF0F2F5),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Image.asset(
                                                    'assets/images/step_3.png'),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              Text(
                                                'Verification & Approval',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1E2A3B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Description
                                              Text(
                                                'Your application is reviewed and approved',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontSize: 10,
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // const SizedBox(height: 16),
                                // CustomButton(
                                //   label: 'Register',
                                //   onPressed: () => Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => const RegisterScreen()),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 45),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 10),
                                  child: Container(
                                    width: double.infinity,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Ready to get started?",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Join Thousands of Customers Who Have Found Financial Freedom with ${AppStrings.appName}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  color: AppColors.textHint,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          CustomButton(
                                            color: AppColors.white,
                                            width: 160,
                                            label: 'Get Started',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                ),
                                            onPressed: () =>
                                                context.go(AppRoutes.login),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/images/aemo-logo.png',
                                      width: 32),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.appName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E2A3B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Leading the way in digital financial\nservices. Simple, transparent, and\nbuilt for you.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 8,
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.language,
                                      color: AppColors.textSecondary, size: 22),
                                  const SizedBox(width: 12),
                                  Icon(Icons.alternate_email,
                                      color: AppColors.textSecondary, size: 22),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Solutions column
                        Expanded(
                          child: _buildFooterColumn(context, 'SOLUTIONS', [
                            'Personal Loans',
                            'Business Credit',
                            'Mortgage Refinance',
                            'Student Loans',
                          ]),
                        ),

                        // Company column
                        Expanded(
                          child: _buildFooterColumn(context, 'COMPANY', [
                            'About Us',
                            'Careers',
                            'Press Room',
                            'Impact',
                          ]),
                        ),

                        // Compliance column
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

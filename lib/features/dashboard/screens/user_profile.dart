import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final authState = ref.watch(authNotifierProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildNavbar(context, ref),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: user?.selfieUrl != null &&
                                    user!.selfieUrl!.isNotEmpty
                                ? NetworkImage(user!.selfieUrl!)
                                : null,
                            child: user?.selfieUrl == null ||
                                    user!.selfieUrl!.isEmpty
                                ? Text(
                                    user?.fullName.isNotEmpty ?? false
                                        ? user!.fullName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Name & email
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: user.verificationStatus ==
                                  VerificationStatus.verified
                              ? AppColors.successLight
                              : user.verificationStatus ==
                                      VerificationStatus.unverified
                                  ? AppColors.errorLight
                                  : AppColors.pendingLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "KYC ${user.verificationStatus.name.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: user.verificationStatus ==
                                    VerificationStatus.verified
                                ? AppColors.success
                                : user.verificationStatus ==
                                        VerificationStatus.unverified
                                    ? AppColors.error
                                    : AppColors.pending,
                          ),
                        ),
                      ),

                      // Edit profile button
                      // ElevatedButton.icon(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.edit_outlined, size: 16),
                      //   label: const Text('Edit Profile'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColors.primary,
                      //     foregroundColor: Colors.white,
                      //     elevation: 0,
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 24, vertical: 12),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 32),

                      // Personal Information section
                      // _buildSection(
                      //   context,
                      //   title: 'PERSONAL INFORMATION',
                      //   items: [
                      //     _ProfileItem(
                      //       icon: Icons.person_outline,
                      //       label: 'Personal Details',
                      //       onTap: () => _showPersonalDetails(context, user),
                      //     ),
                      //     _ProfileItem(
                      //       icon: Icons.mail_outline,
                      //       label: 'Contact Information',
                      //       onTap: () => _showContactInformation(context, user),
                      //     ),
                      //   ],
                      // ),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Text(
                                'PERSONAL INFORMATION',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            ExpansionTile(
                              shape: Border.all(
                                  color: Colors
                                      .transparent), // removes ExpansionTile's own border
                              collapsedShape:
                                  Border.all(color: Colors.transparent),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_outline,
                                    color: AppColors.primary, size: 18),
                              ),
                              title: Text('Personal Details',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Column(
                                    children: [
                                      _detailRow(
                                          context, 'Full Name', user.fullName),
                                      _detailRow(
                                        context,
                                        'Phone',
                                        user.phone,
                                      ),
                                      _detailRow(
                                          context, 'Country', user.countryCode),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            ExpansionTile(
                              shape: Border.all(
                                  color: Colors
                                      .transparent), // removes ExpansionTile's own border
                              collapsedShape:
                                  Border.all(color: Colors.transparent),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.mail_outline,
                                    color: AppColors.primary, size: 18),
                              ),
                              title: Text('Contact Information',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Column(
                                    children: [
                                      _detailRow(context, 'Email', user.email),
                                      _detailRow(context, 'Street',
                                          user.streetAddress),
                                      _detailRow(context, 'City', user.city),
                                      _detailRow(context, 'State', user.state),
                                      _detailRow(context, 'Postal Code',
                                          user.postalCode),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Security section
                      _buildSection(
                        context,
                        title: 'SECURITY & PASSWORD',
                        items: [
                          _ProfileItem(
                            icon: Icons.lock_outline,
                            label: 'Change Password',
                            onTap: () {},
                          ),
                          _ProfileItem(
                            icon: Icons.fingerprint,
                            label: 'Biometric Login',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notifications section
                      // _buildSection(
                      //   context,
                      //   title: 'NOTIFICATIONS',
                      //   items: [
                      //     _ProfileItem(
                      //       icon: Icons.notifications_outlined,
                      //       label: 'Push Notifications',
                      //       onTap: () {},
                      //     ),
                      //     _ProfileItem(
                      //       icon: Icons.alternate_email,
                      //       label: 'Email Preferences',
                      //       onTap: () {},
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 16),

                      // Bank accounts section
                      _buildSection(
                        context,
                        title: 'KYC',
                        items: [
                          _ProfileItem(
                            icon: Icons.account_balance_outlined,
                            label: 'Manage KYC Status',
                            onTap: switch (user.verificationStatus) {
                              VerificationStatus.pending => () async {
                                  context
                                      .go('${AppRoutes.kycStatus}/${user.id}');
                                },
                              VerificationStatus.unverified => () async {
                                  context.go(AppRoutes.kyc);
                                },
                              VerificationStatus.verified => () async {
                                  context
                                      .go('${AppRoutes.kycStatus}/${user.id}');
                                },
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Log out
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorLight),
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                          icon: const Icon(Icons.logout,
                              color: AppColors.error, size: 18),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Version
                      Text(
                        '${AppStrings.appName} — Secured with 256-bit encryption',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset('assets/images/aemo-logo.png'),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.dashboard),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to Dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  // void _showPersonalDetails(BuildContext context, dynamic user) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (_) => Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Personal Details',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  //           const SizedBox(height: 20),
  //           _detailRow('Full Name', user.fullName),
  //           _detailRow('Phone', user.phone),
  //           _detailRow('Country', user.countryCode),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showContactInformation(BuildContext context, dynamic user) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (_) => Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Contact Information',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  //           const SizedBox(height: 20),
  //           _detailRow('Email', user.email),
  //           _detailRow('Street', user.streetAddress),
  //           _detailRow('City', user.city),
  //           _detailRow('State', user.state),
  //           _detailRow('Postal Code', user.postalCode),
  //         ],
  //       ),
  //     ),
  //   );
}

Widget _detailRow(
  BuildContext context,
  String label,
  String value,
) {
  final TextStyle textStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  )),
        ),
        Expanded(
          child: Text(value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                  )),
        ),
      ],
    ),
  );
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

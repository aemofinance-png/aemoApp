import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';

// Provider defined at top level — NOT inside build()
final userByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUser(userId);
});

class AdminUserProfile extends ConsumerWidget {
  final String userId;
  const AdminUserProfile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error loading user: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
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
                                child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
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
                                    border: Border.all(
                                        color: Colors.white, width: 2),
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

                          const SizedBox(height: 32),

                          // Personal Information section
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
                                  child: const Text(
                                    'PERSONAL INFORMATION',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                ExpansionTile(
                                  shape: Border.all(color: Colors.transparent),
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
                                  title: const Text('Personal Details'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: Column(
                                        children: [
                                          _detailRow(context, 'Full Name',
                                              user.fullName),
                                          _detailRow(
                                              context, 'Phone', user.phone),
                                          _detailRow(context, 'Country',
                                              user.countryCode),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 1),
                                ExpansionTile(
                                  shape: Border.all(color: Colors.transparent),
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
                                  title: const Text('Contact Information'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: Column(
                                        children: [
                                          _detailRow(
                                              context, 'Email', user.email),
                                          _detailRow(context, 'Street',
                                              user.streetAddress),
                                          _detailRow(
                                              context, 'City', user.city),
                                          _detailRow(
                                              context, 'State', user.state),
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

                          // Bank accounts section
                          _buildSection(
                            context,
                            title: 'KYC STATUS',
                            items: [
                              _ProfileItem(
                                icon: Icons.account_balance_outlined,
                                label: 'Manage KYC',
                                onTap: () => context.go(
                                    '${AppRoutes.reviewKYc}/${user.id}'), // navigate to KYC review screen
                              ),
                            ],
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
      },
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () =>
                context.go(AppRoutes.admin), // back to admin dashboard
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
}

Widget _detailRow(
  BuildContext context,
  String label,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
          ),
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

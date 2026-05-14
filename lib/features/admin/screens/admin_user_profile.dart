import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:aemo_loan_app/features/admin/providers/admin_provider.dart';
import 'package:aemo_loan_app/shared/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../app/router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';

// Providers defined at top level
final userByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUser(userId);
});

final userApplicationsProvider =
    FutureProvider.family<List<LoanApplicationModel>, String>(
        (ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserApplications(userId);
});

final userWithdrawalsProvider =
    FutureProvider.family<List<WithdrawalModel>, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserWithdrawals(userId);
});

class AdminUserProfile extends ConsumerWidget {
  final String userId;
  const AdminUserProfile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));
    final applicationsAsync = ref.watch(userApplicationsProvider(userId));
    final withdrawalsAsync = ref.watch(userWithdrawalsProvider(userId));

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
          backgroundColor: const Color(0xFFF7F9FB),
          body: Column(
            children: [
              _buildNavbar(context, ref, user),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1024;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64 : 20,
                      vertical: 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(user),
                            const SizedBox(height: 32),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        _buildInfoSection(context, user),
                                        const SizedBox(height: 24),
                                        _buildApplicationsSection(
                                            context, applicationsAsync, user),
                                        const SizedBox(height: 24),
                                        _buildWithdrawalsSection(context, withdrawalsAsync, user, ref),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        _buildKycStatusCard(context, user),
                                        const SizedBox(height: 24),
                                        _buildBankAccountsCard(
                                            context, user, ref),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildKycStatusCard(context, user),
                                  const SizedBox(height: 24),
                                  _buildInfoSection(context, user),
                                  const SizedBox(height: 24),
                                  _buildBankAccountsCard(context, user, ref),
                                  const SizedBox(height: 24),
                                  _buildApplicationsSection(
                                      context, applicationsAsync, user),
                                  const SizedBox(height: 24),
                                  _buildWithdrawalsSection(context, withdrawalsAsync, user, ref),
                                ],
                              ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavbar(BuildContext context, WidgetRef ref, UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRoutes.adminUsers),
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF001E40)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'User Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF001E40),
                ),
              ),
              Text(
                user.fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {
              ref.invalidate(userByIdProvider(userId));
              ref.invalidate(userApplicationsProvider(userId));
              ref.invalidate(userWithdrawalsProvider(userId));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
            image: user.selfieUrl != null && user.selfieUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user.selfieUrl!), fit: BoxFit.cover)
                : null,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: user.selfieUrl == null || user.selfieUrl!.isEmpty
              ? Center(
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF001E40),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                user.email,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, UserModel user) {
    return _buildCard(
      title: 'PERSONAL & CONTACT INFORMATION',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _buildInfoRow('Phone Number', user.phone),
          _buildInfoRow('Country', user.countryCode),
          _buildInfoRow('Street Address', user.streetAddress),
          _buildInfoRow('City/State', '${user.city}, ${user.state}'),
          _buildInfoRow('Postal Code', user.postalCode),
          _buildInfoRow('Account Created', Formatters.date(user.createdAt)),
        ],
      ),
    );
  }

  Widget _buildKycStatusCard(BuildContext context, UserModel user) {
    Color statusColor;
    IconData statusIcon;

    switch (user.verificationStatus) {
      case VerificationStatus.verified:
        statusColor = AppColors.success;
        statusIcon = Icons.verified_user_rounded;
        break;
      case VerificationStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case VerificationStatus.unverified:
        statusColor = AppColors.error;
        statusIcon = Icons.gpp_bad_rounded;
        break;
    }

    return _buildCard(
      title: 'VERIFICATION STATUS',
      icon: Icons.security_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.verificationStatus.name.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Identity verification is ${user.verificationStatus.name}',
                        style: TextStyle(
                            fontSize: 12,
                            color: statusColor.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Review KYC Documents',
            Icons.assignment_ind_outlined,
            () => context.go('${AppRoutes.reviewKYc}/${user.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsCard(
      BuildContext context, UserModel user, WidgetRef ref) {
    return _buildCard(
      title: 'BANK ACCOUNTS',
      icon: Icons.account_balance_rounded,
      child: Column(
        children: [
          if (user.bankAccounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No bank accounts linked',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...user.bankAccounts.map((account) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () =>
                        _showBankVerificationSheet(context, account, user, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_outlined,
                                size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account.bankName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(account.accountNumber,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          _buildMiniBadge(
                            account.verificationStatus.name,
                            account.verificationStatus ==
                                    BankVerificationStatus.verified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showAdminDeleteBankAccountDialog(
                                context, account, user, ref),
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error, size: 20),
                            tooltip: 'Delete Account',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildApplicationsSection(BuildContext context,
      AsyncValue<List<LoanApplicationModel>> asyncApps, UserModel user) {
    return _buildCard(
      title: 'LOAN APPLICATIONS',
      icon: Icons.description_outlined,
      child: asyncApps.when(
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (apps) {
          if (apps.isEmpty)
            return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No applications found'));
          return Column(
            children:
                apps.map((app) => _buildApplicationItem(context, app)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildApplicationItem(BuildContext context, LoanApplicationModel app) {
    Color statusColor;
    switch (app.status) {
      case LoanStatus.approved:
        statusColor = AppColors.success;
        break;
      case LoanStatus.rejected:
        statusColor = AppColors.error;
        break;
      case LoanStatus.pending:
        statusColor = AppColors.warning;
        break;
    }

    return ListTile(
      onTap: () =>
          context.go('${AppRoutes.admin}/${app.id}?userId=${app.userId}'),
      contentPadding: EdgeInsets.zero,
      title: Text(
        Formatters.currency(app.loanAmount, app.countryCode),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        '${app.loanDuration} Months • ${Formatters.date(app.createdAt)}',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniBadge(app.status.name, statusColor),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsSection(BuildContext context,
      AsyncValue<List<WithdrawalModel>> asyncWithdrawals, UserModel user, WidgetRef ref) {
    return _buildCard(
      title: 'WITHDRAWAL HISTORY',
      icon: Icons.payments_outlined,
      child: asyncWithdrawals.when(
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (withdrawals) {
          if (withdrawals.isEmpty)
            return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No withdrawals found'));
          return Column(
            children: withdrawals
                .map((w) => _buildWithdrawalItem(context, ref, w))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalItem(
      BuildContext context, WidgetRef ref, WithdrawalModel withdrawal) {
    Color statusColor;
    switch (withdrawal.status) {
      case WithdrawalStatus.completed:
        statusColor = AppColors.success;
        break;
      case WithdrawalStatus.failed:
        statusColor = AppColors.error;
        break;
      case WithdrawalStatus.pending:
        statusColor = AppColors.warning;
        break;
      case WithdrawalStatus.processing:
        statusColor = Colors.blue;
        break;
    }

    return ListTile(
      onTap: () => _showWithdrawalStatusSheet(context, withdrawal, ref),
      contentPadding: EdgeInsets.zero,
      title: Text(
        Formatters.currency(withdrawal.amount, withdrawal.countryCode),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        'via ${withdrawal.bankName} • ${Formatters.date(withdrawal.createdAt)}',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniBadge(withdrawal.status.name, statusColor),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
        ],
      ),
    );
  }

  void _showWithdrawalStatusSheet(
      BuildContext context, WithdrawalModel withdrawal, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        bool isSubmitting = false;
        WithdrawalStatus? activeStatus;

        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            Future<void> updateStatus(WithdrawalStatus status) async {
              setModalState(() {
                isSubmitting = true;
                activeStatus = status;
              });
              try {
                await ref
                    .read(adminNotifierProvider.notifier)
                    .updateWithdrawalStatus(
                      withdrawalId: withdrawal.id,
                      status: status,
                    );
                ref.invalidate(userWithdrawalsProvider(withdrawal.userId));
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              } finally {
                if (sheetContext.mounted) {
                  setModalState(() {
                    isSubmitting = false;
                    activeStatus = null;
                  });
                }
              }
            }

            Widget statusButton(WithdrawalStatus status, String label, Color color,
                {bool isOutlined = false}) {
              final isLoading = isSubmitting && activeStatus == status;
              final isCurrent = withdrawal.status == status;

              if (isOutlined) {
                return OutlinedButton(
                  onPressed: isSubmitting || isCurrent ? null : () => updateStatus(status),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    foregroundColor: color,
                    side: BorderSide(color: color),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(label),
                );
              }

              return ElevatedButton(
                onPressed: isSubmitting || isCurrent ? null : () => updateStatus(status),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(label),
              );
            }

            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Withdrawal Status',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(
                    'Update status for ${Formatters.currency(withdrawal.amount, withdrawal.countryCode)} withdrawal',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _detailRowItem('Bank Name', withdrawal.bankName),
                  _detailRowItem('Account Number', withdrawal.accountNumber),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: statusButton(
                                  WithdrawalStatus.pending, 'Pending', AppColors.warning)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: statusButton(
                                  WithdrawalStatus.processing, 'Processing', Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: statusButton(
                                  WithdrawalStatus.completed, 'Complete', AppColors.success)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: statusButton(
                                  WithdrawalStatus.failed, 'Fail', AppColors.error)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF001E40))),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          foregroundColor: const Color(0xFF001E40),
          textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

void _showBankVerificationSheet(
    BuildContext context, BankAccount account, UserModel user, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) {
      bool isSubmitting = false;
      String? activeAction;

      return StatefulBuilder(
        builder: (sheetContext, setModalState) {
          Future<void> runAction({
            required String actionKey,
            required Future<void> Function() action,
          }) async {
            setModalState(() {
              isSubmitting = true;
              activeAction = actionKey;
            });
            try {
              await action();
              ref.invalidate(userByIdProvider(user.id));
              if (sheetContext.mounted) Navigator.pop(sheetContext);
            } finally {
              if (sheetContext.mounted) {
                setModalState(() {
                  isSubmitting = false;
                  activeAction = null;
                });
              }
            }
          }

          Widget actionLabel(String actionKey, String text) {
            final isLoading = isSubmitting && activeAction == actionKey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(isLoading ? '$text...' : text),
              ],
            );
          }

          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank Verification',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 24),
                _detailRowItem('Bank Name', account.bankName),
                _detailRowItem('Account Number', account.accountNumber),
                _detailRowItem('Account Name', account.accountName),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: account.verificationStatus ==
                                    BankVerificationStatus.verified ||
                                isSubmitting
                            ? null
                            : () => runAction(
                                  actionKey: 'verify',
                                  action: () => ref
                                      .read(adminNotifierProvider.notifier)
                                      .updateBankVerificationStatus(
                                        userId: user.id,
                                        bankAccountId: account.id,
                                        status: BankVerificationStatus.verified,
                                      ),
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: actionLabel('verify', 'Verify'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: account.verificationStatus ==
                                    BankVerificationStatus.unverified ||
                                isSubmitting
                            ? null
                            : () => runAction(
                                  actionKey: 'unverify',
                                  action: () => ref
                                      .read(adminNotifierProvider.notifier)
                                      .updateBankVerificationStatus(
                                        userId: user.id,
                                        bankAccountId: account.id,
                                        status:
                                            BankVerificationStatus.unverified,
                                      ),
                                ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: account.verificationStatus ==
                                  BankVerificationStatus.unverified
                              ? AppColors.error
                              : Colors.transparent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: actionLabel('unverify', 'Unverify'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: account.verificationStatus ==
                                    BankVerificationStatus.pending ||
                                isSubmitting
                            ? null
                            : () => runAction(
                                  actionKey: 'pending',
                                  action: () => ref
                                      .read(adminNotifierProvider.notifier)
                                      .updateBankVerificationStatus(
                                        userId: user.id,
                                        bankAccountId: account.id,
                                        status: BankVerificationStatus.pending,
                                      ),
                                ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.pending,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: actionLabel('pending', 'Pending'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _detailRowItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700)),
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

void _showAdminDeleteBankAccountDialog(
    BuildContext context, BankAccount account, UserModel user, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Bank Account',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          'Are you sure you want to delete this bank account (${account.bankName} - ${account.accountNumber}) for user ${user.fullName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            CustomPopup.show(
              context,
              title: 'Processing',
              message: 'Deleting bank account...',
              isWarning: false,
            );

            try {
              await ref
                  .read(adminNotifierProvider.notifier)
                  .deleteUserBankAccount(
                    userId: user.id,
                    bankAccountId: account.id,
                  );

              if (context.mounted) {
                CustomPopup.show(
                  context,
                  title: 'Success',
                  message: 'Bank account deleted successfully',
                  isWarning: false,
                );
              }
            } catch (e) {
              if (context.mounted) {
                CustomPopup.show(
                  context,
                  title: 'Error',
                  message: 'Error deleting bank account: $e',
                  isWarning: true,
                );
              }
            }
          },
          child: const Text('DELETE',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.error)),
        ),
      ],
    ),
  );
}

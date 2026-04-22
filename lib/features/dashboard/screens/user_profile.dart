import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1024) {
          return _MobileProfileView(
            user: user,
            onLogout: _handleLogout,
          );
        }
        return _DesktopProfileView(
          user: user,
          onLogout: _handleLogout,
        );
      },
    );
  }
}

// ── Desktop View ─────────────────────────────────────────────────────────────

class _DesktopProfileView extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const _DesktopProfileView({
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildSharedDrawer(context, user, onLogout),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 260,
            color: AppColors.backgroundDark,
            child: _buildSidebar(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopNavBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 48),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildPersonalInfoSection(context),
                                      const SizedBox(height: 32),
                                      _buildKYCManagementSection(context),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildBankAccountsSection(context),
                                      const SizedBox(height: 32),
                                      _buildSupportSection(context),
                                      const SizedBox(height: 48),
                                      _buildLogoutAction(context),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aemo Finance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'AEMO LOAN APP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary.withOpacity(0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        _SidebarItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          onTap: () => context.go(AppRoutes.dashboard),
        ),
        _SidebarItem(
          icon: Icons.description_outlined,
          label: 'Apply for Loan',
          onTap: () => context.go(AppRoutes.apply),
        ),
        _SidebarItem(
          icon: Icons.summarize_outlined,
          label: 'Applications',
          onTap: () => context.go(AppRoutes.userApplications),
        ),
        _SidebarItem(
          icon: Icons.calculate_outlined,
          label: 'Calculator',
          onTap: () => context.go(AppRoutes.calculator),
        ),
        _SidebarItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Withdrawals',
          onTap: () => context.go(AppRoutes.withdrawals),
        ),
        _SidebarItem(
          icon: Icons.person_outlined,
          label: 'Profile',
          isActive: true,
          onTap: () => context.go(AppRoutes.profile),
        ),
        const Spacer(),
        const Divider(),
        _SidebarItem(
          icon: Icons.logout,
          label: 'Log Out',
          color: AppColors.error,
          onTap: onLogout,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Builder(
          //   builder: (context) => IconButton(
          //     icon:
          //         const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          //     onPressed: () => Scaffold.of(context).openDrawer(),
          //   ),
          // ),
          const SizedBox(width: 12),
          Text(
            'Profile Settings',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 20),
          const Icon(Icons.help_outline_rounded,
              color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            backgroundImage:
                user.selfieUrl != null && user.selfieUrl!.isNotEmpty
                    ? NetworkImage(user.selfieUrl!)
                    : null,
            child: user.selfieUrl == null || user.selfieUrl!.isEmpty
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 16,
                            color: _kycStatusColor(user.verificationStatus)),
                        const SizedBox(width: 8),
                        Text(
                          'KYC ${user.verificationStatus.name.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text('Edit Profile',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    final address = [user.streetAddress, user.city, user.state, user.postalCode]
        .where((s) => s.isNotEmpty)
        .join(', ');
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PERSONAL INFORMATION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary, size: 24),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                  child: _buildSharedDataField('FULL NAME', user.fullName)),
              Expanded(
                  child: _buildSharedDataField(
                      'DATE JOINED', Formatters.date(user.createdAt))),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _buildSharedDataField('NATIONALITY',
                      user.countryName.isEmpty ? 'Not set' : user.countryName)),
              Expanded(child: _buildSharedDataField('ID NUMBER', 'Not set')),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 40),
          Text(
            'CONTACT DETAILS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _buildSharedDataField('MOBILE NUMBER',
                      user.phone.isEmpty ? 'Not set' : user.phone)),
              Expanded(
                  child: _buildSharedDataField('RESIDENTIAL ADDRESS',
                      address.isEmpty ? 'Not set' : address)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKYCManagementSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KYC MANAGEMENT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.badge_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Identity Verification',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(
                        user.verificationStatus == VerificationStatus.verified
                            ? 'Verified on ${Formatters.date(user.createdAt)}'
                            : user.verificationStatus ==
                                    VerificationStatus.pending
                                ? 'Verification pending'
                                : 'Not yet verified',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      user.verificationStatus != VerificationStatus.verified
                          ? context.go(AppRoutes.kyc)
                          : context.go(AppRoutes.kycStatus),
                  child: Text(
                    'VIEW CERTIFICATE',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'BANK ACCOUNTS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, _) => SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showAddBankAccountSheet(context, ref, user),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('LINK NEW',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (user.bankAccounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                  child: Text('No accounts linked',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary, fontSize: 15))),
            )
          else
            ...user.bankAccounts
                .map((account) => _buildBankAccountItem(account)),
        ],
      ),
    );
  }

  Widget _buildBankAccountItem(BankAccount account) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.account_balance_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.bankName,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '**** ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber} • ${account.accountName}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(account.verificationStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BankVerificationStatus status) {
    final isVerified = status == BankVerificationStatus.verified;
    final isPending = status == BankVerificationStatus.pending;
    Color bg = isVerified
        ? AppColors.successLight
        : isPending
            ? AppColors.warningLight
            : AppColors.errorLight;
    Color fg = isVerified
        ? AppColors.success
        : isPending
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our dedicated support team is available 24/7 for premium account holders.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('CONTACT SUPPORT',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutAction(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout, color: AppColors.error, size: 22),
        label: Text(
          'SECURE LOG OUT',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: AppColors.error,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _kycStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.unverified:
        return AppColors.error;
    }
  }
}

// ── Mobile View ──────────────────────────────────────────────────────────────

class _MobileProfileView extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const _MobileProfileView({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      drawer: _buildSharedDrawer(context, user, onLogout),
      body: Consumer(
        builder: (context, ref, _) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            await ref.read(currentUserProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeroCard(context, ref),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _sectionLabel('PERSONAL INFORMATION'),
                      const SizedBox(height: 10),
                      _buildPersonalInfoCard(context),
                      const SizedBox(height: 24),
                      _sectionLabel('CONTACT DETAILS'),
                      const SizedBox(height: 10),
                      _buildContactCard(context),
                      const SizedBox(height: 24),
                      _buildLinkedAccountsHeader(context, ref),
                      const SizedBox(height: 10),
                      if (user.bankAccounts.isNotEmpty)
                        _buildBankAccountsCard(context),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${AppStrings.appName} — Secured with 256-bit encryption',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildHeroCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryDark,
                backgroundImage:
                    user.selfieUrl != null && user.selfieUrl!.isNotEmpty
                        ? NetworkImage(user.selfieUrl!)
                        : null,
                child: user.selfieUrl == null || user.selfieUrl!.isEmpty
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      )
                    : null,
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                            color: _kycStatusColor(user.verificationStatus),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            size: 9, color: Colors.white),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'KYC ${user.verificationStatus.name.toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(user.fullName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Text(user.email,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: Colors.white),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _gridField('FULL NAME', user.fullName)),
                Expanded(
                    child: _gridField(
                        'NATIONALITY',
                        user.countryName.isEmpty
                            ? 'Not set'
                            : user.countryName)),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _gridField('PHONE', user.phone)),
                Expanded(child: _gridField('EMAIL', user.email)),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          InkWell(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            onTap: switch (user.verificationStatus) {
              VerificationStatus.pending => () =>
                  context.go('${AppRoutes.kycStatus}/${user.id}'),
              VerificationStatus.unverified => () => context.go(AppRoutes.kyc),
              VerificationStatus.verified => () =>
                  context.go('${AppRoutes.kycStatus}/${user.id}'),
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16))),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KYC Status',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                        Text(
                          user.verificationStatus == VerificationStatus.verified
                              ? 'Verified — tap to view'
                              : user.verificationStatus ==
                                      VerificationStatus.pending
                                  ? 'Pending — tap to check status'
                                  : 'Not verified — tap to start KYC',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kycStatusColor(user.verificationStatus)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final address = [user.streetAddress, user.city, user.state, user.postalCode]
        .where((s) => s.isNotEmpty)
        .join(', ');
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_android_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MOBILE NUMBER',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHint,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(user.phone.isEmpty ? 'Not set' : user.phone,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RESIDENTIAL ADDRESS',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHint,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(address.isEmpty ? 'Not set' : address,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                              height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedAccountsHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionLabel('LINKED ACCOUNTS'),
        GestureDetector(
          onTap: () => _showAddBankAccountSheet(context, ref, user),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        children: user.bankAccounts.asMap().entries.map((entry) {
          final isLast = entry.key == user.bankAccounts.length - 1;
          final account = entry.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_outlined,
                          color: AppColors.primaryDark, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.bankName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark)),
                          Text(
                              '**** ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    _mobileBankStatusBadge(account.verificationStatus),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 0.5,
                    color: AppColors.border,
                    indent: 20,
                    endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.errorLight, width: 0.5)),
      child: TextButton.icon(
        onPressed: onLogout,
        icon:
            const Icon(Icons.logout_outlined, color: AppColors.error, size: 18),
        label: const Text(' Log Out',
            style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
            letterSpacing: 1.4));
  }

  Widget _gridField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value.isEmpty ? '—' : value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark),
            overflow: TextOverflow.ellipsis,
            maxLines: 2),
      ],
    );
  }

  Widget _mobileBankStatusBadge(BankVerificationStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case BankVerificationStatus.verified:
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = 'VERIFIED';
        break;
      case BankVerificationStatus.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        label = 'PENDING';
        break;
      default:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        label = 'UNVERIFIED';
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.5)));
  }

  Color _kycStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.unverified:
        return AppColors.error;
    }
  }
}

// ── Shared Widgets & Helpers ──────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem(
      {required this.icon,
      required this.label,
      this.isActive = false,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: color ??
                      (isActive ? AppColors.primary : AppColors.textSecondary),
                  size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: color ??
                        (isActive
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  const _DrawerItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color,
      this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color:
              color ?? (isActive ? AppColors.primary : AppColors.textPrimary),
          size: 22),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: color ??
                  (isActive ? AppColors.primary : AppColors.textPrimary))),
      onTap: onTap,
    );
  }
}

Widget _buildSharedDrawer(
    BuildContext context, UserModel user, VoidCallback onLogout) {
  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      user.selfieUrl != null && user.selfieUrl!.isNotEmpty
                          ? NetworkImage(user.selfieUrl!)
                          : null,
                  child: user.selfieUrl == null || user.selfieUrl!.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(user.email,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.dashboard);
              }),
          _DrawerItem(
              icon: Icons.description_outlined,
              label: 'Apply for Loan',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.apply);
              }),
          _DrawerItem(
              icon: Icons.summarize_outlined,
              label: 'Applications',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.userApplications);
              }),
          _DrawerItem(
              icon: Icons.calculate_outlined,
              label: 'Calculator',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.calculator);
              }),
          _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Withdrawals',
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.withdrawals);
              }),
          _DrawerItem(
              icon: Icons.person_outlined,
              label: 'Profile',
              isActive: true,
              onTap: () {
                Navigator.pop(context);
              }),
          const Spacer(),
          const Divider(),
          _DrawerItem(
              icon: Icons.logout,
              label: 'Log Out',
              color: AppColors.error,
              onTap: onLogout),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildSharedDataField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

// ── Add Bank Account Sheet ────────────────────────────────────────────────────

void _showAddBankAccountSheet(
    BuildContext context, WidgetRef ref, UserModel user) {
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final currentUser = ref.read(currentUserProvider).value;
  final countryCode = currentUser?.countryCode ?? 'BZ';
  final banks = AppStrings.banksByCountry[countryCode] ?? [];
  String selectedBank = banks.isNotEmpty ? banks.first : '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: StatefulBuilder(
        builder: (context, setModalState) => Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Bank Account',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 20),
              const Text('Bank Name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedBank.isEmpty ? null : selectedBank,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                ),
                items: banks
                    .map((bank) =>
                        DropdownMenuItem(value: bank, child: Text(bank)))
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => selectedBank = value!),
                validator: (value) =>
                    value == null ? 'Please select a bank' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Account Number',
                hint: 'Enter account number',
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Account number is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Account Name',
                hint: 'Enter account name',
                controller: accountNameController,
                prefixIcon: const Icon(Icons.person_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Account name is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newAccount = BankAccount(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      bankName: selectedBank,
                      accountNumber: accountNumberController.text.trim(),
                      accountName: accountNameController.text.trim(),
                      verificationStatus: BankVerificationStatus.pending,
                    );
                    final updatedAccounts = [...user.bankAccounts, newAccount];
                    final updatedUser =
                        user.copyWith(bankAccounts: updatedAccounts);
                    await ref
                        .read(firestoreServiceProvider)
                        .updateUser(updatedUser);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

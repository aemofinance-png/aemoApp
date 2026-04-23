import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../../app/router.dart';
import '../../auth/providers/auth_provider.dart';

final allUsersProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
  return ref.read(firestoreServiceProvider).getAllUsers();
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  VerificationStatus? _statusFilter;

  Future<void> _handleLogout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          final filtered = users
              .where((u) => u.role != 'admin')
              .where((u) =>
                  _statusFilter == null || u.verificationStatus == _statusFilter)
              .where((u) =>
                  _searchQuery.isEmpty ||
                  u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              
              return Row(
                children: [
                  if (isDesktop) _buildSidebar(context),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopAppBar(context, !isDesktop),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            children: [
                              // Header Section
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: _buildHeaderSection(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Search & Filters
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: _buildSearchAndFilters(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // User List
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: filtered.isEmpty
                                        ? _buildEmptyState()
                                        : Column(
                                            children: filtered.asMap().entries.map((entry) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 16),
                                                child: _buildUserCard(context, entry.value, entry.key),
                                              );
                                            }).toList(),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Footer
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 500),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: _buildPaginationInfo(filtered.length, users.length),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFFF2F4F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'ADMIN CONSOLE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => context.go(AppRoutes.admin),
          ),
          _SidebarItem(
            icon: Icons.payments_outlined,
            label: 'Withdrawals',
            onTap: () => context.go(AppRoutes.adminWithdrawals),
          ),
          _SidebarItem(
            icon: Icons.group_outlined,
            label: 'Users',
            isActive: true,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.analytics_outlined,
            label: 'Reports',
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: AppColors.error,
            onTap: _handleLogout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool showLogo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showLogo) ...[
            IconButton(
              onPressed: () => context.go(AppRoutes.admin),
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF001E40)),
            ),
            const SizedBox(width: 8),
            Text(
              'Admin Ledger',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40),
                letterSpacing: -0.5,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF001E40), size: 20),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBUmfAuZIfZTpsWDpOf6631nQzI2H5EdMTF8EXGzbhHNbwDSkpL0WIG1A9jCRr7um99F42GdX1AM5tStvCj8oD6AqwkUfJI4Z0ZmM8dCNO7zaOURKd8dnKTsxImB0Mh_QEi8RY0D-JdsfzABo1yPBt7Sdql46H1RiMfeOl5tdLbEazRgs6BehoRgutuen3uLke9ZB80nZwRDelgUDLdQSC8rZ8UYTjM2kEe_Gi4I8uXb7xgV_vOhUS4ceLKEtgKKwk00LXp4h6zmYMn'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (showLogo) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Users',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF001E40),
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E8EA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF737780).withValues(alpha: 0.6),
                  fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF737780), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', null),
              const SizedBox(width: 8),
              _buildFilterChip('Verified', VerificationStatus.verified),
              const SizedBox(width: 8),
              _buildFilterChip('Pending', VerificationStatus.pending),
              const SizedBox(width: 8),
              _buildFilterChip('Unverified', VerificationStatus.unverified),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VerificationStatus? status) {
    final isSelected = _statusFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF001E40) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF525F75),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, int index) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    switch (user.verificationStatus) {
      case VerificationStatus.verified:
        statusBg = const Color(0xFFD5E3FF).withValues(alpha: 0.3);
        statusText = const Color(0xFF1F477B);
        statusLabel = 'Verified';
        break;
      case VerificationStatus.pending:
        statusBg = const Color(0xFFFFDBCA).withValues(alpha: 0.3);
        statusText = const Color(0xFFD8885C);
        statusLabel = 'Pending';
        break;
      case VerificationStatus.unverified:
        statusBg = const Color(0xFFFFDAD6).withValues(alpha: 0.3);
        statusText = const Color(0xFFBA1A1A);
        statusLabel = 'Unverified';
        break;
    }

    return GestureDetector(
      onTap: () => context.go('${AppRoutes.adminUserProfile}/${user.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: user.selfieUrl != null &&
                                user.selfieUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.selfieUrl!),
                                fit: BoxFit.cover)
                            : null,
                        color: const Color(0xFFF2F4F6),
                      ),
                      child: user.selfieUrl == null || user.selfieUrl!.isEmpty
                          ? Center(
                              child: Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF001E40))))
                          : null,
                    ),
                    if (user.verificationStatus == VerificationStatus.verified)
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E3FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check,
                              size: 10, color: Color(0xFF001E40)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF191C1E)),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: statusText,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert_rounded,
                    color: Color(0xFF737780), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildInfoRow(Icons.mail_outline_rounded, user.email),
                const SizedBox(height: 8),
                _buildInfoRow(
                  user.verificationStatus == VerificationStatus.verified
                      ? Icons.schedule_rounded
                      : Icons.history_rounded,
                  user.verificationStatus == VerificationStatus.verified
                      ? 'Last active: 2 hours ago'
                      : 'Created: ${Formatters.date(user.createdAt)}',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF43474F)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF43474F)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationInfo(int current, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ARCHITECTURE',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF737780),
                  letterSpacing: 2),
            ),
            const SizedBox(height: 4),
            Text(
              'Showing $current of $total users',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF43474F)),
            ),
          ],
        ),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 0,
            ),
            child: Text('Load More',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.group_outlined,
              color: const Color(0xFF001E40).withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 24),
          Text(
            'No users found',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF001E40)),
          ),
          const SizedBox(height: 8),
          Text(
            'Refine your search or filter criteria',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF737780),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    this.color,
  });

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
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ?? (isActive ? AppColors.primary : AppColors.textSecondary),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: color ?? (isActive ? AppColors.primary : AppColors.textSecondary),
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

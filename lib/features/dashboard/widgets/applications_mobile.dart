import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/loan_application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../app/router.dart';

class ApplicationsMobile extends StatelessWidget {
  final UserModel? currentUser;
  final List<LoanApplicationModel> applications;
  final List<LoanApplicationModel> filtered;
  final LoanStatus? selectedFilter;
  final Function(LoanStatus?) onFilterChanged;
  final AnimationController listAnimationController;
  final VoidCallback onLogout;

  const ApplicationsMobile({
    super.key,
    required this.currentUser,
    required this.applications,
    required this.filtered,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.listAnimationController,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilterTabs(),
            const SizedBox(height: 24),
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ...filtered.asMap().entries.map((entry) {
                final index = entry.key;
                final app = entry.value;

                return _ApplicationCard(
                  application: app,
                  countryCode: currentUser?.countryCode ?? 'BZ',
                  index: index,
                  animationController: listAnimationController,
                );
              }),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.apply),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'NEW LOAN',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      }),
      centerTitle: false,
      title: Text(
        'Aemo Finance',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: AppColors.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: currentUser?.selfieUrl != null && currentUser!.selfieUrl!.isNotEmpty
                  ? NetworkImage(currentUser!.selfieUrl!)
                  : null,
              child: currentUser?.selfieUrl == null || currentUser!.selfieUrl!.isEmpty
                  ? Text(
                      currentUser?.fullName.isNotEmpty ?? false ? currentUser!.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
                    backgroundImage: currentUser?.selfieUrl != null && currentUser!.selfieUrl!.isNotEmpty
                        ? NetworkImage(currentUser!.selfieUrl!)
                        : null,
                    child: currentUser?.selfieUrl == null || currentUser!.selfieUrl!.isEmpty
                        ? Text(
                            currentUser?.fullName.isNotEmpty ?? false ? currentUser!.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(currentUser?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(currentUser?.email ?? '', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', onTap: () { Navigator.pop(context); context.go(AppRoutes.dashboard); }),
            _DrawerItem(icon: Icons.description_outlined, label: 'Apply for Loan', onTap: () { Navigator.pop(context); context.go(AppRoutes.apply); }),
            _DrawerItem(icon: Icons.summarize_outlined, label: 'Applications', isActive: true, onTap: () { Navigator.pop(context); }),
            _DrawerItem(icon: Icons.calculate_outlined, label: 'Calculator', onTap: () { Navigator.pop(context); context.go(AppRoutes.calculator); }),
            _DrawerItem(icon: Icons.account_balance_wallet_outlined, label: 'Withdrawals', onTap: () { Navigator.pop(context); context.go(AppRoutes.withdrawals); }),
            _DrawerItem(icon: Icons.person_outlined, label: 'Profile', onTap: () { Navigator.pop(context); context.go(AppRoutes.profile); }),
            const Spacer(),
            const Divider(),
            _DrawerItem(icon: Icons.logout, label: 'Log Out', color: AppColors.error, onTap: onLogout),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ACTIVE PORTFOLIO REVIEW',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary.withOpacity(0.7),
            letterSpacing: 1.2,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterTab(label: 'ALL', isSelected: selectedFilter == null, onTap: () => onFilterChanged(null)),
          const SizedBox(width: 8),
          _FilterTab(label: 'PENDING', isSelected: selectedFilter == LoanStatus.pending, onTap: () => onFilterChanged(LoanStatus.pending)),
          const SizedBox(width: 8),
          _FilterTab(label: 'APPROVED', isSelected: selectedFilter == LoanStatus.approved, onTap: () => onFilterChanged(LoanStatus.approved)),
          const SizedBox(width: 8),
          _FilterTab(label: 'REJECTED', isSelected: selectedFilter == LoanStatus.rejected, onTap: () => onFilterChanged(LoanStatus.rejected)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              'No applications found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your history will appear here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final LoanApplicationModel application;
  final String countryCode;
  final int index;
  final AnimationController animationController;

  const _ApplicationCard({
    required this.application,
    required this.countryCode,
    required this.index,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.status}/${application.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOAN APPLICATION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              application.loanPurpose,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REQUESTED AMOUNT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(application.loanAmount, countryCode),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SUBMISSION DATE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.date(application.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: (index * 100).ms,
        ).slideY(begin: 0.1, end: 0);
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundDark : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            letterSpacing: 0.5,
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

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? (isActive ? AppColors.primary : AppColors.textPrimary), size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: color ?? (isActive ? AppColors.primary : AppColors.textPrimary),
        ),
      ),
      onTap: onTap,
      selected: isActive,
      selectedTileColor: AppColors.primaryLight.withOpacity(0.1),
    );
  }
}

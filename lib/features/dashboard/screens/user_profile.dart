import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';
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
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          _buildNavbar(context, ref, user),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserProvider);
                await ref.read(currentUserProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── Hero / avatar card ──────────────────────────────
                    _buildHeroCard(context, ref, user),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // ── Personal Information ──────────────────────
                          _sectionLabel('PERSONAL INFORMATION'),
                          const SizedBox(height: 10),
                          _buildPersonalInfoCard(context, ref, user),

                          const SizedBox(height: 24),

                          // ── Contact Details ───────────────────────────
                          _sectionLabel('CONTACT DETAILS'),
                          const SizedBox(height: 10),
                          _buildContactCard(context, user),

                          const SizedBox(height: 24),

                          // ── Bank Accounts ─────────────────────────────
                          _buildLinkedAccountsHeader(context, ref, user),
                          const SizedBox(height: 10),
                          if (user.bankAccounts.isNotEmpty)
                            _buildBankAccountsCard(context, user),

                          const SizedBox(height: 32),

                          // ── Log out ───────────────────────────────────
                          _buildLogoutButton(context, ref),

                          const SizedBox(height: 20),

                          Center(
                            child: Text(
                              '${AppStrings.appName} — Secured with 256-bit encryption',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFCBD5E1),
                              ),
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
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navbar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNavbar(BuildContext context, WidgetRef ref, UserModel user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.dashboard),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Color(0xFF0D1B3E)),
            ),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B3E),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_outlined,
                size: 18, color: Color(0xFF0D1B3E)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hero / Avatar Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, WidgetRef ref, UserModel user) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        children: [
          // Avatar with KYC badge
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFF0D1B3E),
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
                          color: Colors.white,
                        ),
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
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
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
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 9, color: Colors.white),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'KYC ${user.verificationStatus.name.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B3E),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Name & email
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 18),

          // Edit Profile button (commented-out in original — kept but wired)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: navigate to edit profile
              },
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: Colors.white),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B3E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Personal Information Card  (grid layout + KYC row)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPersonalInfoCard(
      BuildContext context, WidgetRef ref, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        children: [
          // Row 1: Full name / Nationality
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
          const Divider(height: 0.5, color: Color(0xFFF1F5F9)),

          // Row 2: Phone / Email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _gridField('PHONE', user.phone)),
                Expanded(child: _gridField('EMAIL', user.email)),
              ],
            ),
          ),
          const Divider(height: 0.5, color: Color(0xFFF1F5F9)),

          // KYC row — tappable, navigates to KYC screen
          InkWell(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            onTap: switch (user.verificationStatus) {
              VerificationStatus.pending => () {
                  context.go('${AppRoutes.kycStatus}/${user.id}');
                },
              VerificationStatus.unverified => () {
                  context.go(AppRoutes.kyc);
                },
              VerificationStatus.verified => () {
                  context.go('${AppRoutes.kycStatus}/${user.id}');
                },
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Color(0xFF4F46E5), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KYC Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D1B3E),
                          ),
                        ),
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
                            color: _kycStatusColor(user.verificationStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Contact Details Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContactCard(BuildContext context, UserModel user) {
    final address = [
      user.streetAddress,
      user.city,
      user.state,
      user.postalCode,
    ].where((s) => s.isNotEmpty).join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_android_outlined,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MOBILE NUMBER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone.isEmpty ? 'Not set' : user.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D1B3E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RESIDENTIAL ADDRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.isEmpty ? 'Not set' : address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D1B3E),
                          height: 1.5,
                        ),
                      ),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Linked Accounts header row + card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLinkedAccountsHeader(
      BuildContext context, WidgetRef ref, UserModel user) {
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
              color: const Color(0xFF0D1B3E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountsCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
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
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_outlined,
                          color: Color(0xFF0D1B3E), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.bankName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D1B3E),
                            ),
                          ),
                          Text(
                            '**** ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _bankStatusBadge(account.verificationStatus),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 0.5,
                    color: Color(0xFFF1F5F9),
                    indent: 20,
                    endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Log Out button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA), width: 0.5),
      ),
      child: TextButton.icon(
        onPressed: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go(AppRoutes.login);
        },
        icon: const Icon(Icons.logout_outlined,
            color: Color(0xFFDC2626), size: 18),
        label: const Text(
          ' Log Out',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Small helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _gridField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1B3E),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _bankStatusBadge(BankVerificationStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case BankVerificationStatus.verified:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'VERIFIED';
        break;
      case BankVerificationStatus.unverified:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'UNVERIFIED';
        break;
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'UNVERIFIED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _kycStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const Color(0xFF16A34A);
      case VerificationStatus.pending:
        return const Color(0xFFCA8A04);
      case VerificationStatus.unverified:
        return const Color(0xFFDC2626);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _detailRow  (kept for any future use, untouched)
// ─────────────────────────────────────────────────────────────────────────────

Widget _detailRow(BuildContext context, String label, String value) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Add Bank Account bottom sheet  (logic unchanged)
// ─────────────────────────────────────────────────────────────────────────────

void _showAddBankAccountSheet(
    BuildContext context, WidgetRef ref, UserModel user) {
  final bankController = TextEditingController();
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) => Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Bank Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1B3E),
                ),
              ),
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
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                items: banks
                    .map((bank) => DropdownMenuItem(
                          value: bank,
                          child: Text(bank),
                        ))
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
                    backgroundColor: const Color(0xFF0D1B3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

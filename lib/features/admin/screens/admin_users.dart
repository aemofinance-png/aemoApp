import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';
import '../../../app/router.dart';

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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B3E)),
          onPressed: () => context.go(AppRoutes.admin),
        ),
        title: const Text(
          'Registered Users',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B3E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0D1B3E)),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          // Filter out admins and apply search
          final filtered = users
              .where((u) => u.role != 'admin')
              .where((u) =>
                  _searchQuery.isEmpty ||
                  u.fullName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  u.phone.contains(_searchQuery))
              .toList();

          return Column(
            children: [
              // ── Search bar ──────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Search by name, email or phone...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: Icon(Icons.search,
                                color: Color(0xFF94A3B8), size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats row ────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    _buildStatChip(
                      'Total',
                      filtered.length.toString(),
                      const Color(0xFF0D1B3E),
                      const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      'Verified',
                      filtered
                          .where((u) =>
                              u.verificationStatus ==
                              VerificationStatus.verified)
                          .length
                          .toString(),
                      const Color(0xFF16A34A),
                      const Color(0xFFDCFCE7),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      'Pending',
                      filtered
                          .where((u) =>
                              u.verificationStatus ==
                              VerificationStatus.pending)
                          .length
                          .toString(),
                      const Color(0xFFCA8A04),
                      const Color(0xFFFEF9C3),
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      'Unverified',
                      filtered
                          .where((u) =>
                              u.verificationStatus ==
                              VerificationStatus.unverified)
                          .length
                          .toString(),
                      const Color(0xFFDC2626),
                      const Color(0xFFFEE2E2),
                    ),
                  ],
                ),
              ),

              const Divider(height: 0.5, color: Color(0xFFE2E8F0)),

              // ── User list ────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allUsersProvider),
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildUserCard(context, filtered[index]),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return GestureDetector(
      onTap: () => context.go('${AppRoutes.adminUserProfile}/${user.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B3E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          user.countryName.isEmpty
                              ? user.countryCode
                              : user.countryName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.date(user.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // KYC badge + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildKycBadge(user.verificationStatus),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycBadge(VerificationStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case VerificationStatus.verified:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'VERIFIED';
        break;
      case VerificationStatus.pending:
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFFCA8A04);
        label = 'PENDING';
        break;
      case VerificationStatus.unverified:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'UNVERIFIED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: fg.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.people_outline,
                color: Color(0xFF0D1B3E), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registered users will appear here',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

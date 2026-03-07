import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';
import '../providers/admin_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/service_providers.dart';
import '../screens/admin_user_profile.dart';
import '../screens/document_viewer_screen.dart';
import '../../../app/router.dart';

class KycApprovalScreen extends ConsumerWidget {
  final String userId;
  const KycApprovalScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }
        return _KycApprovalContent(user: user);
      },
    );
  }
}

class _KycApprovalContent extends ConsumerStatefulWidget {
  final UserModel user;
  const _KycApprovalContent({required this.user});

  @override
  ConsumerState<_KycApprovalContent> createState() =>
      _KycApprovalContentState();
}

class _KycApprovalContentState extends ConsumerState<_KycApprovalContent> {
  // Toggle between document types if multiple exist
  int _selectedDocIndex = 0;

  final List<String> _docLabels = ['PASSPORT', 'ID CARD', 'SELFIE'];

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final docUrls = <String>[
      if (user.idDocumentUrl != null && user.idDocumentUrl!.isNotEmpty)
        user.idDocumentUrl!,
      if (user.selfieUrl != null && user.selfieUrl!.isNotEmpty) user.selfieUrl!,
    ];

    final hasDoc = docUrls.isNotEmpty;
    final currentDocUrl =
        hasDoc ? docUrls[_selectedDocIndex.clamp(0, docUrls.length - 1)] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.admin),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'KYC Approval',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'AEMO Finance Admin',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // USER INFORMATION label
                  const Text(
                    'USER INFORMATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: user.selfieUrl != null &&
                                  user.selfieUrl!.isNotEmpty
                              ? NetworkImage(user.selfieUrl!)
                              : null,
                          child:
                              user.selfieUrl == null || user.selfieUrl!.isEmpty
                                  ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // KYC ID + Submitted date row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.fingerprint,
                          value:
                              '#KYC-${user.id.substring(0, 8).toUpperCase()}',
                          label: 'Application ID',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_outlined,
                          value: _formatDate(user.createdAt),
                          label: 'Submitted Date',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // DOCUMENT PREVIEW label + doc type badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DOCUMENT PREVIEW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
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
                          user.verificationStatus.name.toUpperCase(),
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
                      if (hasDoc)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedDocIndex == 0 && docUrls.length > 1
                                ? 'PASSPORT'
                                : _selectedDocIndex == 1
                                    ? 'SELFIE'
                                    : 'PASSPORT',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Document image
                  GestureDetector(
                    onTap: currentDocUrl != null
                        ? () {
                            debugPrint('Viewing document: $currentDocUrl');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentViewerScreen(
                                  imageUrl: currentDocUrl,
                                  title: _selectedDocIndex == 0
                                      ? 'ID Document'
                                      : 'Selfie',
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasDoc && currentDocUrl != null
                          ? Image.network(
                              currentDocUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 48,
                                        color: AppColors.textSecondary),
                                    SizedBox(height: 8),
                                    Text('Failed to load document',
                                        style: TextStyle(
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.insert_drive_file_outlined,
                                      size: 48, color: AppColors.textSecondary),
                                  SizedBox(height: 8),
                                  Text('No document uploaded',
                                      style: TextStyle(
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // Doc switcher if multiple docs
                  if (docUrls.length > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(docUrls.length, (i) {
                        final selected = i == _selectedDocIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDocIndex = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 100),

                  // space for bottom buttons
                ],
              ),
            ),
          ),

          // Show current status badge
        ],
      ),

      // Bottom action buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Decline button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(adminNotifierProvider.notifier)
                      .updateKycStatus(
                        userId: user.id,
                        status: VerificationStatus.unverified,
                      );
                  if (context.mounted) context.go(AppRoutes.admin);
                },
                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                label: const Text(
                  'Decline',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Approve button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: user.verificationStatus == VerificationStatus.pending
                    ? () async {
                        await ref
                            .read(adminNotifierProvider.notifier)
                            .updateKycStatus(
                              userId: user.id,
                              status: VerificationStatus.verified,
                            );
                        debugPrint("$VerificationStatus");
                        if (context.mounted) context.go(AppRoutes.admin);
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(
                  'Approve KYC',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      user.verificationStatus == VerificationStatus.pending
                          ? AppColors.primary
                          : AppColors.primaryLight,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

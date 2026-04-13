import 'package:aemo_loan_app/data/models/loan_application_model.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/data/models/withdrawal_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/router.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  final LoanApplicationModel application;

  const WithdrawalScreen({super.key, required this.application});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  int _currentStep = 0;
  BankAccount? _selectedAccount;
  PlatformFile? _uploadedDocument;
  bool _isUploading = false;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.bankAccounts.isNotEmpty) {
        // Pre-select the account matching the application
        final match = user.bankAccounts.firstWhere(
          (a) => a.accountNumber == widget.application.accountNumber,
          orElse: () => user.bankAccounts.first,
        );
        setState(() => _selectedAccount = match);
      }
    });
  }

  Future<void> _pickAndUploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('withdrawal_documents')
          .child(widget.application.id)
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      await ref.putData(
        file.bytes!,
        SettableMetadata(contentType: _getContentType(file.extension)),
      );

      final url = await ref.getDownloadURL();

      setState(() {
        _uploadedDocument = file;
        _uploadedUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final countryCode = currentUser?.countryCode ?? 'BZ';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B3E)),
          onPressed: () =>
              context.go('${AppRoutes.status}/${widget.application.id}'),
        ),
        title: const Text(
          'Withdrawal',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1B3E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _currentStep == 0
                      ? _buildStep1(countryCode)
                      : _currentStep == 1
                          ? _buildStep2(currentUser)
                          : _buildStep3(countryCode),
                ),
              ),
            ),
          ),

          // Bottom button
          _buildBottomButton(countryCode),
        ],
      ),
    );
  }

  // ── Step Indicator ───────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = [
      'Upload Agreement',
      'Bank Verification',
      'Confirm Withdrawal'
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (i) {
              final isComplete = i < _currentStep;
              final isActive = i == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isComplete || isActive
                                ? const Color(0xFF0D1B3E)
                                : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isComplete
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[i].toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isActive || isComplete
                                ? const Color(0xFF0D1B3E)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isComplete)
                          const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < _currentStep
                              ? const Color(0xFF0D1B3E)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            'STEP ${_currentStep + 1}: ${[
              'UPLOAD AGREEMENT',
              'BANK VERIFICATION',
              'CONFIRM WITHDRAWAL'
            ][_currentStep]}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF0D1B3E),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Sign Agreement ───────────────────────────────
  Widget _buildStep1(String countryCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Verification Required for Withdrawal',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B3E),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'To ensure regulatory compliance and secure your funds, please review and upload your signed withdrawal agreement.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),

        // Loan agreement document row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined,
                  color: Color(0xFF0D1B3E), size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'LOAN_AGREEMENT.PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B3E),
                  ),
                ),
              ),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF0D1B3E),
              //     borderRadius: BorderRadius.circular(6),
              //   ),
              //   child: const Text(
              //     'READY\nTO SIGN',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 8,
              //       fontWeight: FontWeight.w700,
              //       color: Colors.white,
              //       height: 1.3,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Placeholder lines (simulating document preview)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 10,
                width: i == 3 ? 140 : double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Upload signed copy button
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadDocument,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0D1B3E),
                      ),
                    )
                  else
                    const Icon(Icons.upload_file_outlined,
                        color: Color(0xFF0D1B3E), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _isUploading
                        ? 'Uploading...'
                        : _uploadedDocument != null
                            ? _uploadedDocument!.name
                            : 'Upload Signed Copy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _uploadedDocument != null
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF0D1B3E),
                    ),
                  ),
                  if (_uploadedDocument != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle,
                        color: Color(0xFF16A34A), size: 16),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Encrypted badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENCRYPTED & SECURE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B3E),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your digital signature is legally binding and protected by 256-bit bank-grade encryption.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        height: 1.4,
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
  }

  // ── Step 2: Bank Verification ────────────────────────────
  Widget _buildStep2(UserModel? currentUser) {
    final accounts = currentUser?.bankAccounts ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Verify bank account',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B3E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a linked account or connect a new one to complete your withdrawal security check.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'LINKED ACCOUNTS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Account list
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              ...accounts.asMap().entries.map((entry) {
                final index = entry.key;
                final account = entry.value;
                final isSelected = _selectedAccount?.id == account.id;
                final isLast = index == accounts.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedAccount = account),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_balance_outlined,
                                  color: Color(0xFF0D1B3E), size: 20),
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
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0D1B3E),
                                    ),
                                  ),
                                  Text(
                                    '•••• ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D1B3E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 14),
                              )
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0), width: 2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),

              // Link new account
              const Divider(height: 0.5, color: Color(0xFFF1F5F9)),
              InkWell(
                onTap: () {},
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Color(0xFF0D1B3E), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Link a new bank account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D1B3E),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Info note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF64748B), size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verification ensures funds are transferred only to accounts owned by you. Deposits typically reflect within 1-2 business days.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Final Execution ──────────────────────────────
  Widget _buildStep3(String countryCode) {
    final amount = widget.application.loanAmount;
    final account = _selectedAccount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Amount display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              const Text(
                'FINAL WITHDRAWAL AMOUNT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Formatters.currency(amount, countryCode),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B3E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Secured via AEMO Vault',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Destination account
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DESTINATION ACCOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (account?.verificationStatus ==
                      BankVerificationStatus.verified)
                    Row(
                      children: const [
                        Icon(Icons.check_circle,
                            color: Color(0xFF16A34A), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'VERIFIED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_outlined,
                        color: Color(0xFF0D1B3E), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account?.bankName ?? 'No account selected',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B3E),
                        ),
                      ),
                      if (account != null)
                        Text(
                          'Ending in •••• ${account.accountNumber.length >= 4 ? account.accountNumber.substring(account.accountNumber.length - 4) : account.accountNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Disbursement details
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildDisbursementRow(
                  'Estimated Arrival', 'Within 1-2 business days'),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDisbursementRow(
                  'Network Fee', Formatters.currency(0, countryCode)),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDisbursementRow(
                'Total Disbursement',
                Formatters.currency(amount, countryCode),
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Disclaimer
        const Text(
          'By executing this withdrawal, you acknowledge that the funds will be transferred to the verified account above. This action is irreversible once processed.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Disbursement row ─────────────────────────────────────
  Widget _buildDisbursementRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isBold ? const Color(0xFF0D1B3E) : const Color(0xFF64748B),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF0D1B3E),
          ),
        ),
      ],
    );
  }

  // ── Bottom Button ────────────────────────────────────────
  Widget _buildBottomButton(String countryCode) {
    final labels = [
      'Continue to Bank Verification',
      'Continue to Final Step',
      'Execute Withdrawal',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              final currentUser = ref.read(currentUserProvider).value;
              if (currentUser == null || _selectedAccount == null) return;

              try {
                final withdrawal = WithdrawalModel(
                  id: '',
                  userName: currentUser.fullName,
                  userId: currentUser.id,
                  applicationId: widget.application.id,
                  amount: widget.application.loanAmount,
                  bankName: _selectedAccount!.bankName,
                  accountNumber: _selectedAccount!.accountNumber,
                  documentUrl: _uploadedUrl,
                  createdAt: DateTime.now(),
                );

                await ref
                    .read(firestoreServiceProvider)
                    .createWithdrawal(withdrawal);

                if (mounted) {
                  context.go(AppRoutes.withdrawalSuccess, extra: withdrawal);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to process withdrawal: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            }
            ;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D1B3E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                labels[_currentStep],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

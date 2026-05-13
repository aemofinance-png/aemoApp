import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/data/providers/service_providers.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';
import '../providers/loan_form_provider.dart';

class BankAndDocumentsStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserModel? currentUser;
  final String countryCode;

  const BankAndDocumentsStep({
    super.key,
    required this.formKey,
    required this.currentUser,
    required this.countryCode,
  });

  @override
  ConsumerState<BankAndDocumentsStep> createState() => _BankAndDocumentsStepState();
}

class _BankAndDocumentsStepState extends ConsumerState<BankAndDocumentsStep> {
  late TextEditingController _accountNumberController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loanFormProvider);
    _accountNumberController = TextEditingController(text: state.accountNumber);
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanFormProvider);
    final notifier = ref.read(loanFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bank & Docs',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildStepDots(3),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Finally, tell us where to send your funds and upload required documents.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                if (widget.currentUser?.bankAccounts.isNotEmpty ?? false) ...[
                  _buildFieldLabel('SAVED ACCOUNTS'),
                  const SizedBox(height: 12),
                  Column(
                    children: widget.currentUser!.bankAccounts.map((account) {
                      final isSelected = loanState.selectedBank == account.bankName && 
                                        loanState.accountNumber == account.accountNumber;
                                        
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary.withValues(alpha: 0.04) 
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: InkWell(
                            onTap: () {
                              notifier.updateBank(account.bankName);
                              notifier.updateAccountNumber(account.accountNumber);
                              _accountNumberController.text = account.accountNumber;
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? AppColors.primary.withValues(alpha: 0.1)
                                          : AppColors.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance, 
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.bankName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          account.accountNumber,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected 
                                                ? AppColors.primary.withValues(alpha: 0.7) 
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 24)
                                  else
                                    const Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                _buildFieldLabel('ADD NEW ACCOUNT'),
                const SizedBox(height: 15),
                _buildFieldLabel('BANK NAME'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: loanState.selectedBank.isNotEmpty ? loanState.selectedBank : null,
                  hint: 'Select bank',
                  items: AppStrings.banksByCountry[widget.countryCode] ?? [],
                  onChanged: (v) => notifier.updateBank(v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'ACCOUNT NUMBER',
                  controller: _accountNumberController,
                  hint: '• • • • • • • • • • • •',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.credit_card_outlined, size: 20),
                  onChanged: (v) => notifier.updateAccountNumber(v),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 32),
                _buildFieldLabel('REQUIRED DOCUMENTS'),
                const SizedBox(height: 12),
                _buildDocumentUpload(context, loanState.documents, notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(BuildContext context, List<PlatformFile> documents, LoanForm notifier) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
             final file = await ref.read(storageServiceProvider).pickFile();
             if (file != null) notifier.addDocument(file);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 40),
                SizedBox(height: 16),
                Text(
                  'Upload ID, Paystub or Utility Bill',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700, 
                    color: AppColors.primary
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can upload multiple files (JPG, PNG, PDF)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Maximum size: 5MB per file',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ),
        if (documents.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...documents.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.removeDocument(index),
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStepDots(int activeIndex) {
    return Row(
      children: List.generate(
        4,
        (i) => Container(
          width: i == activeIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i == activeIndex ? AppColors.primaryDark : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

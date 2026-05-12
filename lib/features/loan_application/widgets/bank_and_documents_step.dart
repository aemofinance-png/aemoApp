import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:aemo_loan_app/core/constants/app_colors.dart';
import 'package:aemo_loan_app/core/constants/app_strings.dart';
import 'package:aemo_loan_app/data/models/user_model.dart';
import 'package:aemo_loan_app/shared/widgets/custom_text_field.dart';

class BankAndDocumentsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedBank;
  final TextEditingController accountNumberController;
  final List<PlatformFile> documents;
  final UserModel? currentUser;
  final String countryCode;
  final void Function(String?) onBankChanged;
  final VoidCallback onPickDocument;
  final void Function(int) onRemoveDocument;

  const BankAndDocumentsStep({
    super.key,
    required this.formKey,
    required this.selectedBank,
    required this.accountNumberController,
    required this.documents,
    required this.currentUser,
    required this.countryCode,
    required this.onBankChanged,
    required this.onPickDocument,
    required this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: formKey,
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
                if (currentUser?.bankAccounts.isNotEmpty ?? false) ...[
                  _buildFieldLabel('SAVED ACCOUNTS'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: currentUser!.bankAccounts
                          .asMap()
                          .entries
                          .map((entry) {
                        final account = entry.value;
                        final isSelected = selectedBank == account.bankName &&
                            accountNumberController.text ==
                                account.accountNumber;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  onBankChanged(account.bankName);
                                  accountNumberController.text =
                                      account.accountNumber;
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.account_balance,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              account.bankName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              account.accountNumber,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? AppColors.primary
                                                        .withValues(alpha: 0.7)
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle,
                                            color: AppColors.primary, size: 20)
                                      else
                                        const Icon(Icons.chevron_right,
                                            color: AppColors.border),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildFieldLabel('ADD NEW ACCOUNT'),
                const SizedBox(height: 15),
                _buildFieldLabel('BANK NAME'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedBank,
                  hint: 'Select bank',
                  items: AppStrings.banksByCountry[countryCode] ?? [],
                  onChanged: onBankChanged,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'ACCOUNT NUMBER',
                  controller: accountNumberController,
                  hint: '• • • • • • • • • • • •',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.credit_card_outlined, size: 20),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                _buildFieldLabel('REQUIRED DOCUMENTS'),
                const SizedBox(height: 12),
                _buildDocumentUpload(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPickDocument,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined,
                    color: AppColors.primary, size: 40),
                SizedBox(height: 16),
                Text(
                  'Upload Required Documents',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can upload multiple files (ID, Paystub, etc.)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'JPG, PNG or PDF (Max 5MB each)',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  const Icon(Icons.description_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemoveDocument(index),
                    child: const Icon(Icons.close,
                        color: AppColors.textSecondary, size: 18),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

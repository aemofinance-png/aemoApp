import 'package:aemo_loan_app/shared/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/withdrawal_provider.dart';

class StepAgreementUpload extends ConsumerWidget {
  const StepAgreementUpload({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(withdrawalProvider);
    final notifier = ref.read(withdrawalProvider.notifier);

    Future<void> pickFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      try {
        await notifier.uploadDocument(result.files.first);
      } catch (e) {
        if (context.mounted) {
          CustomPopup.show(
            context,
            title: 'Upload Failed',
            message: 'Upload failed: $e',
            isWarning: true,
          );
        }
      }
    }

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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.insert_drive_file_outlined,
                  color: Color(0xFF0D1B3E), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'LOAN_AGREEMENT.PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B3E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
        GestureDetector(
          onTap: state.isUploading ? null : pickFile,
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
                  if (state.isUploading)
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
                    state.isUploading
                        ? 'Uploading...'
                        : state.uploadedDocument != null
                            ? state.uploadedDocument!.name
                            : 'Upload Signed Copy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state.uploadedDocument != null
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF0D1B3E),
                    ),
                  ),
                  if (state.uploadedDocument != null) ...[
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
}

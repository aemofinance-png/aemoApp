import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../app/router.dart';
import '../../loan_application/providers/loan_provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/providers/service_providers.dart';
import '../../../data/models/user_model.dart';

final ImagePicker _picker = ImagePicker();

Future<void> _takePhoto() async {
  final XFile? photo = await _picker.pickImage(
    source: ImageSource.camera,
  );
  if (photo != null) {
    // use photo.path or photo.readAsBytes()
  }
}

enum IdDocumentType { passport, driversLicense, nationalId }

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  IdDocumentType _selectedDocument = IdDocumentType.passport;
  PlatformFile? _idFile;
  PlatformFile? _selfieFile;
  bool isLoading = false;

  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // final _step1Key = GlobalKey<FormState>();
  // final _step2Key = GlobalKey<FormState>();
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _idFile != null;
      case 1:
        return _selfieFile != null;
      default:
        return true;
    }
  }
  // bool _validateCurrentStep() {
  //   switch (_currentStep) {
  //     case 0:
  //       return _step1Key.currentState!.validate();
  //     case 1:
  //       return _step2Key.currentState!.validate();

  //     default:
  //       return true;
  //   }
  // }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final List<_DocumentOption> _documents = [
    _DocumentOption(
      type: IdDocumentType.passport,
      title: 'Passport',
      subtitle: 'International travel document',
      icon: Icons.menu_book_outlined,
    ),
    _DocumentOption(
      type: IdDocumentType.driversLicense,
      title: "Driver's License",
      subtitle: 'State or government issued license',
      icon: Icons.badge_outlined,
    ),
    _DocumentOption(
      type: IdDocumentType.nationalId,
      title: 'National ID',
      subtitle: 'Official government identity card',
      icon: Icons.fingerprint,
    ),
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (_currentStep == 0) {
          _idFile = result.files.first;
        } else {
          _selfieFile = result.files.first;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(loanNotifierProvider);
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // appBar: AppBar(
        //   backgroundColor: AppColors.white,
        //   elevation: 0,
        //   leading: _currentStep > 0
        //       ? IconButton(
        //           icon: const Icon(Icons.arrow_back),
        //           onPressed: _previousStep,
        //         )
        //       : IconButton(
        //           icon: const Icon(Icons.close),
        //           onPressed: () => context.go(AppRoutes.dashboard),
        //         ),
        //   title: const Text(
        //     'Loan Application',
        //     style: TextStyle(
        //       fontSize: 18,
        //       fontWeight: FontWeight.w600,
        //       color: AppColors.textPrimary,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
        body: Column(
          children: [
            // Step indicator

            // Step pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            // Bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _previousStep,
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Animated success icon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'Verification Submitted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description with highlighted text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Your documents are being reviewed. This process usually takes about '),
                  TextSpan(
                    text: '24 hours.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: " We'll notify you once it's complete."),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Current Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'In Review - Pending Approval',
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

            const Spacer(),

            // Go to Dashboard button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Need Help button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final canContinue = _selfieFile != null;
    Future<void> _submitKyc() async {
      final user = ref.read(currentUserProvider).value;
      if (user == null || _idFile == null || _selfieFile == null) return;

      final storageService = ref.read(storageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final idUrl = await storageService.uploadKycDocument(
        userId: user.id,
        fileName: 'id_document',
        file: _idFile!,
      );

      final selfieUrl = await storageService.uploadKycDocument(
        userId: user.id,
        fileName: 'selfie',
        file: _selfieFile!,
      );

      await firestoreService.saveKycDocuments(
        userId: user.id,
        idDocumentUrl: idUrl,
        selfieUrl: selfieUrl,
      );
      setState(() {
        isLoading = false;
      });
      _nextStep(); // go to step 3 (success screen)
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _previousStep(),
        ),
        title: const Text(
          'Identity Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress

            const SizedBox(height: 28),

            // Title
            const Text(
              'Upload a selfie holding your ID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload a clear photo of your face for identity verification. Ensure good lighting and that your face is fully visible.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // Document options

            const SizedBox(height: 24),

            // Upload area
            _buildUploadArea(_selfieFile),

            const SizedBox(height: 24),

            // Requirements
            _buildRequirements2(),

            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canContinue
                    ? () async {
                        setState(() {
                          isLoading = true;
                        });
                        final user = ref.read(currentUserProvider).value;
                        if (user == null) return;

                        final firestoreService =
                            ref.read(firestoreServiceProvider);

                        await firestoreService.updateVerificationStatus(
                          user.id,
                          VerificationStatus.pending,
                        );
                        _submitKyc();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: canContinue ? AppColors.white : AppColors.textHint,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy note
            const Center(
              child: Text(
                'Your data is encrypted and handled securely according\nto our privacy policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    final canContinue = _idFile != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        title: const Text(
          'Identity Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress

            const SizedBox(height: 28),

            // Title
            const Text(
              'Upload your ID',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select the document type and upload a clear photo of your government-issued identification.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // Document options
            ..._documents.map((doc) => _buildDocumentOption(doc)),

            const SizedBox(height: 24),

            // Upload area
            _buildUploadArea(_idFile),

            const SizedBox(height: 24),

            // Requirements
            _buildRequirements(),

            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        _nextStep();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: canContinue ? AppColors.white : AppColors.textHint,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy note
            const Center(
              child: Text(
                'Your data is encrypted and handled securely according\nto our privacy policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'STEP 2 OF 4',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '50% Complete',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.5,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentOption(_DocumentOption doc) {
    final isSelected = _selectedDocument == doc.type;
    return GestureDetector(
      onTap: () => setState(() => _selectedDocument = doc.type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                doc.icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(PlatformFile? file) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: file != null
            ? Column(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    file!.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _pickFile,
                    child: const Text('Change file'),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'Take a photo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'or upload from your files',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRequirements() {
    final requirements = [
      'Ensure the full document is visible',
      'Avoid shadows and glare',
      'All text must be clearly legible',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHOTO REQUIREMENTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...requirements.map(
          (req) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Text(
                  req,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirements2() {
    final requirements = [
      'Ensure your face is fully visible',
      'Avoid shadows and glare',
      'No glasses or hats that obscure your face',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHOTO REQUIREMENTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...requirements.map(
          (req) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Text(
                  req,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentOption {
  final IdDocumentType type;
  final String title;
  final String subtitle;
  final IconData icon;

  _DocumentOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

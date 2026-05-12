import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/loan_application_model.dart';
import 'custom_badge.dart';

class StatusBadge extends StatelessWidget {
  final LoanStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case LoanStatus.pending:
        return AppColors.pendingLight;
      case LoanStatus.approved:
        return AppColors.successLight;
      case LoanStatus.rejected:
        return AppColors.errorLight;
    }
  }

  Color get _textColor {
    // These could also come from the theme if we define custom extensions
    return AppColors.primaryDark;
  }

  String get _label {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBadge(
      label: _label,
      backgroundColor: _backgroundColor,
      textColor: _textColor,
    );
  }
}

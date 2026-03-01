import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/loan_application_model.dart';

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
    switch (status) {
      case LoanStatus.pending:
        return AppColors.pending;
      case LoanStatus.approved:
        return AppColors.success;
      case LoanStatus.rejected:
        return AppColors.error;
    }
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}

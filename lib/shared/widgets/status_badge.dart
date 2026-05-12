import 'package:flutter/material.dart';
import 'package:aemo_loan_app/core/theme/theme_extensions.dart';
import '../../data/models/loan_application_model.dart';
import 'custom_badge.dart';

class StatusBadge extends StatelessWidget {
  final LoanStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    
    Color backgroundColor;
    String label;

    switch (status) {
      case LoanStatus.pending:
        backgroundColor = customColors.pendingLight;
        label = 'Pending';
      case LoanStatus.approved:
        backgroundColor = customColors.successLight;
        label = 'Approved';
      case LoanStatus.rejected:
        backgroundColor = customColors.errorLight;
        label = 'Rejected';
    }

    return CustomBadge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: Theme.of(context).colorScheme.primary,
    );
  }
}

import 'package:flutter/material.dart';

class WithdrawalStepIndicator extends StatelessWidget {
  final int currentStep;

  const WithdrawalStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
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
              final isComplete = i < currentStep;
              final isActive = i == currentStep;
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
                          color: i < currentStep
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
            'STEP ${currentStep + 1}: ${[
              'UPLOAD AGREEMENT',
              'BANK VERIFICATION',
              'CONFIRM WITHDRAWAL'
            ][currentStep]}',
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
              value: (currentStep + 1) / 3,
              backgroundColor: const Color(0xFFE2E8F0),
              color: const Color(0xFF0D1B3E),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

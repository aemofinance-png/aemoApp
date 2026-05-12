import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5))
        .fade(duration: 750.ms, begin: 0.4, end: 1.0);
  }
}

class WithdrawalListSkeleton extends StatelessWidget {
  const WithdrawalListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Skeleton
        const Skeleton(width: 240, height: 32),
        const SizedBox(height: 8),
        const Skeleton(width: 320, height: 16),
        const SizedBox(height: 32),

        // Stats Row Skeleton
        const Row(
          children: [
            Expanded(child: Skeleton(height: 100, borderRadius: 24)),
            SizedBox(width: 16),
            Expanded(child: Skeleton(height: 100, borderRadius: 24)),
          ],
        ),
        const SizedBox(height: 40),

        // Filters Skeleton
        const Skeleton(width: 100, height: 12),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
              4,
              (index) => const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Skeleton(width: 80, height: 36, borderRadius: 12),
                  )),
        ),
        const SizedBox(height: 24),

        // List items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Skeleton(width: 48, height: 48, borderRadius: 14),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 140, height: 16),
                        SizedBox(height: 8),
                        Skeleton(width: 100, height: 12),
                        SizedBox(height: 4),
                        Skeleton(width: 80, height: 12),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Skeleton(width: 80, height: 20),
                      SizedBox(height: 8),
                      Skeleton(width: 70, height: 22, borderRadius: 8),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            // Hero section skeleton
            const Skeleton(
                width: double.infinity, height: 200, borderRadius: 24),
            const SizedBox(height: 32),
            // Profile details grid skeleton
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 3,
              children: List.generate(
                  6,
                  (index) => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Skeleton(width: 80, height: 10),
                            SizedBox(height: 8),
                            Skeleton(width: 150, height: 16),
                          ],
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusSkeleton extends StatelessWidget {
  const StatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeleton(width: 300, height: 48),
            Skeleton(width: 150, height: 60, borderRadius: 20),
          ],
        ),
        SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Skeleton(height: 400, borderRadius: 32)),
            SizedBox(width: 40),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Skeleton(height: 180, borderRadius: 24),
                    SizedBox(height: 32),
                    Skeleton(height: 250, borderRadius: 24),
                  ],
                )),
          ],
        )
      ],
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1024;

        if (isMobile) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(width: 150, height: 24),
                const SizedBox(height: 8),
                const Skeleton(width: 200, height: 32),
                const SizedBox(height: 24),
                const Skeleton(
                    width: double.infinity, height: 180, borderRadius: 24),
                const SizedBox(height: 32),
                const Skeleton(width: 120, height: 16),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                      3,
                      (i) => const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Skeleton(height: 40, borderRadius: 12),
                            ),
                          )),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                    3,
                    (i) => const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Skeleton(
                              width: double.infinity,
                              height: 100,
                              borderRadius: 20),
                        )),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Sidebar placeholder
            Container(
              width: 260,
              color: const Color(0xFFF2F4F6),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Skeleton(width: 120, height: 24),
                  const SizedBox(height: 48),
                  ...List.generate(
                      6,
                      (i) => const Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Skeleton(
                                width: double.infinity,
                                height: 20,
                                borderRadius: 8),
                          )),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Top bar placeholder
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: const Row(
                      children: [
                        Skeleton(width: 24, height: 24),
                        Spacer(),
                        Skeleton(width: 36, height: 36, borderRadius: 18),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Skeleton(width: 300, height: 48),
                          const SizedBox(height: 32),
                          Row(
                            children: List.generate(
                                4,
                                (i) => const Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: Skeleton(
                                            height: 120, borderRadius: 24),
                                      ),
                                    )),
                          ),
                          const SizedBox(height: 48),
                          const Skeleton(width: 150, height: 24),
                          const SizedBox(height: 24),
                          ...List.generate(
                              3,
                              (i) => const Padding(
                                    padding: EdgeInsets.only(bottom: 16.0),
                                    child: Skeleton(
                                        width: double.infinity,
                                        height: 80,
                                        borderRadius: 16),
                                  )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

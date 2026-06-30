import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: SkeletonLoader(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
      title: SkeletonLoader(height: 16),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8),
        child: SkeletonLoader(height: 12, width: double.infinity),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 20, width: 150),
            SizedBox(height: 12),
            SkeletonLoader(height: 16, width: double.infinity),
            SizedBox(height: 8),
            SkeletonLoader(height: 16, width: 200),
          ],
        ),
      ),
    );
  }
}




























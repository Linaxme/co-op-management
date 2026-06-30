import 'package:flutter/material.dart';

import 'app_card.dart';
import 'cached_image_file.dart';

/// Organization name, address, and optional logo.
class OrgHeaderCard extends StatelessWidget {
  final String name;
  final String address;
  final String? logoPath;

  const OrgHeaderCard({
    super.key,
    required this.name,
    required this.address,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = logoPath?.trim();

    Widget leading;
    if (logo != null && logo.isNotEmpty) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedImageFile(
          filePath: logo,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: _fallbackAvatar(theme),
        ),
      );
    } else {
      leading = _fallbackAvatar(theme);
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                if (address.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(ThemeData theme) {
    final label = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 26,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        label.length > 3 ? label.substring(0, 3) : label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

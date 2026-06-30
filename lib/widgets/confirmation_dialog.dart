import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Shows a confirmation dialog with customizable title, message, and button texts.
/// Returns true if user confirms, false if cancelled.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          child: Text(confirmText ?? AppLocalizations.of(context)!.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}













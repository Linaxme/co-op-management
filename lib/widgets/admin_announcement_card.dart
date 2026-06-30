import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/admin_route_guard.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/notifications/announcement_service.dart';
import '../../l10n/app_localizations.dart';

class AdminAnnouncementCard extends ConsumerStatefulWidget {
  const AdminAnnouncementCard({super.key});

  @override
  ConsumerState<AdminAnnouncementCard> createState() =>
      _AdminAnnouncementCardState();
}

class _AdminAnnouncementCardState extends ConsumerState<AdminAnnouncementCard>
    with AdminRouteGuard {
  bool _sending = false;

  Future<void> _sendAnnouncement() async {
    final l10n = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sendAnnouncement),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.announcementTitle,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                decoration: InputDecoration(
                  labelText: l10n.announcementMessage,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.send),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final title = titleCtrl.text.trim();
    final body = bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.required)),
      );
      return;
    }

    final coopId = ref.read(authSessionProvider).coopId;
    final uid = ref.read(authSessionProvider).user?.uid;
    if (coopId == null || uid == null) return;

    setState(() => _sending = true);
    try {
      await AnnouncementService.instance.publish(
        coopId: coopId,
        adminUid: uid,
        title: title,
        body: body,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.announcementPublished)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: Text(l10n.sendAnnouncement),
        subtitle: Text(l10n.sendAnnouncementSubtitle),
        trailing: _sending
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right),
        onTap: _sending ? null : _sendAnnouncement,
      ),
    );
  }
}

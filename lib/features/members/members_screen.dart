import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/cached_image_file.dart';
import '../../l10n/app_localizations.dart';

final membersListProvider = StreamProvider.family((ref, String q) {
  return coopScopedStream(
    ref,
    () => ref.watch(repoProvider).watchActiveMembers(query: q),
  );
});

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.members),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-member'),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: AppLocalizations.of(context)!.addMember,
          ),
          IconButton(
            onPressed: () => context.push('/trash'),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: AppLocalizations.of(context)!.trash,
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchBy,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: membersAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: q.isEmpty
                        ? AppLocalizations.of(context)!.noMembersYet
                        : AppLocalizations.of(context)!.noMembersFound,
                    message: q.isEmpty
                        ? AppLocalizations.of(context)!.tapToAddFirstMember
                        : AppLocalizations.of(context)!.tryDifferentSearch,
                    actionLabel: q.isEmpty
                        ? AppLocalizations.of(context)!.addFirstMember
                        : null,
                    onAction:
                        q.isEmpty ? () => context.push('/add-member') : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 86),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final m = items[i];
                    return Card(
                      child: ListTile(
                        leading: _memberAvatar(m),
                        title: Text(m.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            'ID: ${m.memberIdNumber}  |  Monthly: ${formatCurrencyCompact(m.monthlyAmount)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/member/${m.uuid}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade300, size: 48),
                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!.errorLoadingMembers,
                            style: TextStyle(color: Colors.red.shade700)),
                        const SizedBox(height: 8),
                        Text('$e',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberAvatar(Member m) {
    final cs = Theme.of(context).colorScheme;
    final initial = m.name.isNotEmpty ? m.name[0].toUpperCase() : '?';
    final fallback = CircleAvatar(
      radius: 20,
      backgroundColor: cs.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final photo = m.photoPath?.trim();
    if (kIsWeb || photo == null || photo.isEmpty) {
      return fallback;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: ClipOval(
        child: CachedImageFile(
          filePath: photo,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorWidget: fallback,
          placeholder: CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

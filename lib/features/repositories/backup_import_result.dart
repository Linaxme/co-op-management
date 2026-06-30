class BackupImportResult {
  final Map<String, int> stats;
  final List<({String uuid, String? phoneNormalized})> membersToProvision;

  const BackupImportResult({
    required this.stats,
    required this.membersToProvision,
  });
}

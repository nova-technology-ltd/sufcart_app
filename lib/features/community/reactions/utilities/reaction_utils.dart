Map<String, int> groupReactions(List<dynamic> reactions) {
  final Map<String, int> grouped = {};
  for (var reaction in reactions) {
    final emoji = reaction['reaction'] as String;
    grouped[emoji] = (grouped[emoji] ?? 0) + 1;
  }
  return grouped;
}
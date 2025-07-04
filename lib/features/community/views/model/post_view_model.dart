class PostViewModel {
  final String userID;
  final DateTime viewedAt;

  PostViewModel({required this.userID, required this.viewedAt});

  factory PostViewModel.fromMap(Map<String, dynamic> map) {
    return PostViewModel(
      userID: map['userID'] ?? '',
      viewedAt: DateTime.parse(map['viewedAt']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }
}
import 'package:intl/intl.dart';

String formatRelativeTime(String dateTimeString) {
  final inputDate = DateTime.parse(dateTimeString).toLocal();
  final now = DateTime.now();
  final difference = now.difference(inputDate);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes${minutes == 1 ? 'm' : 'm'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours${hours == 1 ? 'hr' : 'hr'} ago';
  } else if (difference.inDays < 10) {
    final days = difference.inDays;
    return '$days${days == 1 ? ' day' : ' days'} ago';
  } else {
    final formatter = DateFormat('d MMM yyyy');
    return formatter.format(inputDate);
  }
}
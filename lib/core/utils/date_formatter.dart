import 'package:intl/intl.dart';

String formatDate(String iso) {
  if (iso.isEmpty) return '';
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso.length < 10 ? iso : iso.substring(0, 10);
  }
}

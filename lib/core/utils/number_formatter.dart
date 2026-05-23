/// Formats an integer with Indonesian dot separators.
/// Examples: 1000 → "1.000", 1000000 → "1.000.000"
String formatNumber(int n) {
  if (n < 1000) return n.toString();
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

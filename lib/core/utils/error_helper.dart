String sanitizeErrorMessage(Object e) {
  final msg = e.toString().replaceAll('Exception: ', '');
  if (msg.isEmpty || msg == 'null') return 'Terjadi kesalahan. Silakan coba lagi.';
  if (msg.toLowerCase().contains('dioexception') ||
      msg.toLowerCase().contains('socket') ||
      msg.toLowerCase().contains('connection') ||
      msg.toLowerCase().contains('network')) {
    return 'Koneksi internet tidak stabil. Periksa koneksi kamu dan coba lagi.';
  }
  return msg;
}

enum ApiErrorType { network, timeout, server, auth, validation, unknown }

class SanitizedError {
  final String message;
  final ApiErrorType type;
  const SanitizedError({required this.message, required this.type});
}

String sanitizeErrorMessage(Object e) {
  return parseError(e).message;
}

ApiErrorType categorizeError(Object e) {
  return parseError(e).type;
}

SanitizedError parseError(Object e) {
  final raw = e.toString();
  final msg = raw.replaceAll('Exception: ', '').replaceAll('DioException: ', '');

  if (msg.isEmpty || msg == 'null') {
    return const SanitizedError(
      message: 'Terjadi kesalahan. Silakan coba lagi.',
      type: ApiErrorType.unknown,
    );
  }

  final lower = msg.toLowerCase();
  if (lower.contains('socket') || lower.contains('connection') || lower.contains('network')) {
    return SanitizedError(
      message: 'Koneksi internet tidak stabil. Periksa koneksi kamu dan coba lagi.',
      type: ApiErrorType.network,
    );
  }
  if (lower.contains('timeout') || lower.contains('timed out')) {
    return SanitizedError(
      message: 'Waktu permintaan habis. Silakan coba lagi.',
      type: ApiErrorType.timeout,
    );
  }
  if (lower.contains('401') || lower.contains('unauthorized') || lower.contains('unauthenticated')) {
    return const SanitizedError(
      message: 'Sesi kamu telah berakhir. Silakan login ulang.',
      type: ApiErrorType.auth,
    );
  }
  if (lower.contains('500') || lower.contains('internal server') || lower.contains('bad gateway')) {
    return SanitizedError(
      message: 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
      type: ApiErrorType.server,
    );
  }
  if (lower.contains('422') || lower.contains('validation') || lower.contains('invalid')) {
    return SanitizedError(
      message: msg,
      type: ApiErrorType.validation,
    );
  }
  return SanitizedError(message: msg, type: ApiErrorType.unknown);
}

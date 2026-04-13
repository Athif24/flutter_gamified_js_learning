import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _token  = 'bloom_token';
  static const _uid    = 'bloom_uid';

  static Future<void>    saveToken(String v)  => _s.write(key: _token, value: v);
  static Future<String?> getToken()           => _s.read(key: _token);
  static Future<void>    deleteToken()        => _s.delete(key: _token);

  static Future<void>    saveUid(String v)    => _s.write(key: _uid, value: v);
  static Future<String?> getUid()             => _s.read(key: _uid);

  static Future<void>    clearAll()           => _s.deleteAll();
}
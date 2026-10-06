// lib/core/security/encryption_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';

class EncryptionService {
  static const String _encryptionKeyName = 'isar_aes_256_encryption_key';

  final FlutterSecureStorage _secureStorage;

  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Obtiene la clave de 32 bytes (256 bits) existente o genera una nueva de forma segura
  Future<List<int>> getOrCreateEncryptionKey() async {
    try {
      // 1. Intentar leer la clave almacenada en formato Base64
      final existingKeyBase64 =
          await _secureStorage.read(key: _encryptionKeyName);

      if (existingKeyBase64 != null && existingKeyBase64.isNotEmpty) {
        final decodedKey = base64Decode(existingKeyBase64);
        if (decodedKey.length == 32) {
          return decodedKey;
        }
      }

      // 2. Si no existe o es inválida, generar una clave cryptográficamente segura de 32 bytes
      final newKeyBytes = _generateSecureRandomBytes(32);
      final newKeyBase64 = base64Encode(newKeyBytes);

      // 3. Almacenar la clave cifrada en KeyStore / Keychain
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: newKeyBase64,
      );

      return newKeyBytes;
    } catch (e) {
      throw Exception('Error al gestionar la clave de cifrado local: $e');
    }
  }

  /// Generador criptográfico aleatorio seguro
  List<int> _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  /// Borrado seguro de la clave en caso de cierre de sesión o reseteo de fábrica
  Future<void> clearEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyName);
  }
}

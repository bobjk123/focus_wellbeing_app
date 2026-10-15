// test/core/security/encryption_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus_wellbeing_app/core/security/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService Tests', () {
    late EncryptionService encryptionService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      encryptionService = EncryptionService();
    });

    test('Debe generar una clave de exactamente 32 bytes (256 bits)', () async {
      final key = await encryptionService.getOrCreateEncryptionKey();

      expect(key.length, equals(32));
    });

    test('Debe reutilizar la misma clave generada en llamadas posteriores',
        () async {
      final firstKey = await encryptionService.getOrCreateEncryptionKey();
      final secondKey = await encryptionService.getOrCreateEncryptionKey();

      expect(firstKey, equals(secondKey));
    });
  });
}

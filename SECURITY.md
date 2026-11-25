# Política de seguridad

## Estado del proyecto y versiones soportadas

El proyecto está en fase de prototipo y no debe usarse todavía para proteger
información sensible en entornos reales. Por ahora, la rama `main` es la única
versión que recibe correcciones de seguridad. Las funciones de cifrado y
almacenamiento seguro están en desarrollo y su presencia no implica que toda la
información persistida esté cifrada.

La integración de Google Calendar utiliza OAuth y solicita el scope
`calendar.events`, limitado a la gestión de eventos. El flujo de autenticación
y la configuración de credenciales por plataforma siguen siendo
experimentales; no incluyas secretos OAuth, client secrets ni tokens en el
repositorio.

## Modelo de privacidad y cifrado local

1. **Cero telemetría externa**: Las sesiones Pomodoro, árboles plantados, estadísticas de uso y recomendaciones de descanso (`SlmEngine`) se procesan y almacenan exclusivamente en el dispositivo.
2. **Cifrado de base de datos (SQLCipher)**: `wellbeing.db` se abre con `PRAGMA cipher_compatibility = 4` y una clave AES-256 de 32 bytes generada mediante `Random.secure()`.
3. **Resguardo de claves**: La clave maestra se guarda en el almacén seguro nativo de cada plataforma (`Android KeyStore`, `iOS Keychain`, `Windows DPAPI`) mediante `flutter_secure_storage`.
4. **Permisos mínimos en la nube**: Google Calendar es opcional y solicita únicamente el scope `calendar.events`.

## Migración de datos históricos

- El prototipo inicial utilizó Isar como motor local; a partir de la migración a SQLite con SQLCipher, la aplicación crea un esquema relacional limpio (`user_tasks`, `pomodoro_sessions`, `plant_trees`, `calendar_events`, `usage_limits`).
- No existe importación automática desde archivos `.isar` legados. Si se requiere conservar registros previos de prototipos anteriores, deben exportarse antes de actualizar o implementar un lector puntual de transición.
- Futuros cambios de esquema en `wellbeing.db` deben gestionarse con migraciones versionadas mediante `PRAGMA user_version`.

## Reportar una vulnerabilidad

No abras un issue público para una vulnerabilidad. Usa la función privada
**Report a vulnerability** de la pestaña **Security** del repositorio de GitHub.
Si esa función no está disponible, contacta de forma privada a las personas
mantenedoras antes de publicar los detalles.

Incluye una descripción del impacto, los pasos para reproducirlo, el entorno
afectado y, si es posible, una propuesta de mitigación. No adjuntes secretos ni
datos personales.

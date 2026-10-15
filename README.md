# Focus & Wellbeing App

> **Proyecto en desarrollo activo — versión experimental**
>
> Este repositorio se publica para documentar el proceso, recibir feedback y
> colaborar en la construcción de la aplicación. Todavía no es una versión
> terminada ni debe considerarse lista para producción.

Aplicación Flutter para mejorar la productividad y el bienestar digital mediante
sesiones de enfoque, seguimiento de hábitos y una experiencia de uso consciente.
Busca convertirse en una herramienta de productividad respetuosa con la
privacidad.

## Objetivos

- Ayudar a concentrarse con sesiones Pomodoro.
- Registrar sesiones y eventos localmente.
- Mantener los datos del usuario bajo su control.
- Explorar integraciones de calendario e IA de forma ética y transparente.

## Estado actual

La aplicación se encuentra en una etapa temprana de construcción. Actualmente
incluye:

- Estructura Flutter multiplataforma.
- Base del módulo de enfoque/Pomodoro organizada por capas.
- Pantalla de temporizador con controles de inicio, pausa, reinicio y registro
  de sesiones completadas.
- Gestión de estado con `flutter_bloc`.
- Inyección de dependencias con `get_it`.
- Persistencia SQLite cifrada con SQLCipher para tareas, sesiones Pomodoro,
  árboles, eventos de calendario y límites de uso.
- Servicio inicial de almacenamiento seguro para claves de cifrado.
- Cliente inicial de Google Calendar para crear bloques de enfoque mediante
  autenticación OAuth.
- Módulo de bienestar digital con límites diarios por aplicación, persistencia
  local y una pantalla inicial para consultar y ajustar esos límites.
- Sincronización de calendario separada por capas, con búsqueda de una ventana
  libre, propuesta explicable y confirmación del bloque de enfoque.
- Motor local experimental de recomendaciones de IA/SLM que analiza fatiga,
  minutos de enfoque y conflictos de calendario, junto con una tarjeta de
  recomendaciones que permite aceptarlas o descartarlas.
- Pruebas iniciales y configuración para continuar ampliando la cobertura.

La interfaz visible todavía es mínima y algunas capas representan la base
arquitectónica de funcionalidades que aún no están terminadas. Las APIs,
modelos y decisiones técnicas pueden cambiar mientras el proyecto evoluciona.

### Cambios recientes — 15 de octubre de 2026

Durante la sesión de hoy se conectó la página principal con los módulos
existentes y se verificó su ejecución en Windows y Android:

- **Dashboard conectado a BLoCs**: `DashboardPage` ahora recibe mediante
  `MultiBlocProvider` los estados de Pomodoro, Bienestar Digital y
  sincronización con Google Calendar desde el contenedor de dependencias.
- **Tarjetas dinámicas**: el dashboard muestra los árboles plantados y minutos
  de enfoque del día desde SQLite/SQLCipher, el próximo bloque o la acción de
  resolución de calendario, y el progreso del tiempo de pantalla consumido.
- **Estadísticas del bosque**: se añadió una consulta diaria agregada en la
  base local, expuesta por el repositorio y `PomodoroBloc`, con actualización
  automática al completar una sesión.
- **Navegación principal**: se habilitaron los destinos Inicio, Bosque,
  Bienestar y Reportes mediante `NavigationBar` en móvil y `NavigationRail` en
  escritorio.
- **Arranque multiplataforma**: se eliminó la pantalla placeholder de inicio y
  se corrigió la inicialización de un árbol del bosque que provocaba un
  `LateInitializationError` al abrir Windows.
- **Compilación Android**: se habilitó Core Library Desugaring y se añadió
  `desugar_jdk_libs` para satisfacer el requisito de
  `flutter_local_notifications`. `flutter build apk --debug` genera
  `build/app/outputs/flutter-apk/app-debug.apk` correctamente.
- **Validación**: `flutter analyze` finaliza sin errores, las 8 pruebas
  automatizadas pasan y la aplicación compila, arranca y supera un hot restart
  en Windows. La compilación iOS queda pendiente de validación en macOS con
  Xcode y CocoaPods; este entorno Windows no expone el subcomando iOS y el
  checkout no contiene `ios/Podfile`.
- **Advertencias conocidas**: Workmanager se omite correctamente en Windows,
  mientras que Gradle advierte sobre la futura migración de
  `workmanager_android` al Kotlin integrado y sobre el acceso nativo de Java.

### Cambios recientes — 14 de octubre de 2026

Durante la sesión de hoy se realizaron las siguientes actualizaciones críticas y mejoras de compatibilidad:

- **Actualización global de dependencias a versiones mayores**: Se migraron todas las dependencias principales a sus versiones actuales (`flutter_bloc: ^9.1.1`, `get_it: ^9.3.0`, `flutter_secure_storage: ^11.2.0`, `googleapis: ^17.0.0`, `google_sign_in: ^7.2.0`, `extension_google_sign_in_as_googleapis_auth: ^3.0.0`, `flutter_local_notifications: ^22.3.2`, `workmanager: ^0.10.10`, `cupertino_icons: ^2.0.0`, `flutter_lints: ^6.0.0`, `bloc_test: ^10.0.0`).
- **Eliminación del override forzado**: Se removió la directiva `dependency_overrides: analyzer: ^6.0.0` de `pubspec.yaml`, resolviendo las dependencias de forma estándar y sin bloqueos de versión.
- **Tolerancia y compatibilidad multiplataforma en `WorkmanagerService`**:
  - Se implementó la verificación `WorkmanagerService.isSupported` para plataformas que admiten nativamente Workmanager (`Android`, `iOS`, `macOS`, `Linux`).
  - En plataformas de escritorio como Windows, se omite de forma segura la inicialización y el registro de tareas en segundo plano, previniendo excepciones no controladas de tipo `UnimplementedError`.
  - Se actualizaron las firmas para la versión 0.10.x (`NetworkType.notRequired`, `ExistingPeriodicWorkPolicy.keep` y eliminación del parámetro en desuso `isInDebugMode`).
- **Soporte nativo para Windows en `NotificationService`**:
  - Se incorporó `WindowsInitializationSettings` y `WindowsNotificationDetails` en `flutter_local_notifications: ^22.3.2`, permitiendo la emisión de alertas tanto en Windows Desktop como en Android, iOS y Linux.
  - Se migraron las invocaciones a parámetros con nombre requeridos por la nueva versión (`initialize(settings: ...)` y `show(id: ..., title: ..., ...)`).
- **Modernización del cliente de calendario (`GoogleCalendarClient`)**:
  - Adaptación al nuevo flujo singleton y autenticación interactiva (`GoogleSignIn.instance.authenticate`) y no interactiva (`attemptLightweightAuthentication`).
  - Obtención de credenciales HTTP autenticadas para `CalendarApi` mediante `account.authorizationClient.authorizeScopes()`.
- **Actualización de opciones de cifrado (`EncryptionService`)**:
  - Migración a `AndroidOptions(resetOnError: true)` alineado con el estándar moderno de KeyStore y AES-GCM en `flutter_secure_storage: ^11.2.0`.
- **Limpieza de código y organización de pruebas**:
  - Reubicación de la suite `encryption_service_test.dart` a su directorio correspondiente en `test/core/security/`.
  - Depuración completa del analizador estático: cero errores y cero advertencias (`flutter analyze` 100% limpio).
  - Verificación exitosa de la totalidad de pruebas unitarias y de widgets (`flutter test`).

### Cambios anteriores — 13 de octubre de 2026

Durante la sesión de hoy se incorporaron las siguientes piezas:

- Se registraron en el localizador de dependencias el motor de IA local, el
  bienestar digital y la sincronización de calendario.
- Se añadió la detección de solapamientos en Google Calendar y el desplazamiento
  automático de una propuesta al siguiente espacio disponible, con un margen de
  cinco minutos.
- Se añadieron entidades y estados BLoC para representar propuestas de
  planificación, confirmaciones y errores de sincronización.
- Se añadió la persistencia cifrada de límites de uso en SQLite/SQLCipher y el
  cálculo de cuándo una aplicación supera su límite diario.
- Se migró la persistencia local completa desde Isar a SQLite con SQLCipher.
- Se centralizó la apertura de la base, el esquema y las transacciones en
  `lib/core/database/sqlite_database.dart`.
- Se configuró `sqlite3` con el build hook `source: sqlcipher` para empaquetar
  SQLCipher en Android, iOS, Windows, macOS y Linux.
- Se conservó la clave AES-256 en `flutter_secure_storage` y se actualizó el
  worker de segundo plano para abrir la misma base cifrada que la aplicación
  principal.
- Se añadió un motor de recomendaciones explicables basado en reglas locales:
  fatiga de sesiones recientes, acumulación diaria de enfoque y eventos próximos.
- Se añadió una tarjeta reutilizable para mostrar la explicación de cada
  recomendación y permitir su aceptación o descarte.

Estas capacidades todavía no constituyen una integración final: las estadísticas
de uso parten de datos de demostración cuando no existen registros, el motor de
IA es determinista y local, y faltan la conexión con estadísticas reales del
sistema y el flujo completo de permisos OAuth.

## En desarrollo

- Completar la interfaz de usuario del temporizador.
- Añadir tareas, hábitos y estadísticas.
- Completar el consentimiento explícito, OAuth y manejo de errores por
  plataforma para la sincronización con calendarios.
- Sustituir los datos de demostración del bienestar digital por estadísticas
  reales del sistema cuando la plataforma lo permita.
- Conectar las recomendaciones de IA con el flujo de sesiones y documentar sus
  límites, explicaciones y controles de la persona usuaria.
- Ampliar las pruebas unitarias, de widgets e integración.
- Completar la migración de datos históricos desde el prototipo Isar y
  documentar el modelo de privacidad.

El orden puede cambiar. Consulta los issues y pull requests para conocer el
trabajo activo y las decisiones recientes.

## 2. Hoja de ruta: Lo que se hará después

Una vez vinculada la página principal con los módulos de Bosque Virtual,
Google Calendar, Bienestar Digital y Reportes, los siguientes pasos son:

### Pruebas de Integración y Flujo Completo (E2E)

- Verificar la persistencia real guardando datos en la base cifrada y
  confirmando que persistan al cerrar y abrir la aplicación.
- Probar el flujo de notificación cuando se excede un límite de pantalla
  configurado.

### Optimizaciones de Rendimiento y UX

- Agregar estados de carga (Skeletons / Spinners) mientras se leen las
  consultas de la base local al iniciar la app.
- Adaptar el layout para pantallas de escritorio (Windows/macOS) y
  dispositivos móviles (Android/iOS).

### Manejo de Errores y Casos Límite

- Configurar estados vacíos cuando no haya eventos agendados en Google
  Calendar o cuando el bosque no tenga árboles.
- Capturar excepciones cuando falle la autenticación OAuth2 con Google.

### Preparación para Producción

- Ejecutar el script de compilación Release (`.\build_windows.ps1`).
- Verificar los binarios nativos requeridos, incluido `isar.dll` si se reactiva
  la persistencia Isar en una futura migración. La implementación actual usa
  SQLCipher y debe verificar sus binarios nativos correspondientes.

## Tecnologías

| Área | Tecnología |
| --- | --- |
| Cliente | Flutter / Dart |
| Estado | `flutter_bloc` (v9.x) |
| Inyección | `get_it` (v9.x) |
| Persistencia | SQLite con SQLCipher (Android, iOS, Windows, macOS y Linux) |
| Seguridad local | `flutter_secure_storage` (v11.x), AES-256 |
| Integraciones | Google APIs (v17.x), Google Sign-In (v7.x), HTTP |
| Segundo plano | `workmanager` (v0.10.x, soporte nativo en Android, iOS, macOS, Linux) |
| Notificaciones | `flutter_local_notifications` (v22.x, soporte en Android, iOS, Linux, Windows) |

## Requisitos

- Flutter compatible con Dart `>=3.3.0 <4.0.0`.
- Un dispositivo, emulador o navegador compatible con Flutter.
- Para Android/iOS/desktop, las herramientas de desarrollo de la plataforma
  correspondiente.

Puedes comprobar tu instalación con:

```bash
flutter doctor
```

## Instalación y ejecución local

```bash
git clone https://github.com/bobjk123/focus_wellbeing_app.git
cd focus_wellbeing_app
flutter pub get
flutter run
```

Estas instrucciones sirven para explorar el estado actual del prototipo; no
representan todavía un proceso de instalación para usuarios finales.

### Google Calendar

La integración actual solicita iniciar sesión con Google y utiliza únicamente
el permiso de eventos de calendario (`calendar.events`) para crear bloques de
enfoque en el calendario principal. La experiencia de permisos, la
configuración OAuth por plataforma y el manejo completo de errores siguen en
desarrollo. No se debe asumir que la integración está lista para producción.

Para ejecutar el análisis estático y las pruebas:

```bash
flutter analyze
flutter test
```

La base de datos se abre desde `lib/core/database/sqlite_database.dart`. La
clave de 32 bytes se genera una sola vez y se conserva en
`flutter_secure_storage`; SQLCipher la usa para cifrar todo el archivo SQLite.
El paquete `sqlite3` se configura mediante el build hook `source: sqlcipher`
para incluir el binario SQLCipher en Android, iOS, Windows, macOS y Linux.
La aplicación usa el archivo `wellbeing.db` dentro del directorio de documentos
de la aplicación. La apertura activa `PRAGMA key`, compatibilidad de SQLCipher
4 y claves foráneas antes de crear o consultar las tablas.

El esquema actual contiene las tablas `user_tasks`, `pomodoro_sessions`,
`plant_trees`, `calendar_events` y `usage_limits`. Las sesiones Pomodoro y su
árbol se guardan dentro de una única transacción para evitar estados parciales.
Las futuras modificaciones del esquema deben incorporar una migración
versionada antes de cambiar las tablas existentes.

La clave nunca se escribe en el repositorio ni en texto plano dentro de la
base. Si se elimina el almacenamiento seguro del dispositivo, la base cifrada
no puede recuperarse sin una copia de la clave.

## Estructura del proyecto

```text
lib/
├── core/
│   ├── ai/                       # Motor local experimental y recomendaciones
│   ├── background/               # Tareas periódicas en segundo plano (Workmanager)
│   ├── database/                 # Base de datos SQLite cifrada con SQLCipher
│   ├── network/                  # Clientes de red (Google Calendar OAuth2)
│   ├── notifications/            # Servicio de notificaciones multiplataforma
│   └── security/                 # Gestión de claves de cifrado en KeyStore / Keychain
├── features/
│   ├── calendar_sync/            # Propuestas y confirmación de bloques en agenda
│   ├── digital_wellbeing/        # Límites de tiempo y uso diario de aplicaciones
│   ├── focus_pomodoro/           # Sesiones Pomodoro, bosque virtual y temporizador
│   ├── reports/                  # Reportes semanales de enfoque y fatiga
│   └── shared/                   # Modelos, entidades y dashboard común
├── injection_container.dart      # Registro de dependencias (Service Locator)
└── main.dart                     # Punto de entrada de la aplicación
```

La aplicación sigue una separación inspirada en Clean Architecture:
`presentation` depende de `domain`, y `data` implementa los contratos definidos
en `domain`.

## Cómo colaborar

Las contribuciones son bienvenidas, especialmente para documentación, pruebas,
accesibilidad, diseño y pequeñas mejoras aisladas. Como el proyecto está en
desarrollo, agradecemos discutir primero los cambios que puedan afectar la
arquitectura, la privacidad o el alcance del producto.

1. Revisa los issues abiertos o crea uno describiendo el problema o la idea.
2. Crea una rama a partir de `main`:

   ```bash
   git checkout -b feat/nombre-del-cambio
   ```

3. Realiza un cambio enfocado y añade o actualiza pruebas cuando corresponda.
4. Ejecuta `dart format .`, `flutter analyze` y `flutter test`. Si algún
   warning o prueba existente ya fallaba, indícalo claramente en el pull
   request.
5. Abre un pull request usando la plantilla del repositorio.

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para conocer las convenciones de
commits, revisión y privacidad. Las vulnerabilidades de seguridad deben
reportarse siguiendo [SECURITY.md](SECURITY.md), no mediante un issue público.

## Privacidad y seguridad

Este proyecto pretende minimizar la recopilación de datos y priorizar el
almacenamiento local. No incluyas credenciales, tokens, archivos `.env` ni datos
personales en commits o issues. La política de reporte responsable está en
[SECURITY.md](SECURITY.md).

La persistencia local de la aplicación utiliza SQLCipher en Android, iOS,
Windows, macOS y Linux. La clave AES-256 se genera con un generador
criptográficamente seguro y se guarda mediante `flutter_secure_storage`, que
delegará su protección al almacén seguro disponible en cada plataforma.
Eliminar la aplicación o restablecer el almacenamiento seguro puede hacer
irrecuperables los datos locales cifrados.

La configuración `source: sqlcipher` del build hook descarga o incorpora los
binarios nativos necesarios durante el build. Revisa las licencias de
SQLCipher y OpenSSL antes de distribuir una versión comercial. Google Calendar
solo se utiliza cuando la persona usuaria inicia sesión y concede el permiso
solicitado.

## Licencia

Este proyecto se distribuye bajo la licencia [MIT](LICENSE).

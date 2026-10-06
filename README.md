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
- Gestión de estado con `flutter_bloc`.
- Inyección de dependencias con `get_it`.
- Modelos Isar para tareas, sesiones Pomodoro, árboles, eventos de calendario y
  límites de uso.
- Servicio inicial de almacenamiento seguro para claves de cifrado.
- Cliente inicial de Google Calendar para crear bloques de enfoque mediante
  autenticación OAuth.
- Pruebas iniciales y configuración para continuar ampliando la cobertura.

La interfaz visible todavía es mínima y algunas capas representan la base
arquitectónica de funcionalidades que aún no están terminadas. Las APIs,
modelos y decisiones técnicas pueden cambiar mientras el proyecto evoluciona.

## En desarrollo

- Completar la interfaz de usuario del temporizador.
- Añadir tareas, hábitos y estadísticas.
- Integrar la sincronización con calendarios con consentimiento explícito.
- Conectar y documentar las funciones de IA ética.
- Ampliar las pruebas unitarias, de widgets e integración.
- Finalizar la integración del cifrado de la base de datos y documentar el
  modelo de privacidad.

El orden puede cambiar. Consulta los issues y pull requests para conocer el
trabajo activo y las decisiones recientes.

## Tecnologías

| Área | Tecnología |
| --- | --- |
| Cliente | Flutter / Dart |
| Estado | `flutter_bloc` |
| Inyección | `get_it` |
| Persistencia | Isar |
| Seguridad local | `flutter_secure_storage`, `crypto` |
| Integraciones | Google APIs, Google Sign-In, HTTP |

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
dart run build_runner build --delete-conflicting-outputs
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

El archivo `lib/features/shared/data/models/app_entities.g.dart` es generado.
Cuando cambies los modelos de Isar, vuelve a ejecutar `build_runner` y revisa
el resultado antes de abrir un pull request.

## Estructura del proyecto

```text
lib/
├── core/                         # Servicios transversales, como seguridad
├── features/
│   ├── focus_pomodoro/
│   │   ├── data/                 # Fuentes de datos y repositorios
│   │   ├── domain/               # Contratos y casos de uso
│   │   └── presentation/         # BLoC y pantallas
│   └── shared/                   # Modelos compartidos
├── injection_container.dart      # Registro de dependencias
└── main.dart                     # Punto de entrada
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

La presencia de un servicio de claves seguras no significa que todas las rutas
de persistencia estén cifradas todavía; esa integración forma parte del
desarrollo pendiente. Del mismo modo, Google Calendar solo se utiliza cuando
la persona usuaria inicia sesión y concede el permiso solicitado.

## Licencia

Este proyecto se distribuye bajo la licencia [MIT](LICENSE).

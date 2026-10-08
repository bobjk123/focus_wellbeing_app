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
- Modelos Isar para tareas, sesiones Pomodoro, árboles, eventos de calendario y
  límites de uso.
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

### Cambios recientes — 8 de octubre de 2026

Durante la sesión de hoy se incorporaron las siguientes piezas:

- Se registraron en el localizador de dependencias el motor de IA local, el
  bienestar digital y la sincronización de calendario.
- Se añadió la detección de solapamientos en Google Calendar y el desplazamiento
  automático de una propuesta al siguiente espacio disponible, con un margen de
  cinco minutos.
- Se añadieron entidades y estados BLoC para representar propuestas de
  planificación, confirmaciones y errores de sincronización.
- Se añadió la persistencia de límites de uso en Isar y el cálculo de cuándo
  una aplicación supera su límite diario.
- Se añadió un motor de recomendaciones explicables basado en reglas locales:
  fatiga de sesiones recientes, acumulación diaria de enfoque y eventos próximos.
- Se añadió una tarjeta reutilizable para mostrar la explicación de cada
  recomendación y permitir su aceptación o descarte.

Estas capacidades todavía no constituyen una integración final: las estadísticas
de uso parten de datos de demostración cuando no existen registros, el motor de
IA es determinista y local, y faltan la conexión con estadísticas reales del
sistema, el flujo completo de permisos y la integración de todas las pantallas
en la navegación principal.

## En desarrollo

- Completar la interfaz de usuario del temporizador.
- Añadir tareas, hábitos y estadísticas.
- Integrar la sincronización con calendarios en la navegación y completar el
  consentimiento explícito, OAuth y manejo de errores por plataforma.
- Sustituir los datos de demostración del bienestar digital por estadísticas
  reales del sistema cuando la plataforma lo permita.
- Conectar las recomendaciones de IA con el flujo de sesiones y documentar sus
  límites, explicaciones y controles de la persona usuaria.
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
├── core/
│   ├── ai/                       # Motor local experimental y recomendaciones
│   └── network/                  # Clientes de red, incluido Google Calendar
├── features/
│   ├── focus_pomodoro/
│   │   ├── data/                 # Fuentes de datos y repositorios
│   │   ├── domain/               # Contratos y casos de uso
│   │   └── presentation/         # BLoC, pantallas y widgets
│   ├── calendar_sync/             # Propuestas y confirmación de bloques
│   ├── digital_wellbeing/         # Límites y uso diario de aplicaciones
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

# Guía de contribución

Gracias por tu interés en Focus & Wellbeing App. Las contribuciones deben
mejorar la claridad, la privacidad o la utilidad del proyecto sin introducir
recopilación de datos innecesaria.

> El proyecto está en desarrollo activo. Las APIs, la estructura interna y la
> interfaz pueden cambiar. Antes de realizar cambios grandes, confirma el
> enfoque en un issue para evitar trabajo que deba rehacerse.

## Antes de empezar

- Lee el [README](README.md) y revisa los issues existentes.
- Para cambios grandes, abre primero un issue para acordar el enfoque.
- No publiques credenciales, tokens, datos personales ni capturas con
  información privada.
- No incluyas client secrets, tokens OAuth ni credenciales de Google Calendar;
  utiliza configuración local fuera del control de versiones.
- No presentes una funcionalidad experimental como terminada; documenta
  explícitamente sus limitaciones.

## Flujo de trabajo

1. Crea una rama descriptiva desde `main`, por ejemplo
   `fix/persistencia-sesion` o `feat/estadisticas`.
2. Mantén cada pull request enfocado en un solo cambio.
3. Respeta la organización por funcionalidades y las capas existentes.
4. Actualiza la documentación y las pruebas relacionadas.
5. Ejecuta antes de enviar el pull request:

   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

## Commits y pull requests

Usa mensajes claros en imperativo, por ejemplo `Añade resumen de sesión`.
En la descripción del pull request explica el problema, la solución y cómo
verificaste el cambio. Si cambia la interfaz, incluye capturas o una breve
descripción visual. Describe también cualquier limitación o trabajo pendiente.

Todas las contribuciones deben cumplir el
[Código de conducta](CODE_OF_CONDUCT.md) y la [licencia MIT](LICENSE).

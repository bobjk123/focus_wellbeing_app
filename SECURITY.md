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

## Reportar una vulnerabilidad

No abras un issue público para una vulnerabilidad. Usa la función privada
**Report a vulnerability** de la pestaña **Security** del repositorio de GitHub.
Si esa función no está disponible, contacta de forma privada a las personas
mantenedoras antes de publicar los detalles.

Incluye una descripción del impacto, los pasos para reproducirlo, el entorno
afectado y, si es posible, una propuesta de mitigación. No adjuntes secretos ni
datos personales.

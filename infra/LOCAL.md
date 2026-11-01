# Desarrollo local rápido

Desde esta carpeta se puede arrancar toda la aplicación con un único comando:

```powershell
.\start-local.ps1
```

El script crea, si no existen, la configuración local de Docker y del frontend,
levanta PostgreSQL y Keycloak, configura automáticamente el realm `finanzapp`,
crea un cliente de desarrollo y arranca los cuatro microservicios junto con
Next.js.

La aplicación queda disponible en `http://localhost:3000`.

Usuario local:

- Email: `local@finanzapp.test`
- Contraseña: `localpass123!`

Para detenerla sin borrar datos:

```powershell
.\stop-local.ps1
```

Los datos se guardan en volúmenes Docker del proyecto `finanzapp-local`.
El script de parada no utiliza `docker compose down -v`.

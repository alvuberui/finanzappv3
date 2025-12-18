# finanzappv3
Resumen de diseño (seguro y estándar):

OIDC Authorization Code + PKCE para tu SPA Next.js (cliente público).

JWTs firmados por Keycloak que tu microservicio valida como Resource Server (no guarda sesiones).

Backchannel administrativo con client_credentials desde el microservicio “auth” hacia la Admin API de Keycloak para tareas de “provisioning” (crear usuario, asignar rol, etc.).

Pantallas: por seguridad, NO recomendamos capturar usuario/contraseña en React. Lo estándar es redirigir a las páginas de Keycloak con tema personalizado (se ven “como tu React”, pero la autenticación ocurre en el IdP). Si aún quieres UI 100% en React, te explico más abajo la alternativa y sus riesgos.

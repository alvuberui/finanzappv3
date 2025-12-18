<#ftl output_format="HTML" auto_esc=true>
<!DOCTYPE html>
<html lang="${locale!'es'}">
<head>
  <meta charset="UTF-8" />
  <title>FinanzApp · Error</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="robots" content="noindex,nofollow" />
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#fa-error-card">Saltar al contenido principal</a>

  <header class="${properties.kcHeaderClass!} fa-header">
    <div class="fa-brand">
      <h1 class="${properties.kcFormHeaderClass!} fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="${properties.kcContentWrapperClass!} fa-wrapper" role="main">
    <section id="fa-error-card" class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">Ha ocurrido un problema</h2>
        <p class="fa-card-subtitle">No se pudo completar la acción solicitada</p>
      </div>

      <#-- Alerta principal con el mensaje de Keycloak. Manejo robusto cuando falta message.summary -->
      <#assign mainMsg = "Se produjo un error inesperado.">
      <#if message??>
        <#if message.summary?? && message.summary?has_content>
          <#assign mainMsg = message.summary>
        <#elseif message?has_content>
          <#-- como último recurso mostramos message en texto -->
          <#assign mainMsg = message?string>
        </#if>
      </#if>

      <div class="fa-alert fa-alert-error" role="alert" aria-live="polite">
        <div class="fa-error-message">Error 500. Contacte con el adminitrador</div>
      </div>

      <#-- Acciones sugeridas -->
      <div class="fa-actions-primary gap">
        <#-- Volver a la aplicación si hay client con baseUrl -->
        <#if client?? && client.baseUrl?has_content>
          <a class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} fa-btn-full" href="${client.baseUrl}">Volver a la aplicación</a>
        </#if>
      </div>




    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp · <span class="fa-muted">Todos los derechos reservados</span></p>
  </footer>

  <style>
    .fa-actions-primary.gap a { margin-top: .5rem; }
    .fa-divider-inline { margin: 0 .375rem; color: var(--fa-muted, #9ca3af); }
    .fa-small { font-size: .875rem; }
  </style>
</body>
</html>

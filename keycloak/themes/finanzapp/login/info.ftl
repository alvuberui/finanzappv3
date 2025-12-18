<!DOCTYPE html>
<html lang="${(locale.current)!'es'}">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>
    <#assign _type = (message.type!'info')>
    <#if _type == 'error'>
      ${msg('errorTitle')!'Ha ocurrido un error'}
    <#elseif _type == 'warning'>
      ${msg('warningTitle')!'Atención'}
    <#elseif _type == 'success'>
      ${msg('successTitle')!'Operación completada'}
    <#else>
      ${msg('infoTitle')!'Información'}
    </#if>
  </title>

  <!-- Usa tu hoja global que ya funciona en el resto -->
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css"/>
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-info-main">${msg('skipToMain')!'Saltar al contenido principal'}</a>

  <header class="fa-header">
    <div class="fa-brand">
      <h1 class="fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="fa-wrapper" role="main" id="kc-info-main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">
          <#if _type == 'error'>
            ${msg('errorTitle')!'Ha ocurrido un error'}
          <#elseif _type == 'warning'>
            ${msg('warningTitle')!'Atención'}
          <#elseif _type == 'success'>
            ${msg('successTitle')!'Operación completada'}
          <#else>
            ${msg('infoTitle')!'Información'}
          </#if>
        </h2>
        <#if client?? && client.clientId?has_content>
          <p class="fa-card-subtitle">${client.clientId}</p>
        </#if>
      </div>

      <#-- Mapeo de tipo -> clase de alerta -->
      <#assign alertClass = 'fa-alert fa-alert-info'>
      <#if _type == 'error'>
        <#assign alertClass = 'fa-alert fa-alert-error'>
      <#elseif _type == 'warning'>
        <#assign alertClass = 'fa-alert fa-alert-warn'>
      <#elseif _type == 'success'>
        <#-- Si quieres verde, crea .fa-alert-success en tu CSS y cámbialo aquí -->
        <#assign alertClass = 'fa-alert fa-alert-info'>
      </#if>

      <div class="${alertClass}" role="status" aria-live="polite">
        <p style="margin:0;">
          <#if message?? && message.summary?? && message.summary?has_content>
            ${message.summary?no_esc}
          <#elseif message?? && message?has_content>
            ${message?string?no_esc}
          </#if>
        </p>

        <#-- Acciones requeridas (si las hay) -->
        <#if requiredActions?? && (requiredActions?size > 0)>
          <ul class="fa-error-list">
            <#list requiredActions as ra>
              <li>${msg(ra)!ra}</li>
            </#list>
          </ul>
        </#if>
      </div>

      <#-- Redirección automática con contador (si aplica) -->
      <#if pageRedirectUri?? && pageRedirectUri?has_content>
        <#assign redirectExp = (pageRedirect!5)?number>
        <div class="fa-alert fa-alert-info" role="status" aria-live="polite">
          <p style="margin:0;">
            ${msg('redirigerEnSegundos')!'Serás redirigido en'}
            <strong id="fa-count">${redirectExp}</strong> ${msg('seconds')!'segundos'}.
            <a href="${pageRedirectUri}">${msg('doContinue')!'Continuar ahora'}</a>
          </p>
        </div>
        <script>
          (function(){
            var secs = ${redirectExp};
            var el = document.getElementById('fa-count');
            var url = ${pageRedirectUri?json_string};
            var t = setInterval(function(){
              secs -= 1;
              if (el) el.textContent = String(secs);
              if (secs <= 0){
                clearInterval(t);
                window.location.href = url;
              }
            }, 1000);
          })();
        </script>
      </#if>

      <#-- Botones/acciones -->
      <div class="fa-btns" style="margin-top:12px;">
        <#-- Acción primaria custom -->
        <#if actionUri?? && actionUri?has_content>
          <a class="fa-btn fa-btn-min" href="${actionUri}">
            ${actionLabel! (msg('doContinue')!'Continuar')}
          </a>
        </#if>

        <#-- Volver a la app del cliente -->
        <#if client?? && client.baseUrl?? && client.baseUrl?has_content>
          <a class="fa-btn fa-btn-outline" href="${client.baseUrl}">
            ${msg('backToApplication')!'Volver a la aplicación'}
          </a>
        </#if>

        <#-- Enlace a iniciar sesión si procede -->
        <#if url?? && url.loginUrl?? && url.loginUrl?has_content && (_type!'') != 'success'>
          <a class="fa-btn fa-btn-outline" href="${url.loginUrl}">
            ${msg('doLogIn')!'Iniciar sesión'}
          </a>
        </#if>

        <#-- Enlace genérico si no había otros -->
        <#if !(actionUri?? && actionUri?has_content)
            && !(client?? && client.baseUrl?? && client.baseUrl?has_content)
            && (pageRedirectUri?? && pageRedirectUri?has_content)>
          <a class="fa-btn fa-btn-outline" href="${pageRedirectUri}">
            ${msg('doContinue')!'Continuar'}
          </a>
        </#if>
      </div>

      <#-- Enlaces secundarios (opcionales) -->
      <div class="fa-actions-secondary" aria-label="Enlaces">
        <#if !(skipLink!false)>
          <#if client?? && client.baseUrl?? && client.baseUrl?has_content>
            <a class="fa-link" href="${client.baseUrl}">${msg('backToApplication')!'Volver a la aplicación'}</a>
          <#elseif url?? && url.loginUrl?? && url.loginUrl?has_content>
            <a class="fa-link" href="${url.loginUrl}">${msg('doLogIn')!'Iniciar sesión'}</a>
          </#if>
        </#if>
      </div>
    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp ·
      <span class="fa-muted">${msg("allRightsReserved")!"Todos los derechos reservados"}</span>
    </p>
  </footer>
</body>
</html>

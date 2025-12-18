<#ftl output_format="HTML" auto_esc=true>
<!DOCTYPE html>
<html lang="${locale!'es'}">
<head>
  <meta charset="UTF-8" />
  <title>FinanzApp · Código de verificación</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>

<body class="kcBody fa-bg">
  <header class="fa-header">
    <div class="fa-brand">
      <h1 class="fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">Verificación en dos pasos</h2>
        <p class="fa-card-subtitle">Introduce el código de seguridad de tu app de autenticación</p>
      </div>

      <#-- Mensajes de Keycloak -->
      <#if message?has_content>
        <div class="fa-alert <#if message.type=='error'>fa-alert-error<#elseif message.type=='warning'>fa-alert-warn<#else>fa-alert-info</#if>" role="alert" aria-live="polite">
          ${message.summary}
        </div>
      </#if>

      <form id="kc-otp-login-form"
            class="${properties.kcFormClass!}"
            action="${url.loginAction}"
            method="post"
            onsubmit="window.faDisableOnSubmit?.(this)">
        <input type="hidden" id="id-hidden-input" name="credentialId" />

        <div class="${properties.kcFormGroupClass!}">
          <div class="fa-field">
            <input tabindex="1"
                   id="otp"
                   name="otp"
                   type="text"
                   inputmode="numeric"
                   pattern="[0-9]*"
                   class="fa-input-modern"
                   autocomplete="one-time-code"
                   placeholder=" "
                   autofocus />
            <label for="otp" class="fa-floating-label">Código de verificación</label>
          </div>
        </div>

        <div class="fa-actions-primary">
          <button class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} fa-btn-full fa-btn-progress fa-btn-min"
                  type="submit"
                  data-loading-text="Verificando…"
                  aria-live="polite">
            <span class="fa-btn-label">Verificar</span>
            <span class="fa-spinner" aria-hidden="true"></span>
          </button>
        </div>

        <div class="fa-actions-secondary" aria-label="Acciones secundarias">
          <a class="fa-link" href="${url.loginRestartFlowUrl}">Volver a iniciar sesión</a>
        </div>
      </form>
    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp · <span class="fa-muted">Todos los derechos reservados</span></p>
  </footer>

  <script>
    // Spinner + bloqueo de botón
    window.faDisableOnSubmit = function (form) {
      const btn = form.querySelector('button[type="submit"]');
      if (!btn) return true;
      const label = btn.querySelector('.fa-btn-label');
      const loadingText = btn.getAttribute('data-loading-text') || 'Cargando…';
      btn.disabled = true;
      btn.classList.add('loading');
      if (label) label.textContent = loadingText;
      return true;
    };
  </script>
</body>
</html>

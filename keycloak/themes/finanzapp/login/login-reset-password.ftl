<!DOCTYPE html>
<html lang="${(locale.current)!'es'}">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>${msg("emailForgotTitle")!'Recuperar contraseña'}</title>
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css"/>
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-reset-password-form">${msg('skipToMain')!'Saltar al contenido principal'}</a>

  <header class="fa-header">
    <div class="fa-brand">
      <h1 class="fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">
          ${msg("emailForgotTitle")!'Recuperar contraseña'}
        </h2>
        <p class="fa-card-subtitle">
          ${msg("emailInstruction")!'Introduce tu usuario o email y te enviaremos un enlace para restablecerla.'}
        </p>
      </div>

      <#-- Mensaje global, si existe -->
      <#if message?? && (message.summary?? && message.summary?has_content || message?has_content)>
        <div class="fa-alert fa-alert-info" role="status" aria-live="polite">
          <p style="margin:0;">
            <#if message.summary?? && message.summary?has_content>
              ${message.summary?no_esc}
            <#else>
              ${message?string?no_esc}
            </#if>
          </p>
        </div>
      </#if>

      <form id="kc-reset-password-form"
            class="fa-form"
            action="${url.loginAction}"
            method="post"
            novalidate
            onsubmit="return window.faDisableOnSubmit?.(this)">

        <#assign errUser = (messagesPerField?? && messagesPerField.existsError('username'))?then('true','false')>
        <label class="label" for="username">
          ${msg('usernameOrEmail')!'Usuario o email'} <span class="req" aria-hidden="true">*</span>
        </label>

        <div class="fa-field <#if errUser=='true'>fa-invalid</#if>">
          <input id="username"
                 name="username"
                 type="text"
                 class="fa-input"
                 autocapitalize="none"
                 spellcheck="false"
                 autocomplete="username email"
                 aria-invalid="${errUser}"
                 value="${(realm.loginWithEmailAllowed!true)?then((login.username!'')?string,'')}" />
        </div>

        <#if messagesPerField?? && messagesPerField.existsError('username')>
          <div class="err" aria-live="polite">
            ${kcSanitize(messagesPerField.get('username'))?no_esc}
          </div>
        </#if>

        <div class="fa-actions-primary">
          <button class="fa-btn fa-btn-min fa-btn-full fa-btn-progress"
                  type="submit"
                  data-loading-text="${msg('emailSent')!'Enviando…'}"
                  aria-live="polite">
            <span class="fa-btn-label">${msg('doSubmit')!'Enviar enlace'}</span>
            <span class="fa-spinner" aria-hidden="true"></span>
          </button>
        </div>

        <div class="fa-actions-secondary" aria-label="${msg('otherActions')!'Acciones secundarias'}">
          <#if url?? && url.loginUrl?? && url.loginUrl?has_content>
            <a class="fa-link" href="${url.loginUrl}">${msg('backToLogin')!'Volver a iniciar sesión'}</a>
          </#if>
        </div>

      </form>
    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp · <span class="fa-muted">${msg("allRightsReserved")!"Todos los derechos reservados"}</span></p>
  </footer>

  <script>
    window.faDisableOnSubmit = function (form) {
      var btn = form.querySelector('button[type="submit"]');
      if (!btn) return true;
      var label = btn.querySelector('.fa-btn-label');
      var loadingText = btn.getAttribute('data-loading-text') || 'Cargando…';
      btn.disabled = true;
      btn.classList.add('loading');
      if (label) label.textContent = loadingText;
      return true;
    };
  </script>
</body>
</html>

<!DOCTYPE html>
<html lang="${(locale.current)!'es'}">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>${msg("changePasswordTitle")!'Restablecer contraseña'}</title>
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css"/>
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-update-password-form">${msg('skipToMain')!'Saltar al contenido principal'}</a>

  <header class="fa-header">
    <div class="fa-brand">
      <h1 class="fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">
          ${msg("changePasswordTitle")!'Crea tu nueva contraseña'}
        </h2>
        <p class="fa-card-subtitle">
          ${msg("changePasswordInstruction")!'Introduce y confirma tu nueva contraseña para continuar.'}
        </p>
      </div>

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

      <form id="kc-update-password-form"
            class="fa-form"
            action="${url.loginAction}"
            method="post"
            onsubmit="return window.faDisableOnSubmit?.(this)">

        <#assign errPwNew = (messagesPerField?? && messagesPerField.existsError('password-new'))?then('true','false')>
        <label class="label" for="password-new">
          ${msg('passwordNew')!'Nueva contraseña'} <span class="req" aria-hidden="true">*</span>
        </label>
        <div class="fa-field <#if errPwNew=='true'>fa-invalid</#if>">
          <input id="password-new"
                 name="password-new"
                 type="password"
                 class="fa-input"
                 autocomplete="new-password"
                 aria-invalid="${errPwNew}"/>
          <button type="button"
                  class="fa-eye"
                  aria-label="${msg('togglePassword')!'Mostrar u ocultar contraseña'}"
                  aria-controls="password-new"
                  onclick="window.faTogglePassword?.('password-new', this)">
            <span aria-hidden="true">👁</span>
          </button>
        </div>
        <#if messagesPerField?? && messagesPerField.existsError('password-new')>
          <div class="err" aria-live="polite">
            ${kcSanitize(messagesPerField.get('password-new'))?no_esc}
          </div>
        </#if>

        <#assign errPwC = (messagesPerField?? && messagesPerField.existsError('password-confirm'))?then('true','false')>
        <label class="label" for="password-confirm">
          ${msg('passwordConfirm')!'Repetir contraseña'} <span class="req" aria-hidden="true">*</span>
        </label>
        <div class="fa-field <#if errPwC=='true'>fa-invalid</#if>">
          <input id="password-confirm"
                 name="password-confirm"
                 type="password"
                 class="fa-input"
                 autocomplete="new-password"
                 aria-invalid="${errPwC}"/>
          <button type="button"
                  class="fa-eye"
                  aria-label="${msg('togglePassword')!'Mostrar u ocultar contraseña'}"
                  aria-controls="password-confirm"
                  onclick="window.faTogglePassword?.('password-confirm', this)">
            <span aria-hidden="true">👁</span>
          </button>
        </div>
        <#if messagesPerField?? && messagesPerField.existsError('password-confirm')>
          <div class="err" aria-live="polite">
            ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
          </div>
        </#if>

        <#if passwordRequirements?? && (passwordRequirements?size > 0)>
          <div class="fa-help">
            <ul class="fa-error-list">
              <#list passwordRequirements as req>
                <li>${req}</li>
              </#list>
            </ul>
          </div>
        <#elseif passwordHelp?? && passwordHelp?has_content>
          <div class="fa-help">${passwordHelp?no_esc}</div>
        </#if>

        <div class="fa-actions-primary">
          <button class="fa-btn fa-btn-min fa-btn-full fa-btn-progress"
                  type="submit"
                  data-loading-text="${msg('updatingPassword')!'Actualizando…'}"
                  aria-live="polite">
            <span class="fa-btn-label">${msg('doSubmit')!'Guardar contraseña'}</span>
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
    window.faTogglePassword = function (id, btn) {
      var input = document.getElementById(id);
      if (!input) return;
      var isPw = input.type === 'password';
      input.type = isPw ? 'text' : 'password';
      btn.setAttribute('aria-pressed', String(isPw));
      btn.classList.toggle('on', isPw);
      input.focus();
    };
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

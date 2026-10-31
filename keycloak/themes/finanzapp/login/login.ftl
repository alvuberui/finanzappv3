<#ftl output_format="HTML" auto_esc=true>
<!DOCTYPE html>
<html lang="${locale!'es'}">
<head>
  <meta charset="UTF-8" />
  <title>FinanzApp · Iniciar sesión</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Fuente moderna -->
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-form-login">Saltar al contenido principal</a>

  <header class="${properties.kcHeaderClass!} fa-header">
    <div class="fa-brand">
      <h1 class="${properties.kcFormHeaderClass!} fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="${properties.kcContentWrapperClass!} fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">Iniciar sesión</h2>
        <p class="fa-card-subtitle">Accede a tu panel personal</p>
      </div>


      <#if message?has_content>
        <div class="fa-alert <#if message.type=='error'>fa-alert-error<#elseif message.type=='warning'>fa-alert-warn<#else>fa-alert-info</#if>" role="alert" aria-live="polite">
          ${msg(message.summary)!kcSanitize(message.summary)?no_esc}
        </div>
      </#if>


      <form id="kc-form-login"
            class="${properties.kcFormClass!}"
            action="${url.loginAction}"
            method="post"
            novalidate
            onsubmit="window.faDisableOnSubmit?.(this)">
        <input type="hidden" id="id-hidden-input" name="credentialId" />

        <div class="${properties.kcFormGroupClass!}">
          <!-- Email / usuario -->
          <div class="fa-field">
            <input tabindex="1"
                   id="username"
                   name="username"
                   type="text"
                   inputmode="email"
                   autocapitalize="none"
                   spellcheck="false"
                   class="fa-input-modern"
                   value="${login.username!''}"
                   autocomplete="username"
                   placeholder=" " />
            <label for="username" class="fa-floating-label">Email</label>
          </div>

          <!-- Contraseña -->
          <div class="fa-field">
            <input tabindex="2"
                   id="password"
                   name="password"
                   type="password"
                   class="fa-input-modern"
                   autocomplete="current-password"
                   placeholder=" " />
            <label for="password" class="fa-floating-label">Contraseña</label>

            <!-- Toggle ver/ocultar -->
            <button type="button"
                    class="fa-eye"
                    aria-label="Mostrar u ocultar contraseña"
                    aria-controls="password"
                    onclick="window.faTogglePassword?.('password', this)"
                    title="Mostrar u ocultar contraseña">
              <span aria-hidden="true">👁</span>
            </button>
          </div>

          <#-- Recuérdame (opcional, mostrar si está permitido) -->
          <#if realm.rememberMe && !usernameEditDisabled??>
            <div class="fa-remember">
              <input type="checkbox" id="rememberMe" name="rememberMe" class="fa-checkbox" <#if login.rememberMe?? && login.rememberMe>checked</#if> />
              <label for="rememberMe">Mantener la sesión iniciada</label>
            </div>
          </#if>
        </div>

        <!-- Acciones -->
        <div class="fa-actions-primary">
          <button tabindex="3"
                  class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} fa-btn-full fa-btn-progress fa-btn-min"
                  type="submit"
                  data-loading-text="Iniciando…"
                  aria-live="polite">
            <span class="fa-btn-label">Iniciar sesión</span>
            <span class="fa-spinner" aria-hidden="true"></span>
          </button>


        </div>

        <!-- Enlaces secundarios -->
        <div class="fa-actions-secondary" aria-label="Acciones secundarias">
          <#if realm.resetPasswordAllowed>
            <a class="fa-link" href="${url.loginResetCredentialsUrl}">Recuperar contraseña</a>
          </#if>
          <#if realm.registrationAllowed && !registrationDisabled??>
            <span class="fa-sep">·</span>
            <a class="fa-link" href="${url.registrationUrl}">Crear nueva cuenta</a>
          </#if>
        </div>

        <#-- Social providers si existen -->
        <#if realm.password && social.providers?? && (social.providers?size > 0)>
          <div class="fa-divider" role="separator" aria-label="o continúa con"> <span>o continúa con</span> </div>
          <ul class="fa-social-list" role="list">
            <#list social.providers as p>
              <li>
                <a class="fa-social-btn" href="${p.loginUrl}">
                  <img src="${p.iconUrl!''}" class="fa-social-icon" alt="" aria-hidden="true"/>
                  <span>${p.displayName}</span>
                </a>
              </li>
            </#list>
          </ul>
        </#if>
      </form>
    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp · <span class="fa-muted">Todos los derechos reservados</span></p>
  </footer>

  <script>
    // Toggle contraseña accesible
    window.faTogglePassword = function (id, btn) {
      const input = document.getElementById(id);
      if (!input) return;
      const isPw = input.type === 'password';
      input.type = isPw ? 'text' : 'password';
      btn.setAttribute('aria-pressed', String(isPw));
      btn.classList.toggle('on', isPw);
      input.focus();
    };
    // Deshabilitar form en submit + spinner
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

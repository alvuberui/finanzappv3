<#ftl output_format="HTML" auto_esc=true>
<!DOCTYPE html>
<html lang="${locale!'es'}">
<head>
  <meta charset="UTF-8" />
  <title>FinanzApp · Crear cuenta</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>

<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-register-form">Saltar al contenido principal</a>

  <header class="${properties.kcHeaderClass!} fa-header">
    <div class="fa-brand">
      <h1 class="${properties.kcFormHeaderClass!} fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="${properties.kcContentWrapperClass!} fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">Crear tu cuenta</h2>
        <p class="fa-card-subtitle">Regístrate para empezar a usar tu panel</p>
      </div>

      <#-- =======================  ALERTA SUPERIOR  ======================= -->
      <#-- 1) Recolectar errores de campos base -->
      <#assign fieldErrors = []>
      <#list ['firstName','lastName','email','username','password','password-confirm'] as f>
        <#if messagesPerField?? && messagesPerField.existsError(f)>
          <#assign fieldErrors = fieldErrors + [ messagesPerField.get(f) ]>
        </#if>
      </#list>

      <#-- 2) Recolectar errores de atributos de perfil (embellecer si es genérico) -->
      <#if userProfile?? && userProfile.attributes??>
        <#list userProfile.attributes as attr>
          <#assign k = 'user.attributes.' + attr.name>
          <#if messagesPerField?? && messagesPerField.existsError(k)>
            <#assign raw = (messagesPerField.get(k)!'')?string>
            <#if raw == 'error-user-attribute-required'>
              <#assign nice = (msg('error-user-attribute-required', (attr.displayName!attr.name))!('El campo "' + (attr.displayName!attr.name) + '" es obligatorio.'))>
              <#assign fieldErrors = fieldErrors + [ nice ]>
            <#else>
              <#assign fieldErrors = fieldErrors + [ raw ]>
            </#if>
          </#if>
        </#list>
      </#if>

      <#-- 3) Mensaje global robusto -->
      <#assign globalMsg = ''>
      <#if message??>
        <#if message.summary?? && message.summary?has_content>
          <#assign globalMsg = message.summary>
        <#elseif message?has_content>
          <#assign globalMsg = message?string>
        </#if>
      </#if>

      <#-- 4) Normalizar/Traducir + DEDUPLICAR (también contra globalMsg) -->
      <#assign prettyErrors = []>
      <#assign seen = {}>  <#-- hash para dedupe -->
      <#list fieldErrors as e>
        <#assign txt = (e!'')?string>

        <#-- traducir si viene como clave -->
        <#assign translated = msg(txt)!''>
        <#if translated?has_content && translated != txt>
          <#assign txt = translated>
        </#if>

        <#-- mapeos de respaldo -->
        <#if txt == 'missingEmailMessage'>
          <#assign txt = (msg('missingEmailMessage')!'Debes introducir un email.')>
        <#elseif txt == 'missingUsernameMessage'>
          <#assign txt = (msg('missingUsernameMessage')!'Debes introducir un nombre de usuario.')>
        <#elseif txt == 'missingPasswordMessage'>
          <#assign txt = (msg('missingPasswordMessage')!'Debes introducir la contraseña.')>
        <#elseif txt == 'usernameExistsMessage'>
          <#assign txt = (msg('usernameExistsMessage')!'Ese usuario ya existe.')>
        <#elseif txt == 'emailExistsMessage'>
          <#assign txt = (msg('emailExistsMessage')!'Ese email ya está registrado.')>
        <#elseif txt == 'invalidEmailMessage'>
          <#assign txt = (msg('invalidEmailMessage')!'El email no es válido.')>
        <#elseif txt == 'error-user-attribute-required'>
          <#assign txt = (msg('error-user-attribute-required')!'Este campo es obligatorio.')>
        </#if>

        <#-- dedupe: no añadir si ya lo vimos o si es igual al global -->
        <#if txt?has_content && txt != globalMsg && !(seen[txt]??)>
          <#assign seen = seen + { (txt) : true }>
          <#assign prettyErrors = prettyErrors + [ txt ]>
        </#if>
      </#list>

      <#-- 5) Render -->
      <#if globalMsg?has_content || prettyErrors?has_content>
        <div class="fa-alert fa-alert-error" role="alert" aria-live="polite">

          <#if prettyErrors?has_content>
            <ul class="fa-error-list">
              <#list prettyErrors as err>
                <li>${err}</li>
              </#list>
            </ul>
          </#if>
        </div>
      </#if>
      <#-- ===================== FIN ALERTA SUPERIOR ====================== -->




      <form id="kc-register-form"
            class="${properties.kcFormClass!}"
            action="${url.registrationAction}"
            method="post"
            onsubmit="return window.faDisableOnSubmit?.(this)">

        <div class="${properties.kcFormGroupClass!}">

          <#-- Nombre -->
          <#assign errFirst = (messagesPerField?? && messagesPerField.existsError('firstName'))?then('true','false')>
          <div class="fa-field">
            <input id="firstName"
                   name="firstName"
                   type="text"
                   class="fa-input-modern <#if errFirst=='true'>fa-invalid</#if>"
                   value="${(register.formData.firstName)!''}"
                   placeholder=" "
                   aria-invalid="${errFirst}"
                   autocomplete="given-name" />
            <label for="firstName" class="fa-floating-label">Nombre</label>
          </div>

          <#-- Apellidos -->
          <#assign errLast = (messagesPerField?? && messagesPerField.existsError('lastName'))?then('true','false')>
          <div class="fa-field">
            <input id="lastName"
                   name="lastName"
                   type="text"
                   class="fa-input-modern <#if errLast=='true'>fa-invalid</#if>"
                   value="${(register.formData.lastName)!''}"
                   placeholder=" "
                   aria-invalid="${errLast}"
                   autocomplete="family-name" />
            <label for="lastName" class="fa-floating-label">Apellidos</label>
          </div>

          <#-- Email -->
          <#assign errEmail = (messagesPerField?? && messagesPerField.existsError('email'))?then('true','false')>
          <div class="fa-field">
            <input id="email"
                   name="email"
                   type="email"
                   inputmode="email"
                   autocapitalize="none"
                   spellcheck="false"
                   class="fa-input-modern <#if errEmail=='true'>fa-invalid</#if>"
                   value="${(register.formData.email)!''}"
                   placeholder=" "
                   aria-invalid="${errEmail}"
                   autocomplete="email" />
            <label for="email" class="fa-floating-label">Email</label>
          </div>

          <#-- Usuario (si el realm NO usa email como username) -->
          <#if !(realm.registrationEmailAsUsername!false)>
            <#assign errUser = (messagesPerField?? && messagesPerField.existsError('username'))?then('true','false')>
            <div class="fa-field">
              <input id="username"
                     name="username"
                     type="text"
                     autocapitalize="none"
                     class="fa-input-modern <#if errUser=='true'>fa-invalid</#if>"
                     value="${(register.formData.username)!''}"
                     placeholder=" "
                     aria-invalid="${errUser}"
                     autocomplete="username" />
              <label for="username" class="fa-floating-label">Usuario</label>
            </div>
          </#if>

          <#-- Contraseña -->
          <#assign errPw = (messagesPerField?? && messagesPerField.existsError('password'))?then('true','false')>
          <div class="fa-field">
            <input id="password"
                   name="password"
                   type="password"
                   class="fa-input-modern <#if errPw=='true'>fa-invalid</#if>"
                   placeholder=" "
                   aria-invalid="${errPw}"
                   autocomplete="new-password" />
            <label for="password" class="fa-floating-label">Contraseña</label>
            <button type="button"
                    class="fa-eye"
                    aria-label="Mostrar u ocultar contraseña"
                    aria-controls="password"
                    onclick="window.faTogglePassword?.('password', this)">
              <span aria-hidden="true">👁</span>
            </button>
          </div>

          <#-- Repetir contraseña -->
          <#assign errPwC = (messagesPerField?? && messagesPerField.existsError('password-confirm'))?then('true','false')>
          <div class="fa-field">
            <input id="password-confirm"
                   name="password-confirm"
                   type="password"
                   class="fa-input-modern <#if errPwC=='true'>fa-invalid</#if>"
                   placeholder=" "
                   aria-invalid="${errPwC}"
                   autocomplete="new-password" />
            <label for="password-confirm" class="fa-floating-label">Repetir contraseña</label>
            <button type="button"
                    class="fa-eye"
                    aria-label="Mostrar u ocultar contraseña"
                    aria-controls="password-confirm"
                    onclick="window.faTogglePassword?.('password-confirm', this)">
              <span aria-hidden="true">👁</span>
            </button>
          </div>

          <#-- Atributos adicionales (User Profile) -->
          <#if (userProfile?? && userProfile.attributes??)>
            <#list userProfile.attributes as attr>
              <#if (attr.annotations??) && ((attr.annotations.inputType!'') != 'hidden')>
                <#assign errAttr = (messagesPerField?? && messagesPerField.existsError('user.attributes.' + attr.name))?then('true','false')>
                <div class="fa-field">
                  <input id="${attr.name}"
                         name="user.attributes.${attr.name}"
                         type="${(attr.annotations.inputType!'text')}"
                         class="fa-input-modern <#if errAttr=='true'>fa-invalid</#if>"
                         value="${(register.formData['user.attributes.' + attr.name])!''}"
                         placeholder=" " />
                  <label for="${attr.name}" class="fa-floating-label">${attr.displayName!attr.name}</label>
                </div>
              </#if>
            </#list>
          </#if>

          <#-- reCAPTCHA (si está habilitado) -->
          <#if (recaptchaRequired!false) && (recaptchaSiteKey??)>
            <div class="fa-recaptcha">
              <div class="g-recaptcha" data-sitekey="${recaptchaSiteKey}"></div>
            </div>
            <script src="https://www.google.com/recaptcha/api.js" async defer></script>
          </#if>

        </div>

        <div class="fa-actions-primary">
          <button class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} fa-btn-full fa-btn-progress fa-btn-min"
                  type="submit"
                  data-loading-text="Creando cuenta…"
                  aria-live="polite">
            <span class="fa-btn-label">Crear cuenta</span>
            <span class="fa-spinner" aria-hidden="true"></span>
          </button>
        </div>

        <div class="fa-actions-secondary" aria-label="Acciones secundarias">
          <a class="fa-link" href="${url.loginUrl}">¿Ya tienes cuenta? Inicia sesión</a>
        </div>

        <#-- Proveedores sociales opcionales -->
        <#if social.providers?? && (social.providers?size > 0)>
          <div class="fa-divider" role="separator" aria-label="o regístrate con"><span>o regístrate con</span></div>
          <ul class="fa-social-list" role="list">
            <#list social.providers as p>
              <li>
                <a class="fa-social-btn" href="${p.loginUrl}">
                  <img src="${p.iconUrl!''}" class="fa-social-icon" alt="" aria-hidden="true" />
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

  <style>
    /* Opcional: estilo para la lista de errores */
    .fa-error-list { margin:.5rem 0 0; padding-left:1.25rem; }
    .fa-error-list li { margin:.125rem 0; }
    /* Marca visual cuando un campo tiene error */
    .fa-input-modern.fa-invalid { outline: 2px solid rgba(239, 68, 68, .6); }
  </style>

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

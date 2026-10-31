<!DOCTYPE html>
<html lang="${(locale.current)!'es'}">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>${msg("loginTotpTitle")! "Configurar app de autenticación"}</title>

  <!-- Usa el MISMO CSS global que ya te funciona en login/register -->
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css"/>
</head>
<body class="kcBody fa-bg">
  <a class="sr-only" href="#kc-totp-settings-form">${msg('skipToMain')!'Saltar al contenido principal'}</a>

  <header class="fa-header">
    <div class="fa-brand">
      <h1 class="fa-brand-title">FinanzApp</h1>
    </div>
  </header>

  <main class="fa-wrapper" role="main">
    <section class="fa-card" aria-labelledby="fa-card-title">
      <div class="fa-card-header center">
        <h2 id="fa-card-title" class="fa-card-title">
          ${msg("loginTotpTitle")! "Configura la verificación en dos pasos"}
        </h2>
        <p class="fa-card-subtitle">${msg("loginTotpIntro")!""}</p>
      </div>

      <ol class="steps">
        <li>
          <p>${msg("loginTotpStep1")! "Instala una app de autenticación:"}</p>
          <ul class="apps">
            <#if totp?? && totp.policy?? && totp.policy.supportedApplications??>
              <#list totp.policy.supportedApplications as app>
                <li>${app}</li>
              </#list>
            <#else>
              <li>Google Authenticator</li>
              <li>Authy</li>
              <li>Microsoft Authenticator</li>
            </#if>
          </ul>
        </li>

        <#-- Paso 2: QR o modo manual -->
        <#if mode?? && mode == "manual">
          <li>
            <p>${msg("loginTotpManualStep2")! "Introduce esta clave en tu app:"}</p>
            <p><strong id="kc-totp-secret-key">${totp.totpSecretEncoded!totp.totpSecret!""}</strong></p>
            <p class="footer">
              <a id="mode-barcode" href="${totp.qrUrl!'#'}">${msg("loginTotpScanBarcode")!"Escanear código QR"}</a>
            </p>
          </li>
          <li>
            <p>${msg("loginTotpManualStep3")! "Si lo necesitas, usa estos parámetros:"}</p>
            <ul class="apps">
              <li id="kc-totp-type">${msg("loginTotpType")!"Tipo"}: ${msg("loginTotp." + (totp.policy.type!"totp"))}</li>
              <li id="kc-totp-algorithm">${msg("loginTotpAlgorithm")!"Algoritmo"}: ${totp.policy.getAlgorithmKey()!"SHA1"}</li>
              <li id="kc-totp-digits">${msg("loginTotpDigits")!"Dígitos"}: ${totp.policy.digits!6}</li>
              <#if (totp.policy.type!"totp") == "totp">
                <li id="kc-totp-period">${msg("loginTotpInterval")!"Periodo (s)"}: ${totp.policy.period!30}</li>
              <#else>
                <li id="kc-totp-counter">${msg("loginTotpCounter")!"Contador"}: ${totp.policy.initialCounter!0}</li>
              </#if>
            </ul>
          </li>
        <#else>
          <li>
            <p class="center">${msg("loginTotpStep2")! "Escanea este QR con tu app:"}</p>
            <div class="qr center">
              <img id="kc-totp-secret-qr-code"
                   src="data:image/png;base64,${totp.totpSecretQrCode!""}"
                   alt="QR code"/>
            </div>
            <p class="footer center">
              <a id="mode-manual" href="${totp.manualUrl!'#'}">${msg("loginTotpUnableToScan")!"¿No puedes escanear? Introduce la clave manualmente"}</a>
            </p>
          </li>
        </#if>

        <li>
          <p>${msg("loginTotpStep3")! "Introduce el código de 6 dígitos y pon nombre a este dispositivo:"}</p>
        </li>
      </ol>

      <#-- ==== FORMULARIO ==== -->
      <form id="kc-totp-settings-form" class="form" action="${url.loginAction}" method="post" novalidate>

        <#-- Campo OTP -->
        <#assign errTotp = (messagesPerField?? && messagesPerField.existsError('totp'))?then('true','false')>
        <div class="row">
          <label class="label" for="totp">
            ${msg("authenticatorCode")!"Código de un solo uso"} <span class="req" aria-hidden="true">*</span>
          </label>

          <div class="fa-field <#if errTotp=='true'>fa-invalid</#if>">
            <input type="text"
                   id="totp"
                   name="totp"
                   class="fa-input"
                   autocomplete="one-time-code"
                   inputmode="numeric"
                   pattern="[0-9]*"
                   aria-invalid="${errTotp}"/>
          </div>

          <#if messagesPerField.existsError('totp')>
            <div id="input-error-otp-code" class="err" aria-live="polite">
              ${kcSanitize(messagesPerField.get('totp'))?no_esc}
            </div>
          </#if>
        </div>

        <#-- Campo etiqueta del dispositivo -->
        <#assign errLabel = (messagesPerField?? && messagesPerField.existsError('userLabel'))?then('true','false')>
        <div class="row">
          <label class="label" for="userLabel">
            ${msg("loginTotpDeviceName")!"Nombre del dispositivo"}
            <#if totp?? && totp.otpCredentials?? && (totp.otpCredentials?size >= 1)>
              <span class="req" aria-hidden="true">*</span>
            </#if>
          </label>

          <div class="fa-field <#if errLabel=='true'>fa-invalid</#if>">
            <input type="text"
                   id="userLabel"
                   name="userLabel"
                   class="fa-input"
                   autocomplete="off"
                   aria-invalid="${errLabel}"/>
          </div>

          <#if messagesPerField.existsError('userLabel')>
            <div id="input-error-otp-label" class="err" aria-live="polite">
              ${kcSanitize(messagesPerField.get('userLabel'))?no_esc}
            </div>
          </#if>
        </div>

        <#-- Hidden fields requeridos -->
        <input type="hidden" id="totpSecret" name="totpSecret" value="${totp.totpSecret!""}"/>
        <#if mode??><input type="hidden" id="mode" name="mode" value="${mode}"/></#if>

        <div class="btns fa-btns">
          <input type="submit"
                 id="saveTOTPBtn"
                 value="${msg('doSubmit')!'Guardar'}"
                 class="btn primary fa-btn fa-btn-min fa-btn-full"/>
          <#-- Si es App Initiated Action, mostramos Cancel -->
          <#if isAppInitiatedAction??>
            <button type="submit"
                    id="cancelTOTPBtn"
                    name="cancel-aia"
                    value="true"
                    class="btn secondary fa-btn-outline">
              ${msg("doCancel")!"Cancelar"}
            </button>
          </#if>
        </div>
      </form>

    </section>
  </main>

  <footer class="fa-footer">
    <p>© ${.now?string("yyyy")} FinanzApp · <span class="fa-muted">${msg("allRightsReserved")!"Todos los derechos reservados"}</span></p>
  </footer>
</body>
</html>

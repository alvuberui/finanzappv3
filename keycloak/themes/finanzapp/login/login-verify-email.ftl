<#-- themes/<tu-tema>/login/login-verify-email.ftl -->
<!DOCTYPE html>
<html lang="${(locale.current)!'en'}">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>${msg("emailVerifyTitle")!"Verify your email"}</title>
  <style>
    :root { --gap: 12px; --radius: 10px; --font: system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif; }
    * { box-sizing: border-box; }
    body { margin:0; font-family:var(--font); background:#0b1020; color:#e6e8ef; }
    .wrap { min-height:100vh; display:grid; place-items:center; padding:24px; }
    .card { width:100%; max-width:720px; background:#141a2f; border:1px solid #232a43; border-radius:var(--radius); padding:24px; box-shadow:0 10px 30px rgba(0,0,0,.35); }
    h1 { margin:0 0 8px; font-size:1.4rem; }
    p, a, button, input { font-size:.95rem; }
    .muted { color:#a9b1c7; }
    .btns { display:flex; gap:var(--gap); margin-top:16px; }
    .btn { padding:10px 14px; border-radius:8px; border:1px solid transparent; cursor:pointer; }
    .primary { background:#5b8cff; color:#0b1020; border-color:#5b8cff; }
    .secondary { background:transparent; color:#e6e8ef; border-color:#2c3556; }
    a { color:#9ec1ff; text-decoration:none; }
    a:hover { text-decoration:underline; }
  </style>
</head>
<body>
<div class="wrap">
  <main class="card" role="main" aria-labelledby="title">
    <h1 id="title">${msg("emailVerifyTitle")!"Verify your email"}</h1>

    <p class="muted">
      <#-- Mismo comportamiento que el tema base:
          - Si existe verifyEmail -> emailVerifyInstruction1(verifyEmail)
          - Si no -> emailVerifyInstruction4(user.email) -->
      <#if verifyEmail??>
        ${msg("emailVerifyInstruction1", verifyEmail)!}
      <#else>
        ${msg("emailVerifyInstruction4", (user.email)!"")!}
      </#if>
    </p>

    <#-- Si es App Initiated Action (AIA), mostramos formulario con botón Enviar/Reenviar y Cancel -->
    <#if isAppInitiatedAction??>
      <form id="kc-verify-email-form" action="${url.loginAction}" method="post" novalidate>
        <div class="btns">
          <#if verifyEmail??>
            <input class="btn secondary" type="submit" value="${msg('emailVerifyResend')!'Resend email'}"/>
          <#else>
            <input class="btn primary" type="submit" value="${msg('emailVerifySend')!'Send email'}"/>
          </#if>
          <button class="btn secondary" type="submit" name="cancel-aia" value="true" formnovalidate>
            ${msg("doCancel")!"Cancel"}
          </button>
        </div>
      </form>
    <#-- Si NO es AIA, mostramos el bloque informativo con “click here” (igual que base) -->
    <#else>
      <p class="muted">
        ${msg("emailVerifyInstruction2")!}
        <br/>
        <a href="${url.loginAction}">${msg("doClickHere")!"Click here"}</a>
        ${msg("emailVerifyInstruction3")!}
      </p>
    </#if>
  </main>
</div>
</body>
</html>

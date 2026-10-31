<#ftl output_format="HTML" auto_esc=true>
<!DOCTYPE html>
<html lang="${locale!'es'}">
<head>
  <meta charset="UTF-8" />
  <title>FinanzApp · Página caducada</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>
<body class="kcBody fa-bg">
  <main class="fa-wrapper" role="main">
    <section class="fa-card">
      <div class="fa-card-header center">
        <h2 class="fa-card-title">Página caducada</h2>
        <p class="fa-card-subtitle">Tu sesión o formulario ha caducado.</p>
      </div>
      <div class="fa-actions-primary">
        <a class="fa-btn-full ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!}"
           href="${url.loginUrl}">Volver a iniciar sesión</a>
      </div>
    </section>
  </main>
</body>
</html>

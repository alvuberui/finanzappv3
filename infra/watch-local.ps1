[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
$BackendRoot = Split-Path -Parent $PSScriptRoot
$Services = @("apigateway", "user", "movements", "tags")

function Get-ServiceSnapshot {
    param([Parameter(Mandatory)][string]$ServiceRoot)

    $sourceRoots = @(
        (Join-Path $ServiceRoot "src\main\java"),
        (Join-Path $ServiceRoot "src\main\resources")
    )

    $files = foreach ($sourceRoot in $sourceRoots) {
        if (Test-Path $sourceRoot) {
            Get-ChildItem -Path $sourceRoot -File -Recurse
        }
    }

    return (($files | Sort-Object FullName | ForEach-Object {
        "$($_.FullName)|$($_.LastWriteTimeUtc.Ticks)|$($_.Length)"
    }) -join "`n")
}

$snapshots = @{}
foreach ($service in $Services) {
    $snapshots[$service] = Get-ServiceSnapshot (Join-Path $BackendRoot $service)
}

Write-Host "Observador backend activo. Se recompila el servicio afectado al detectar cambios."

while ($true) {
    Start-Sleep -Seconds 1

    foreach ($service in $Services) {
        $serviceRoot = Join-Path $BackendRoot $service
        $currentSnapshot = Get-ServiceSnapshot $serviceRoot

        if ($currentSnapshot -eq $snapshots[$service]) {
            continue
        }

        Write-Host "Cambio detectado en $service. Compilando..."
        Push-Location $serviceRoot
        try {
            & .\mvnw.cmd compile -q -DskipTests
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$service compilado correctamente. Spring DevTools reiniciará el servicio."
            } else {
                Write-Host "La compilación de $service ha fallado. Se reintentará en el siguiente cambio."
            }
        } finally {
            Pop-Location
        }

        $snapshots[$service] = $currentSnapshot
    }
}

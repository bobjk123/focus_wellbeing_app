# build_windows.ps1 - Script de Compilación en Modo Release para Windows

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Iniciando Proceso de Compilación: Windows Release " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Limpieza de caché previa
Write-Host "`n[1/5] Limpiando caché y archivos temporales..." -ForegroundColor Yellow
flutter clean

# 2. Descarga de dependencias
Write-Host "`n[2/5] Descargando dependencias de pubspec.yaml..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
  Write-Host "`n[ERROR] Falló flutter pub get. Abortando compilación." -ForegroundColor Red
  exit $LASTEXITCODE
}

# 3. Análisis estático del proyecto
Write-Host "`n[3/5] Ejecutando análisis estático (flutter analyze)..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
  Write-Host "`n[ERROR] Se encontraron errores en flutter analyze. Abortando compilación." -ForegroundColor Red
  exit $LASTEXITCODE
}

# 4. Ejecución de la suite de pruebas
Write-Host "`n[4/5] Ejecutando pruebas unitarias, de widgets y E2E..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
  Write-Host "`n[ERROR] Las pruebas fallaron. Abortando compilación." -ForegroundColor Red
  exit $LASTEXITCODE
}

# 5. Compilación del ejecutable para Windows en modo Release
Write-Host "`n[5/5] Compilando ejecutable para Windows (Release)..." -ForegroundColor Yellow
flutter build windows --release

if ($LASTEXITCODE -eq 0) {
  $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
  $releaseDir = "build\windows\$arch\runner\Release\"
  Write-Host "`n==================================================" -ForegroundColor Green
  Write-Host " ¡Compilación completada exitosamente! " -ForegroundColor Green
  Write-Host " Ejecutable y binarios (incluyendo SQLCipher) en: " -ForegroundColor Green
  Write-Host " $releaseDir" -ForegroundColor White
  Write-Host "==================================================" -ForegroundColor Green
} else {
  Write-Host "`n[ERROR] Error durante la compilación en modo Release." -ForegroundColor Red
  exit $LASTEXITCODE
}

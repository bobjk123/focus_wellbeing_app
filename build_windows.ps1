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

# 3. Generación de código para Isar DB (.g.dart)
Write-Host "`n[3/5] Generando esquemas de Isar DB con build_runner..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

# 4. Ejecución de la suite de pruebas unitarias
Write-Host "`n[4/5] Ejecutando pruebas unitarias..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
  Write-Host "`n[ERROR] Las pruebas unitarias fallaron. Abortando compilación." -ForegroundColor Red
  exit $LASTEXITCODE
}

# 5. Compilación del ejecutable para Windows en modo Release
Write-Host "`n[5/5] Compilando ejecutable para Windows (Release)..." -ForegroundColor Yellow
flutter build windows --release

if ($LASTEXITCODE -eq 0) {
  Write-Host "`n==================================================" -ForegroundColor Green
  Write-Host " ¡Compilación completada exitosamente! " -ForegroundColor Green
  Write-Host " Ejecutable generado en: " -ForegroundColor Green
  Write-Host " build\windows\x64\runner\Release\" -ForegroundColor White
  Write-Host "==================================================" -ForegroundColor Green
}
else {
  Write-Host "`n[ERROR] Error durante la compilación en modo Release." -ForegroundColor Red
}
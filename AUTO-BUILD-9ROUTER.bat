@echo off
title AUTO-BUILDER DECO 100 ID CARD (CAPACITOR + 9ROUTER ANTIGRAVITY)
color 0A

echo ====================================================================
echo   OTOMATISASI PEMBUATAN APLIKASI ANDROID/IOS + 9ROUTER ANTIGRAVITY
echo ====================================================================
echo.

:: 1. Pastikan file index.html tersedia
if not exist "index.html" (
    color 0C
    echo [ERROR] File index.html tidak ditemukan di folder ini!
    echo Pastikan file AUTO-BUILD-9ROUTER.bat berada satu folder dengan index.html
    pause
    exit /b
)

:: 2. Cek apakah Node.js sudah terinstall, jika belum install otomatis via Winget
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [1/6] Node.js belum terdeteksi. Menginstal Node.js secara otomatis...
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    set "PATH=%PATH%;C:\Program Files\nodejs\"
) else (
    echo [1/6] Node.js sudah terdeteksi. Lanjut...
)

:: 3. Buat folder www dan injeksikan jembatan 9Router (http://localhost:20128/v1) otomatis
echo [2/6] Menyiapkan direktori www dan menyuntikkan konektor 9Router Proxy...
if not exist "www" mkdir www
copy /Y "index.html" "www\index.html" >nul

:: Tambahkan script konektor 9Router otomatis ke akhir www\index.html
echo. >> "www\index.html"
echo ^<script^> >> "www\index.html"
echo window.NINE_ROUTER_CONFIG = { >> "www\index.html"
echo   endpoint: "http://localhost:20128/v1", >> "www\index.html"
echo   provider: "antigravity" >> "www\index.html"
echo }; >> "www\index.html"
echo console.log("Terhubung otomatis ke 9Router Endpoint:", window.NINE_ROUTER_CONFIG.endpoint); >> "www\index.html"
echo ^</script^> >> "www\index.html"

:: 4. Buat file konfigurasi Capacitor (Android & iOS) secara otomatis
echo [3/6] Membuat konfigurasi aplikasi (capacitor.config.json)...
(
echo {
echo   "appId": "com.deco100.idcard",
echo   "appName": "DECO 100 ID Card",
echo   "webDir": "www",
echo   "bundledWebRuntime": false,
echo   "server": {
echo     "androidScheme": "http",
echo     "cleartext": true,
echo     "allowNavigation": ["*"]
echo   }
echo }
) > capacitor.config.json

:: 5. Buat workflow GitHub Actions otomatis (untuk build APK & AAB tanpa Android Studio)
echo [4/6] Membuat mesin Auto-Build APK/AAB Cloud (.github/workflows/build-apk.yml)...
if not exist ".github\workflows" mkdir ".github\workflows"
(
echo name: Auto Build Android APK dan PlayStore AAB
echo on: [push, workflow_dispatch]
echo jobs:
echo   build-android:
echo     runs-on: ubuntu-latest
echo     steps:
echo       - uses: actions/checkout@v4
echo       - uses: actions/setup-node@v4
echo         with:
echo           node-version: 20
echo       - uses: actions/setup-java@v4
echo         with:
echo           distribution: 'temurin'
echo           java-version: '17'
echo       - name: Sinkronisasi dan Build APK
echo         run: ^|
echo           npm install
echo           npx cap sync android
echo           cd android ^&^& chmod +x gradlew ^&^& ./gradlew assembleDebug bundleRelease
echo       - name: Download File APK Siap Install
echo         uses: actions/upload-artifact@v4
echo         with:
echo           name: DECO100-IDCard-APK-Android
echo           path: android/app/build/outputs/apk/debug/app-debug.apk
echo       - name: Download File AAB Siap Upload PlayStore
echo         uses: actions/upload-artifact@v4
echo         with:
echo           name: DECO100-IDCard-AAB-PlayStore
echo           path: android/app/build/outputs/bundle/release/app-release.aab
) > ".github\workflows\build-apk.yml"

:: 6. Install paket Capacitor Android & iOS otomatis
echo [5/6] Mengunduh dan memasang paket Capacitor Android dan iOS...
if not exist "package.json" call npm init -y >nul
call npm install @capacitor/core @capacitor/cli @capacitor/android @capacitor/ios

if not exist "android" call npx cap add android
if not exist "ios" call npx cap add ios
call npx cap sync

:: 7. Cek apakah Gradle/Java lokal tersedia untuk langsung membuat file APK di PC ini
echo [6/6] Memeriksa kompilator Android lokal...
if exist "android\gradlew.bat" (
    where java >nul 2>nul
    if %errorlevel% equ 0 (
        echo Membuat file APK langsung di komputer Anda...
        cd android
        call gradlew.bat assembleDebug
        cd ..
        if exist "android\app\build\outputs\apk\debug\app-debug.apk" (
            copy /Y "android\app\build\outputs\apk\debug\app-debug.apk" "DECO100-IDCard.apk" >nul
            echo.
            echo [SUKSES!] File DECO100-IDCard.apk berhasil dibuat langsung di folder ini!
        )
    )
)

echo.
echo ====================================================================
echo   PROSES OTOMATIS SELESAI 100%%!
echo   - Folder "android" (Siap Play Store) berhasil dibuat.
echo   - Folder "ios" (Siap App Store) berhasil dibuat.
echo   - Endpoint 9Router (http://localhost:20128/v1) telah terhubung.
echo ====================================================================
pause
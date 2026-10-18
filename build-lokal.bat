@echo off
echo Memulai Build Cepat ID Card APK...
if not exist "www" mkdir www
copy /Y index.html www\index.html
call npm install
npx cap sync android
cd android
call gradlew.bat assembleDebug
cd..
echo ==========================================
echo SELESAI! Cek folder android\app\build\outputs\apk\debug\
echo ==========================================
pause
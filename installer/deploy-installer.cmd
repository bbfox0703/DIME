@echo off
mkdir "system32.x86" 2>nul
mkdir "system32.x64" 2>nul
mkdir "system32.arm64" 2>nul
copy ..\Release\DIMESettings.exe .
copy ..\Release\x64\DIME.dll system32.x64\
copy ..\Release\ARM64\DIME.dll system32.arm64\
copy ..\Release\Win32\DIME.dll system32.x86\
copy ..\Tables\*.cin .
"c:\Program Files (x86)\NSIS\makensis.exe" DIME-x86armUniversal.nsi
REM use the following line instead for buiding on x86 platform
REM "c:\Program Files\NSIS\makensis.exe" DIME-x86armUniversal.nsi
echo ===============================================================================
echo Deployment and Installer packaging done!!
echo ===============================================================================
pause

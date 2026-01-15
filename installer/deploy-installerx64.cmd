@echo off
mkdir "system32.x64" 2>nul
copy ..\Release\DIMESettings.exe .
copy ..\Release\x64\DIME.dll system32.x64\
copy ..\Tables\*.cin .
"c:\Program Files (x86)\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi
REM "c:\Program Files\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi
echo ===============================================================================
echo Deployment and Installer packaging done!!
echo ===============================================================================
pause

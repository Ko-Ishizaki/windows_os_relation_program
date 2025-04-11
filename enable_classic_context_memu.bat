@echo off
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo Classic context menu enabled.

choice /c YN /m "Do you want to restart your PC now? (Y/N)"
if errorlevel 2 (
    echo Restart cancelled.
    pause
    exit
)
echo Restarting...
shutdown /r /t 0

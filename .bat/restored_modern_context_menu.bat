@echo off
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
echo Modern context menu restored.

choice /c YN /m "Do you want to restart your PC now? (Y/N)"
if errorlevel 2 (
    echo Restart cancelled.
    pause
    exit
)
echo Restarting...
shutdown /r /t 0

REM PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList 'Set-ExecutionPolicy RemoteSigned' -Verb RunAs}"
Powershell.exe -executionpolicy remotesigned -File ./setup-win.ps1

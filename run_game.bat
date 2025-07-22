@echo off
echo Starting Turn-based Game Template...
echo.

REM Try to find LÖVE in common installation paths
set LOVE_PATH=""

if exist "C:\Program Files\LOVE\love.exe" (
    set LOVE_PATH="C:\Program Files\LOVE\love.exe"
) else if exist "C:\Program Files (x86)\LOVE\love.exe" (
    set LOVE_PATH="C:\Program Files (x86)\LOVE\love.exe"
) else if exist "%APPDATA%\LOVE\love.exe" (
    set LOVE_PATH="%APPDATA%\LOVE\love.exe"
) else (
    echo LÖVE 2D not found in common locations.
    echo Please install LÖVE 2D from https://love2d.org/
    echo Or add LÖVE to your PATH environment variable.
    pause
    exit /b 1
)

echo Found LÖVE at: %LOVE_PATH%
echo.

REM Run the game
%LOVE_PATH% "%~dp0"

echo.
echo Game finished.
pause 
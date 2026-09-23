@echo off
chcp 65001 >nul 2>&1

set "GODOT_EXE="
where godot >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f "delims=" %%i in ('where godot') do set "GODOT_EXE=%%i"
)
if not defined GODOT_EXE (
    for %%F in ("%~dp0..\Godot*console*.exe" "%~dp0..\Godot*.exe" "%~dp0Godot*.exe" "C:\workspace\godot\Godot*.exe") do (
        if exist "%%F" set "GODOT_EXE=%%F"
    )
)

set "PROJECT_DIR=%~dp0godot_project"
set "OUTPUT_DIR=%~dp0build\windows"
set "OUTPUT_EXE=%OUTPUT_DIR%\hgnn-parts.exe"

echo ============================================================
echo  Godot Windows Desktop Export
echo  Godot:   %GODOT_EXE%
echo  Project: %PROJECT_DIR%
echo  Output:  %OUTPUT_EXE%
echo ============================================================

if not defined GODOT_EXE (
    echo ERROR: Godot executable not found.
    pause
    exit /b 1
)

REM --- Check and auto-download export templates if missing ---
set "TEMPLATE_DIR=%APPDATA%\Godot\export_templates\4.7.stable"
set "TPL_DEBUG=%TEMPLATE_DIR%\windows_debug_x86_64.exe"
set "TPL_RELEASE=%TEMPLATE_DIR%\windows_release_x86_64.exe"

if not exist "%TPL_DEBUG%" goto :download_templates
if not exist "%TPL_RELEASE%" goto :download_templates
goto :templates_ready

:download_templates
echo.
echo ============================================================
echo  Export templates not found. Downloading from GitHub...
echo ============================================================
echo.

set "TPL_TEMP=%~dp0templates_temp.tpz"
set "TPL_EXTRACT=%~dp0temp_extracted"

if not exist "%TEMPLATE_DIR%" mkdir "%TEMPLATE_DIR%"

REM --- Download using curl.exe (built into Windows 10 1803+) ---
set "TPL_URL=https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_export_templates.tpz"
echo Downloading from: %TPL_URL%
curl.exe -L -o "%TPL_TEMP%" --connect-timeout 30 --max-time 600 "%TPL_URL%"

if %ERRORLEVEL% neq 0 (
    echo GitHub download failed, trying Tuxfamily mirror...
    set "TPL_URL=https://downloads.tuxfamily.org/godotengine/4.7/Godot_v4.7-stable_export_templates.tpz"
    echo Downloading from: %TPL_URL%
    curl.exe -L -o "%TPL_TEMP%" --connect-timeout 30 --max-time 600 "%TPL_URL%"
)

if not exist "%TPL_TEMP%" (
    echo ERROR: Download failed.
    pause
    exit /b 1
)

REM --- Extract using tar (built into Windows 10 1803+) ---
echo Extracting templates...
if exist "%TPL_EXTRACT%" rmdir /s /q "%TPL_EXTRACT%"
mkdir "%TPL_EXTRACT%"
tar -xf "%TPL_TEMP%" -C "%TPL_EXTRACT%"

REM --- Move required template files ---
for %%T in (windows_debug_x86_64.exe windows_release_x86_64.exe windows_debug_x86_32.exe windows_release_x86_32.exe) do (
    if exist "%TPL_EXTRACT%\templates\%%T" (
        move /y "%TPL_EXTRACT%\templates\%%T" "%TEMPLATE_DIR%\%%T" >nul
        echo Installed: %%T
    )
)

REM --- Cleanup ---
echo Cleaning up...
if exist "%TPL_TEMP%" del /f /q "%TPL_TEMP%"
if exist "%TPL_EXTRACT%" rmdir /s /q "%TPL_EXTRACT%"

echo Template download completed!

if not exist "%TPL_DEBUG%" (
    echo ERROR: Failed to install export templates.
    pause
    exit /b 1
)
if not exist "%TPL_RELEASE%" (
    echo ERROR: Failed to install export templates.
    pause
    exit /b 1
)

echo.
echo  Templates installed successfully.
echo.

:templates_ready
REM --- Proceed with export ---

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo.
echo Building Windows executable...
echo.

"%GODOT_EXE%" --headless --path "%PROJECT_DIR%" --export-release "Windows Desktop" "%OUTPUT_EXE%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Windows export failed! (Error Code: %ERRORLEVEL%)
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ============================================================
echo  Export complete successfully!
echo  Executable created at: %OUTPUT_EXE%
echo ============================================================
echo.
pause

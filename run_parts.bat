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

echo ========================================
echo  Run HGNN-Parts Simulation
echo  Godot:   %GODOT_EXE%
echo  Project: %PROJECT_DIR%
echo ========================================

if not defined GODOT_EXE (
    echo ERROR: Godot executable not found.
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\project.godot" (
    echo ERROR: project.godot not found: %PROJECT_DIR%
    pause
    exit /b 1
)

"%GODOT_EXE%" --path "%PROJECT_DIR%"

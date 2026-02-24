@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ====== CONFIG: update your firmware.bin build path here ======
set "FIRMWARE_SRC=D:\Daniyal Stingray\FuelDispenser\Firmwares\FuelTrack\.pio\build\esp32-s3-devkitc-1-n16r8v\firmware.bin"
set "GITHUB_RAW_BASE=https://raw.githubusercontent.com/isyeddani/FT_Bin/main"
REM =============================================================

cd /d "%~dp0"

if not exist "%FIRMWARE_SRC%" (
  echo ERROR: firmware.bin not found:
  echo "%FIRMWARE_SRC%"
  pause
  exit /b 1
)

REM ---- Input firmware version ----
:ASK_FW
set "FW_VERSION="
set /p "FW_VERSION=Enter firmware version (e.g., 1.2.1): "
for /f "tokens=* delims= " %%A in ("%FW_VERSION%") do set "FW_VERSION=%%A"
if not defined FW_VERSION goto ASK_FW

REM ---- Input hardware version folder ----
:ASK_HW
set "HW_VERSION="
set /p "HW_VERSION=Enter hardware version folder (e.g., 6 or 7): "
for /f "tokens=* delims= " %%A in ("%HW_VERSION%") do set "HW_VERSION=%%A"
if not defined HW_VERSION goto ASK_HW

REM numeric-only validation
set "BAD="
for /f "delims=0123456789" %%A in ("%HW_VERSION%") do set "BAD=1"
if defined BAD (
  echo ERROR: Hardware version must be numeric. Example: 6
  goto ASK_HW
)

REM ---- Create folder <HW_VERSION> if missing ----
set "TARGET_DIR=%CD%\%HW_VERSION%"
if not exist "%TARGET_DIR%\NUL" mkdir "%TARGET_DIR%"

REM ---- Copy firmware.bin into <HW_VERSION>\firmware.bin ----
copy /Y "%FIRMWARE_SRC%" "%TARGET_DIR%\firmware.bin" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy firmware.bin
  pause
  exit /b 1
)

REM ---- Update <HW_VERSION>\info.json ----
set "INFO_JSON=%TARGET_DIR%\info.json"
set "FW_URL=%GITHUB_RAW_BASE%/%HW_VERSION%/firmware.bin"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$obj = [ordered]@{ firmware_version='%FW_VERSION%'; hardware_version='%HW_VERSION%'; url='%FW_URL%' };" ^
  "$obj | ConvertTo-Json -Depth 3 | Set-Content -Encoding UTF8 -Path '%INFO_JSON%';"

if errorlevel 1 (
  echo ERROR: Failed to write "%INFO_JSON%"
  pause
  exit /b 1
)

echo Done.
echo Copied: "%TARGET_DIR%\firmware.bin"
echo Updated: "%INFO_JSON%"
pause
endlocal
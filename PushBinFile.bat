@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: Copy firmware.bin to the same folder as this .bat file
copy "D:\Daniyal Stingray\FuelDispenser\Firmwares\FuelTrack\.pio\build\esp32-s3-devkitc-1-n16r8v\firmware.bin" "%~dp0firmware.bin"

:: Ask for firmware version
:prompt_version
set /p fw_version="Enter firmware version (e.g., 1.0.5): "
for /f "tokens=* delims=" %%a in ("%fw_version%") do set "fw_version=%%a"

if "%fw_version%"=="" (
    echo Firmware version cannot be empty. Please enter a valid version.
    goto prompt_version
)

:: Update info.json in the same folder as this .bat file
set "INFO_JSON=%~dp0info.json"
if not exist "%INFO_JSON%" (
    echo ERROR: info.json not found at "%INFO_JSON%"
    pause
    exit /b 1
)

:: Replace the firmware_version value (keeps everything else unchanged)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p = '%INFO_JSON%';" ^
  "$j = Get-Content -Raw -Path $p | ConvertFrom-Json;" ^
  "$j.firmware_version = '%fw_version%';" ^
  "$j | ConvertTo-Json -Depth 10 | Set-Content -Path $p -Encoding UTF8;"

if %errorlevel% neq 0 (
    echo ERROR: Failed to update info.json
    pause
    exit /b 1
)

echo Updated info.json firmware_version to %fw_version%

:: Check if there are any changes to commit
git diff --quiet
if %errorlevel% neq 0 (
    :: If there are changes, prompt for commit message
    :prompt_message
    set /p commit_message="Enter commit message: "
    for /f "tokens=* delims=" %%a in ("%commit_message%") do set "commit_message=%%a"
    
    if "%commit_message%"=="" (
        echo Commit message cannot be empty. Please enter a valid message.
        goto prompt_message
    )

    :: Git commit and push
    git add .
    git commit -m "%commit_message%"
    git push
) else (
    echo No changes to commit.
)

pause
endlocal
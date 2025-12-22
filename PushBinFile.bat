@echo off
:: Copy firmware.bin to the same folder as this .bat file
copy "D:\Daniyal Stingray\FuelDispenser\Firmwares\FuelTrack\.pio\build\esp32-s3-devkitc-1-n16r8v\firmware.bin" "%~dp0firmware.bin"

:: Check if there are any changes to commit
git diff --quiet
if %errorlevel% neq 0 (
    :: If there are changes, prompt for commit message
    :prompt_message
    set /p commit_message="Enter commit message: "
    
    :: Trim spaces from the commit message
    for /f "tokens=* delims=" %%a in ("%commit_message%") do set commit_message=%%a
    
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

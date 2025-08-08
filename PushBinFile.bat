@echo off
:: Copy firmware.bin to the same folder as this .bat file
copy "D:\Daniyal Stingray\FuelDispenser\Firmwares\FuelTrack\.pio\build\esp32-s3-devkitc-1-n16r8v\firmware.bin" "%~dp0firmware.bin"

:: Prompt for commit message
set /p commit_message="Enter commit message: "

:: Git commit and push
git add .
git commit -m "%commit_message%"
git push

pause

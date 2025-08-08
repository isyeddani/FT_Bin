
@echo off
:: Copy firmware.bin to the same folder as this .bat file
copy "D:\Daniyal Stingray\FuelDispenser\Firmwares\FuelTrack\.pio\build\esp32-s3-devkitc-1-n16r8v\firmware.bin" "%~dp0firmware.bin"

:: Start HTTP server on port 8080 (no admin needed)
python -m http.server 8080

pause

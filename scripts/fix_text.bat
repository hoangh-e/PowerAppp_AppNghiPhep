@echo off
echo =============================================
echo  SCRIPT SUA LOI TEXT FORMATTING TRONG YAML
echo =============================================
echo.

cd /d "%~dp0.."

echo Dang chay script sua loi ": " thanh ":" trong file YAML...
echo.

python scripts/run_fix_text.py

echo.
echo Nhan phim bat ky de dong...
pause > nul 
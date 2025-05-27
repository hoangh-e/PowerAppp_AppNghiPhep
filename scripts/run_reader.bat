@echo off
echo ========================================
echo    SCRIPT DOC FILE EXCEL VA PDF
echo ========================================
echo.

echo Dang kiem tra Python...
python --version
if %errorlevel% neq 0 (
    echo Loi: Chua cai dat Python!
    pause
    exit /b 1
)

echo.
echo Dang kiem tra thu vien...
pip show pandas >nul 2>&1
if %errorlevel% neq 0 (
    echo Dang cai dat thu vien...
    pip install -r requirements.txt
)

echo.
echo ========================================
echo    CHON SCRIPT DE CHAY
echo ========================================
echo 1. Script don gian (test nhanh)
echo 2. Script day du tinh nang
echo 3. Thoat
echo.
set /p choice="Nhap lua chon (1-3): "

if "%choice%"=="1" (
    echo.
    echo Dang chay script don gian...
    python simple_reader.py
) else if "%choice%"=="2" (
    echo.
    echo Dang chay script day du...
    python read_files.py
) else if "%choice%"=="3" (
    echo Tam biet!
    exit /b 0
) else (
    echo Lua chon khong hop le!
)

echo.
echo ========================================
echo Hoan thanh! Nhan phim bat ky de thoat...
pause 
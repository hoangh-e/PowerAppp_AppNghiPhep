@echo off
echo ===============================================
echo  Fix PA2108 Errors - Power Apps YAML Fixer
echo ===============================================
echo.
echo This script will fix common PA2108 errors:
echo - GroupContainer + OnSelect → Rectangle
echo - Gallery VariableHeight + WrapCount → Remove WrapCount
echo - Classic/Button + Invalid properties → Remove/Replace
echo - Rectangle + Individual corner radius → BorderRadius
echo - Classic/TextInput + Invalid properties → Remove/Replace
echo.
pause

echo.
echo 🚀 Running PA2108 fixer...
python "%~dp0fix_pa2108_properties.py"

echo.
echo ✅ PA2108 fixing completed!
echo.
echo 📋 Check the output above for details on what was fixed.
echo 📁 Backup files were created automatically.
echo.
pause 
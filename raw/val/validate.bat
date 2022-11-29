@echo off
rem Default UBL 2 two-phase validation for XP

if "a%~2" == "a" goto :usage
if "a%~3" == "a" goto :ready
:usage
echo Usage: validate.bat  ubl-schema-file  ubl-xml-file
exit /B 1
:ready

set UBLversion=2.4
echo.
echo ############################################################
echo Validating %2
echo ############################################################

if exist "%~2.error.txt" del "%~2.error.txt"
if exist "%~2.svrl.xml" del "%~2.svrl.xml"

echo ============== Phase 1: XSD schema validation ==============
call "%~dp0w3cschema.bat" "%~1" "%~2" > "%~2.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :errorExit
echo No schema validation errors.

echo ============ Phase 2: XSLT value validation ============
call "%~dp0xslt2.bat" "%~2" "%~dp0UBL-DefaultDTQ-%UBLversion%.xsl" "%~2.svrl.xml" 2> "%~2.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :errorExit
del "%~2.error.txt"

call "%~dp0xslt2.bat" "%~2.svrl.xml" "%~dp0testSVRL4UBLerrors.xsl" nul 2> "%~2.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :errorExit

echo No value validation errors.
del "%~2.svrl.xml"
del "%~2.error.txt"
goto :done

:errorExit
type "%~2.error.txt"

:done
exit /B %errorRet%
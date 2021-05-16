@echo off
rem Validate a DocBook document for OASIS document-writing rules
rem
rem Syntax: validate.sh docbook-file

echo.
echo ############################################################
echo Validating "%~1"
echo ############################################################
@echo off
echo ============== Phase 1: DTD validation ==============
call "%~dp0dtd.bat" "%~1" >output.txt
set errorReturn=%errorLevel%
if %errorReturn% neq 0 goto :error
echo No DTD validation errors.

echo ============ Phase 2: Writing rules validation ============
call "%~dp0xslt2.bat" "%~1" "%~dp0\..\oasis-spec-note.xsl" nul 2>output.txt
set errorReturn=%errorLevel%
if %errorReturn% neq 0 goto :error
echo No writing rule validation errors.
goto :done

:error
type output.txt

:done
exit /B %errorReturn%
@echo off
if "a%~3" == "a" goto :usage
if "a%~4" == "a" goto :ready
:usage
echo Usage: xslt.bat  xml-file  xslt-file  output-file
exit /B 1
:ready

java -jar "%~dp0saxon.jar" -o "%~3" "%~1" "%~2"

@echo off
if "a%~2" == "a" goto :usage
if "a%~3" == "a" goto :ready
:usage
echo Usage: w3cschema.bat  schema-file  xml-file
exit /B 1
:ready

java -jar "%~dp0xjparse.jar" -c %~dp0catalog.xml -S "%~1" "%~2"

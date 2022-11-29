@echo off
if "a%~3" == "a" goto :usage
if "a%~4" == "a" goto :ready
:usage
echo Usage: xslt2.bat  xml-file  xslt-file  output-file
exit /B 1
:ready

java -jar "%~dp0saxon9he.jar" "-o:%~3" "-s:%~1" "-xsl:%~2"

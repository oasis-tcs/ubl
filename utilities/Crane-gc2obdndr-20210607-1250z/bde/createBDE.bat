@echo off

echo ...checking...
java -jar ../saxon9he/saxon9he.jar -o:checkBDE.html -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-checkgc4obdndr.xsl config-uri=../config-bde-1.1.xml "title-suffix=Demo BDE" "change-suffix=Demo" 
if %errorlevel% neq 0 goto :done

echo ...building...
java -jar ../saxon9he/saxon9he.jar -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-gc2obdndr.xsl -o:junk.out config-uri=../config-bde-1.1.xml qdt-for-UBL-2.1-only=yes
if %errorlevel% neq 0 goto :done

echo ...summarizing...
java -jar ../saxon9he/saxon9he.jar -o:summary/junk.out -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-gc2obdsummary.xsl config-uri=../config-bde-1.1.xml "title-prefix=Demo BDE" 
if %errorlevel% neq 0 goto :done

@echo off

echo Timesheet extension...
echo ...checking...
java -jar ../saxon9he/saxon9he.jar -o:checkExt.html -s:mod/MyTimesheetExtension-Entities.gc -xsl:../Crane-checkgc4obdndr.xsl config-uri=../config-myext.xml base-gc-uri=UBL-Entities-2.1.gc "title-suffix=Demo MyExt" "change-suffix=Demo"
if %errorlevel% neq 0 goto :done

echo ...building...
java -jar ../saxon9he/saxon9he.jar -s:mod/MyTimesheetExtension-Entities.gc -xsl:../Crane-gc2obdndr.xsl -o:junk.out config-uri=../config-myext.xml base-gc-uri=UBL-Entities-2.1.gc base-config-uri=../config-ubl-2.1.xml
if %errorlevel% neq 0 goto :done

echo ...summarizing...
java -jar ../saxon9he/saxon9he.jar -o:summary/junk.out -s:mod/MyTimesheetExtension-Entities.gc -xsl:../Crane-gc2obdsummary.xsl config-uri=../config-myext.xml base-summary-uri=UBL-Invoice-2.1.html "title-prefix=Demo MyExt" base-gc-uri=UBL-Entities-2.1.gc "copyright-text=Copyright &#169; example.com; Portions copyright &#169; OASIS Open"
if %errorlevel% neq 0 goto :done

:done
@echo off

echo RAR document...
echo ...checking...
java -jar ../saxon9he/saxon9he.jar -o:checkRAR.html -s:mod/MyRARequestResponse-Entities.gc -xsl:../Crane-checkgc4obdndr.xsl config-uri=../config-rar.xml base-config-uri=../config-ubl-2.1.xml base-gc-uri=UBL-Entities-2.1.gc "title-suffix=Demo RAR" "change-suffix=Demo"
if %errorlevel% neq 0 goto :done

echo ...building RARequest... 
java -jar ../saxon9he/saxon9he.jar -s:mod/MyRARequestResponse-Entities.gc -xsl:../Crane-gc2obdndr.xsl -o:junk.out config-uri=../config-rar.xml base-uri=UBL-Entities-2.1.gc base-config-uri=../config-ubl-2.1.xml base-gc-uri=UBL-Entities-2.1.gc
if %errorlevel% neq 0 goto :done

echo ...summarizing...
java -jar ../saxon9he/saxon9he.jar -o:summary/junk.out all-documents-base-name=RARDocuments -s:mod/MyRARequestResponse-Entities.gc -xsl:../Crane-gc2obdsummary.xsl config-uri=../config-rar.xml base-summary-uri=UBL-Invoice-2.1.html base-gc-uri=UBL-Entities-2.1.gc  "copyright-text=Copyright &#169; example.com; Portions copyright &#169; OASIS Open" "title-prefix=Demo RAR"
if %errorlevel% neq 0 goto :done

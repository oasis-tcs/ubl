@echo off
echo SubsetTest document...
echo ...checking without schemas...
java -jar ../saxon9he/saxon9he.jar -o:checkSubsetTest-noschemas.html -s:mod/SubsetTest-Entities.gc -xsl:../Crane-checkgc4obdndr.xsl config-uri=../config-ubl-2.1-test-no-schema.xml "title-suffix=Demo Subset Test" "change-suffix=Demo" "subset-model-regex=-Invoice-" subset-column-name=SubsetTest subset-absent-is-zero=yes
if %errorlevel% neq 0 goto :done

echo ...building minimal...
java -jar ../saxon9he/saxon9he.jar -s:mod/SubsetTest-Entities.gc -xsl:../Crane-gc2obdndr.xsl -o:minimal/junk.out config-uri=../config-ubl-2.1-test-no-ndr.xml qdt-for-UBL-2.1-only=yes "subset-model-regex=-Invoice-" subset-column-name=SubsetTest subset-absent-is-zero=yes subset-exclusions=no
if %errorlevel% neq 0 goto :done

echo ...building annotated...
java -jar ../saxon9he/saxon9he.jar -s:mod/SubsetTest-Entities.gc -xsl:../Crane-gc2obdndr.xsl -o:annotated/junk.out config-uri=../config-ubl-2.1-test-no-ndr.xml "subset-model-regex=-Invoice-" subset-column-name=SubsetTest subset-absent-is-zero=yes subset-exclusions=yes
if %errorlevel% neq 0 goto :done

echo ...summarizing minimal...
java -jar ../saxon9he/saxon9he.jar -o:minimal/summary/junk.out -s:mod/SubsetTest-Entities.gc -xsl:../Crane-gc2obdsummary.xsl "title-prefix=Demo Subset Test" "subset-model-regex=-Invoice-" subset-column-name=SubsetTest subset-absent-is-zero=yes subset-exclusions=no "copyright-text=Copyright &#169; example.com; Portions copyright &#169; OASIS Open"
if %errorlevel% neq 0 goto :done

echo ...summarizing annotated...
java -jar ../saxon9he/saxon9he.jar -o:annotated/summary/junk.out -s:mod/SubsetTest-Entities.gc -xsl:../Crane-gc2obdsummary.xsl "title-prefix=Demo Subset Test" "subset-model-regex=-Invoice-" subset-column-name=SubsetTest subset-absent-is-zero=yes subset-exclusions=yes "copyright-text=Copyright &#169; example.com; Portions copyright &#169; OASIS Open"
if %errorlevel% neq 0 goto :done


:done

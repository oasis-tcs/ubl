
args=() # subset-exclusions=yes subset-column-name=SubsetACardinality subset-include-type-elements=no subset-include-ignored-types=no  subset-absent-is-zero=yes

echo ...checking...
java -jar ../saxon9he/saxon9he.jar -o:checkBDE.html -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-checkgc4obdndr.xsl config-uri=../config-bde-1.1.xml "title-suffix=Demo BDE" "change-suffix=Demo" ${args[@]}
if [ "$?" != "0" ]; then exit ; fi

echo ...building...
java -jar ../saxon9he/saxon9he.jar -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-gc2obdndr.xsl -o:junk.out config-uri=../config-bde-1.1.xml qdt-for-UBL-2.1-only=yes ${args[@]}
if [ "$?" != "0" ]; then exit ; fi

echo ...summarizing...
java -jar ../saxon9he/saxon9he.jar -o:summary/junk.out -s:mod/BDE-Entities-1.1.gc -xsl:../Crane-gc2obdsummary.xsl config-uri=../config-bde-1.1.xml "title-prefix=Demo BDE" ${args[@]}
if [ "$?" != "0" ]; then exit ; fi

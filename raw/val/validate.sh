# Default UBL 2 two-phase validation for linux

if [ "$2" = "" ] || [ "$3" != "" ]
then
echo Usage: sh validate.sh ubl-schema-file ubl-xml-file
exit 1
fi

UBLversion=2.5
DP0=$( cd "$(dirname "$0")" ; pwd -P )
echo
echo "############################################################"
echo Validating $2
echo "############################################################"

if [ -f "$2.error.txt" ]; then rm "$2.error.txt" ; fi
if [ -f "$2.svrl.xml" ];  then rm "$2.svrl.xml"  ; fi

echo ============== Phase 1: XSD schema validation ==============
sh "$DP0/w3cschema.sh" "$1" "$2" 2>&1 >"$2.error.txt"
errorRet=$?
if [ $errorRet -eq 0 ]
then echo No schema validation errors.
else cat "$2.error.txt"; exit $errorRet
fi
echo ============ Phase 2: XSLT value validation ============
sh "$DP0/xslt2.sh" "$2" "$DP0/UBL-DefaultDTQ-$UBLversion.xsl" "$2.svrl.xml" 2>"$2.error.txt"
errorRet=$?

if [ $errorRet -eq 0 ]
then
sh "$DP0/xslt2.sh" "$2.svrl.xml" "$DP0/testSVRL4UBLerrors.xsl" /dev/null 2>"$2.error.txt"
errorRet=$?

if [ $errorRet -eq 0 ]
then echo No value validation errors. ; rm "$2.svrl.xml" "$2.error.txt"
else cat "$2.error.txt"; exit $errorRet

fi #end of check of massaged SVRL

else cat "$2.error.txt"; exit $errorRet

fi #end of check of raw SVRL

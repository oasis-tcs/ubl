# Default UBL 2 two-phase validation for linux

if [ "$2" = "" ] || [ "$3" != "" ]
then
echo Usage: sh validate.sh ubl-schema-file ubl-xml-file
exit 1
fi

DP0=$( cd "$(dirname "$0")" ; pwd -P )
echo
echo "############################################################"
echo Validating $2
echo "############################################################"
echo ============== Phase 1: XSD schema validation ==============
sh "$DP0/w3cschema.sh" "$1" "$2" 2>&1 >output.txt
errorRet=$?
if [ $errorRet -eq 0 ]
then echo No schema validation errors.
else cat output.txt; exit $errorRet
fi
echo ============ Phase 2: XSLT code list validation ============
sh "$DP0/xslt.sh" "$2" "$DP0/UBL-DefaultDTQ-2.3.xsl" /dev/null 2>output.txt
errorRet=$?
if [ $errorRet -eq 0 ]
then echo No code list validation errors.
else cat output.txt; exit $errorRet
fi

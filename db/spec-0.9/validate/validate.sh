# Validate a DocBook document for OASIS document-writing rules
#
# Syntax: validate.sh docbook-file

DP0=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo
echo "############################################################"
echo Validating $1
echo "############################################################"
echo ============== Phase 1: DTD validation ==============
sh $DP0/dtd.sh $1 2>&1 >output.txt
errorReturn=$?
if [ $errorReturn -eq 0 ]
then echo No DTD validation errors.
else cat output.txt; exit $errorReturn
fi
echo ============ Phase 2: Writing rules validation ============
sh $DP0/xslt2.sh $1 $DP0/../oasis-spec-note.xsl /dev/null 2>output.txt
errorReturn=$?
if [ $errorReturn -eq 0 ]
then echo No writing rule validation errors.
else cat output.txt
fi
exit $errorReturn

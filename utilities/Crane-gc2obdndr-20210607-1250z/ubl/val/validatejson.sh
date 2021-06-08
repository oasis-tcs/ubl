# JSON validation
#
# Syntax: validatejson ubl-json-schema-file ubl-json-file
DP0=$( cd "$(dirname "$0")" ; pwd -P )
echo
echo "############################################################"
echo Validating $2
echo "############################################################"
python $DP0/jsonvalidate.py -q $1 $2 2>&1 >output.txt
if [ $? -eq 0 ]
then echo No schema validation errors.
else cat output.txt; exit 1
fi

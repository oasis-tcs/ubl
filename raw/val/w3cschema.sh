if [ "$2" = "" ] || [ "$3" != "" ]
then
echo Usage: sh w3cschema.sh schema-file xml-file
exit 1
fi

DP0=$( cd "$(dirname "$0")" ; pwd -P )
java -jar "$DP0/xjparse.jar" -c "$DP0/catalog.xml" -S "$1" "$2"
errorRet=$?
exit $errorRet

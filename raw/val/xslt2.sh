if [ "$3" = "" ] || [ "$4" != "" ]
then
echo Usage: sh xslt2.sh xml-file xslt-file output-file
exit 1
fi

DP0=$( cd "$(dirname "$0")" ; pwd -P )
java -jar "$DP0/saxon9he.jar" "-o:$3" "-s:$1" "-xsl:$2"
errorRet=$?
exit $errorRet

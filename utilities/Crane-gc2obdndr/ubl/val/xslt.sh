DP0=$( cd "$(dirname "$0")" ; pwd -P )
java -jar $DP0/../../saxon9he/saxon9he.jar -s:$1 -xsl:$2 -o:$3 -versionmsg:off
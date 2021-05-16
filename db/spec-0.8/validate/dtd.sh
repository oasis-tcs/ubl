DP0=$( cd "$(dirname "$0")" ; pwd -P )

java -jar $DP0/xjparse.jar -v -c $DP0/../catalog.xml $1
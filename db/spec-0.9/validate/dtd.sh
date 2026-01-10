DP0=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

java -jar $DP0/xjparse.jar -v -c $DP0/../catalog.xml $1
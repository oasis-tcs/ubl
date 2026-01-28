DP0=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

java -jar $DP0/xjparse.jar -v -c $DP0/../catalog.xml $1
DP0=$( cd "$(dirname "$0")" ; pwd -P )
java -cp $DP0/xjparse.jar:$DP0/resolver.jar:$DP0/xercesImpl.jar:$DP0 com.nwalsh.parsers.xjparse -c catalog.xml -S $1 $2
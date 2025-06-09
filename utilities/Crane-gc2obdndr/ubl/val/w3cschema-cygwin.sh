DP0=$( cd "$(dirname "$0")" ; pwd -P )
java -cp "$DP0/xjparse.jar;$DP0/resolver.jar;$DP0/xercesImpl.jar;." com.nwalsh.parsers.xjparse -c $DP0/catalog.xml -S $1 $2
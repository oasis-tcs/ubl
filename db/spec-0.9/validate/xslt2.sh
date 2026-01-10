DP0=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

java -cp "$DP0/saxon9he.jar:$DP0/lib/resolver.jar" net.sf.saxon.Transform -catalog:$DP0/../catalog.xml -o:$3 -s:$1 -xsl:$2

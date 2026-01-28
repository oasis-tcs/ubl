@echo off
java -cp "%~dp0saxon9he.jar;%~dp0lib/resolver.jar" net.sf.saxon.Transform "-catalog:%~dp0../catalog.xml" "-o:%~3" "-s:%~1" "-xsl:%~2"

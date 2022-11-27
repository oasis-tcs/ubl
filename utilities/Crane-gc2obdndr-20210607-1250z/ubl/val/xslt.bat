@echo off
java -jar ..\..\saxon9he\saxon9he.jar "-s:%~1" "-xsl:%~2" "-o:%~3" -versionmsg:off

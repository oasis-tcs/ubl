@echo off
java -cp "xjparse.jar;resolver.jar;xercesImpl.jar;." com.nwalsh.parsers.xjparse -c catalog.xml -S %1 %2

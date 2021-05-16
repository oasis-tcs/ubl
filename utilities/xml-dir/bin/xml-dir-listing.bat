@echo off

REM Reset variables

set XML_DIR_LISTING_HOME=
set LOCAL_CP=

REM Get XML_DIR_LISTING_HOME

set XML_DIR_LISTING_HOME=%~dp0..

REM Get local classpath

set LOCAL_CP=%XML_DIR_LISTING_HOME%\lib\xercesImpl.jar;%XML_DIR_LISTING_HOME%\lib\xml-dir-listing.0.2.jar;%XML_DIR_LISTING_HOME%\lib\commons-cli-1.1.jar;%XML_DIR_LISTING_HOME%\lib\jakarta-regexp-1.5.jar;%XML_DIR_LISTING_HOME%\lib\log4j-1.2.14.jar

REM echo %LOCAL_CP%

REM Run app

java -classpath "%LOCAL_CP%" net.matthaynes.xml.dirlist.DirectoryListing %*
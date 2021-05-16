#  Configured for 0.8
#  
#  Windows batch file for publishing an OASIS specification DocBook XML instance
#
#  Assumes three batch files exist in the system:
#
#      xmldtd  input-XML-file
#
#      xslt  input-XML-file  stylesheet-XSL-file  output-file
#
#      xslfo-pdf  input-FO-file  output-PDF-file
#
#  $Id: oasis-specification.bat,v 1.13 2011/11/09 17:56:15 admin Exp $

if [ "a$2" == "a" ]; then
echo Missing version of document as first argument and stage as second argument
exit 1
fi

oasisssdir=/Users/admin/z/oasis/spec-0.8/stylesheets
oasisssdir=stylesheets

echo Validating instance...
xmldtd oasis-specification-$1-$2.xml
if [ "$?" != "0" ]; then exit 1; fi
echo Making relative HTML...
xslt oasis-specification-$1-$2.xml $oasisssdir/oasis-note-html-offline.xsl oasis-specification-$1-$2-relative.html
if [ "$?" != "0" ]; then exit 1; fi
echo Making offline HTML...
xslt oasis-specification-$1-$2-offline.xml $oasisssdir/oasis-note-html-offline.xsl oasis-specification-$1-$2-offline.html
if [ "$?" != "0" ]; then exit 1; fi
echo Making online HTML...
xslt oasis-specification-$1-$2-online.xml $oasisssdir/oasis-note-html.xsl nul automatic-output-filename=yes
if [ "$?" != "0" ]; then exit 1; fi
echo Making XSL-FO US...
xslt oasis-specification-$1-$2.xml $oasisssdir/oasis-note-fo-us.xsl nul automatic-output-filename=yes
if [ "$?" != "0" ]; then exit 1; fi
echo Making PDF US...
xslfo-pdf oasis-specification-$1-$2.fo oasis-specification-$1-$2-us.pdf
if [ "$?" != "0" ]; then exit 1; fi
echo Making XSL-FO A4...
xslt oasis-specification-$1-$2.xml $oasisssdir/oasis-note-fo-a4.xsl nul automatic-output-filename=yes
if [ "$?" != "0" ]; then exit 1; fi
echo Making PDF A4...
xslfo-pdf oasis-specification-$1-$2.fo oasis-specification-$1-$2.pdf
if [ "$?" != "0" ]; then exit 1; fi

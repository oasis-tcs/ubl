#
#  Shell script for publishing an OASIS specification DocBook XML instance
#
#  Assumes three script files exist in the system:
#
#      xmldtd  input-XML-file
#
#      xslt  input-XML-file  stylesheet-XSL-file  output-file
#
#      xslfo-pdf  input-FO-file  output-PDF-file
#

oasisssdir=http://docs.oasis-open.org/templates/DocBook/spec-0.8/stylesheets/
oasisssdir=../stylesheets/

echo Validating instance...
xmldtd spec-docbook-template-$1-$2.xml
echo Making relative HTML...
xslt spec-docbook-template-$1-$2.xml $oasisssdir/oasis-specification-html-offline.xsl spec-docbook-template-$1-$2-relative.html
echo Making offline HTML...
xslt spec-docbook-template-$1-$2-offline.xml $oasisssdir/oasis-specification-html-offline.xsl spec-docbook-template-$1-$2-offline.html
echo Making online HTML...
xslt spec-docbook-template-$1-$2-online.xml $oasisssdir/oasis-specification-html.xsl /dev/null automatic-output-filename=yes
echo Making XSL-FO US...
xslt spec-docbook-template-$1-$2.xml $oasisssdir/oasis-specification-fo-us.xsl /dev/null automatic-output-filename=yes
echo Making PDF US...
xslfo-pdf spec-docbook-template-$1-$2.fo spec-docbook-template-$1-$2-us.pdf
echo Making XSL-FO A4...
xslt spec-docbook-template-$1-$2.xml $oasisssdir/oasis-specification-fo-a4.xsl /dev/null automatic-output-filename=yes
echo Making PDF A4...
xslfo-pdf spec-docbook-template-$1-$2.fo spec-docbook-template-$1-$2.pdf


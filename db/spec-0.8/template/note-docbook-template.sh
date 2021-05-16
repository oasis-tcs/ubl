#
#  Shell script for publishing an OASIS committee note DocBook XML instance
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
xmldtd note-docbook-template-$1-$2.xml
echo Making relative HTML...
xslt note-docbook-template-$1-$2.xml $oasisssdir/oasis-note-html-offline.xsl note-docbook-template-$1-$2-relative.html
echo Making offline HTML...
xslt note-docbook-template-$1-$2-offline.xml $oasisssdir/oasis-note-html-offline.xsl note-docbook-template-$1-$2-offline.html
echo Making online HTML...
xslt note-docbook-template-$1-$2-online.xml $oasisssdir/oasis-note-html.xsl /dev/null automatic-output-filename=yes
echo Making XSL-FO US...
xslt note-docbook-template-$1-$2.xml $oasisssdir/oasis-note-fo-us.xsl /dev/null automatic-output-filename=yes
echo Making PDF US...
xslfo-pdf note-docbook-template-$1-$2.fo note-docbook-template-$1-$2-us.pdf
echo Making XSL-FO A4...
xslt note-docbook-template-$1-$2.xml $oasisssdir/oasis-note-fo-a4.xsl /dev/null automatic-output-filename=yes
echo Making PDF A4...
xslfo-pdf note-docbook-template-$1-$2.fo note-docbook-template-$1-$2.pdf


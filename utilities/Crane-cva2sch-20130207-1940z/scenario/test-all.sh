#
#  Illustration of UBL Code List Value Validation Methodology
#  
#  $Id: test-all.sh,v 1.17 2009/10/08 22:00:07 gkholman Exp $
#

echo Precondition validation...
echo
echo Validating partner-agreed constraints...
echo :  w3cschema ContextValueAssociation.xsd order-constraints.cva
sh ../utility/w3cschema.sh ../utility/ContextValueAssociation.xsd order-constraints.cva 2>&1 >test-constraints.txt
cat test-constraints.txt
echo
echo :  w3cschema ContextValueAssociation.xsd order-combined.cva
sh ../utility/w3cschema.sh ../utility/ContextValueAssociation.xsd order-combined.cva 2>&1 >test-constraints.txt
cat test-constraints.txt
echo
echo Validating code lists...
echo   w3cschema genericode.xsd CA_CountrySubentityCode.gc
sh ../utility/w3cschema.sh ../utility/genericode.xsd CA_CountrySubentityCode.gc 2>&1 >test-constraints.txt
cat test-constraints.txt
echo   w3cschema genericode.xsd US_CountrySubentityCode.gc
sh ../utility/w3cschema.sh ../utility/genericode.xsd US_CountrySubentityCode.gc 2>&1 >test-constraints.txt
cat test-constraints.txt
echo   w3cschema.sh genericode.xsd CAUS_CurrencyCode.gc
sh ../utility/w3cschema.sh ../utility/genericode.xsd CAUS_CurrencyCode.gc 2>&1 >test-constraints.txt
cat test-constraints.txt
echo   w3cschema.sh genericode.xsd TaxIdentifier.gc
sh ../utility/w3cschema.sh ../utility/genericode.xsd TaxIdentifier.gc 2>&1 >test-constraints.txt
cat test-constraints.txt
echo   w3cschema.sh genericode.xsd Additional_PaymentMeansCode.gc
sh ../utility/w3cschema.sh ../utility/genericode.xsd Additional_PaymentMeansCode.gc 2>&1 >test-constraints.txt
cat test-constraints.txt
echo
echo Preparing code list rules...
echo
echo Translating partner-agreed constraints into Schematron rules...
echo :  xslt order-constraints.cva 
echo :       ../utility/Crane-cva2schXSLT.xsl
echo :       order-constraints.sch.xsl
sh ../utility/xslt.sh order-constraints.cva ../utility/Crane-cva2schXSLT.xsl order-constraints.sch.xsl >test-constraints.txt
cat test-constraints.txt
echo :  xslt order-constraints.sch.xsl 
echo :       order-constraints.sch.xsl
echo :       order-constraints.sch
sh ../utility/xslt.sh order-constraints.sch.xsl order-constraints.sch.xsl order-constraints.sch >test-constraints.txt
cat test-constraints.txt
echo
echo :  xslt order-combined.cva 
echo :       ../utility/Crane-cva2schXSLT.xsl
echo :       order-combined.sch.xsl
sh ../utility/xslt.sh order-combined.cva ../utility/Crane-cva2schXSLT.xsl order-combined.sch.xsl >test-constraints.txt
cat test-constraints.txt
echo :  xslt order-combined.sch.xsl
echo :       order-combined.sch.xsl
echo :       order-combined.sch
sh ../utility/xslt.sh order-combined.sch.xsl order-combined.sch.xsl order-combined.sch >test-constraints.txt
cat test-constraints.txt
echo
echo Test 1 - standalone code list rules
echo
echo Assembling rules into a Schematron schema...
echo :  xslt codes-only-constraints.sch ../utility/iso_schematron_assembly.xsl 
echo                                                      order-codes-only.sch
sh ../utility/xslt.sh codes-only-constraints.sch ../utility/iso_schematron_assembly.xsl order-codes-only.sch >test-constraints.txt
cat test-constraints.txt
echo
echo Translating Schematron into validation stylesheet...
echo :  xslt order-codes-only.sch ../utility/Message-Schematron-terminator.xsl 
echo                                                      order-codes-only.xsl
sh ../utility/xslt.sh order-codes-only.sch ../utility/Message-Schematron-terminator.xsl order-codes-only.xsl >test-constraints.txt
cat test-constraints.txt
echo
echo Document validation...
echo
echo Testing order-test-good1.xml...
echo :  xslt order-test-good1.xml order-codes-only.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-good1.xml order-codes-only.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo
echo
echo Testing order-test-good2.xml...
echo :  xslt order-test-good2.xml order-codes-only.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-good2.xml order-codes-only.xsl /dev/null 2>test-constraints.txt   
echo Result: $?
cat test-constraints.txt
echo
echo
echo Testing order-test-bad1.xml...
echo :  xslt order-test-bad1.xml order-codes-only.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-bad1.xml order-codes-only.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo
echo
echo Testing order-test-bad2.xml...
echo :  xslt order-test-bad2.xml order-codes-only.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-bad2.xml order-codes-only.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo
echo
echo Testing order-test-bad3.xml...
echo :  xslt order-test-bad3.xml order-codes-only.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-bad3.xml order-codes-only.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo
echo
echo
echo Test 2 - with business rule expressed as a value test
echo
echo Assembling rules into a Schematron schema...
echo :  xslt order-combined-only.sch ../utility/iso_schematron_assembly.xsl 
echo                                                      order-codes-combined.sch
sh ../utility/xslt.sh order-combined-only.sch ../utility/iso_schematron_assembly.xsl order-codes-combined.sch >test-constraints.txt
echo
echo Translating Schematron into validation stylesheet...
echo   xslt order-codes-combined.sch ../utility/Message-Schematron-terminator.xsl 
echo                                                      order-codes-combined.xsl
sh ../utility/xslt.sh order-codes-combined.sch ../utility/Message-Schematron-terminator.xsl order-codes-combined.xsl >test-constraints.txt
echo
echo Document validation...
echo
echo
echo Testing order-test-bad3.xml...
echo :  xslt order-test-bad3.xml order-codes-combined.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-bad3.xml order-codes-combined.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo
echo
echo
echo Test 3 - with business rule expressed as Schematron
echo
echo Assembling rules into a Schematron schema...
echo :  xslt total-constraints.sch ../utility/iso_schematron_assembly.xsl 
echo                                                      order-codes-total.sch
sh ../utility/xslt.sh total-constraints.sch ../utility/iso_schematron_assembly.xsl order-codes-total.sch >test-constraints.txt
echo
echo Translating Schematron into validation stylesheet...
echo   xslt order-codes-total.sch ../utility/Message-Schematron-terminator.xsl 
echo                                                      order-codes-total.xsl
sh ../utility/xslt.sh order-codes-total.sch ../utility/Message-Schematron-terminator.xsl order-codes-total.xsl >test-constraints.txt
echo
echo Document validation...
echo
echo
echo Testing order-test-bad3.xml...
echo :  xslt order-test-bad3.xml order-codes-total.xsl /dev/null test-constraints.txt
sh ../utility/xslt.sh order-test-bad3.xml order-codes-total.xsl /dev/null 2>test-constraints.txt
echo Result: $?
cat test-constraints.txt
echo

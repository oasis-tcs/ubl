@echo off

rem
rem  Illustration of CVA implementation using Schematron
rem
rem  $Id: test-all.bat,v 1.21 2009/05/23 21:21:24 gkholman Exp $
rem

if not exist ..\utility\ContextValueAssociation.xsd goto :nofile

echo Precondition validation...
echo.

echo Validating partner-agreed constraints...
echo   w3cschema ContextValueAssociation.xsd order-constraints.cva
call ..\utility\w3cschema ..\utility\ContextValueAssociation.xsd order-constraints.cva 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo   w3cschema ContextValueAssociation.xsd order-combined.cva
call ..\utility\w3cschema ..\utility\ContextValueAssociation.xsd order-combined.cva 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Validating code lists...
echo   w3cschema genericode.xsd CA_CountrySubentityCode.gc
call ..\utility\w3cschema ..\utility\genericode.xsd CA_CountrySubentityCode.gc 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo   w3cschema genericode.xsd US_CountrySubentityCode.gc
call ..\utility\w3cschema ..\utility\genericode.xsd US_CountrySubentityCode.gc 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo   w3cschema genericode.xsd CAUS_CurrencyCode.gc
call ..\utility\w3cschema ..\utility\genericode.xsd CAUS_CurrencyCode.gc 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo   w3cschema genericode.xsd TaxIdentifier.gc
call ..\utility\w3cschema ..\utility\genericode.xsd TaxIdentifier.gc 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo   w3cschema genericode.xsd Additional_PaymentMeansCode.gc
call ..\utility\w3cschema ..\utility\genericode.xsd Additional_PaymentMeansCode.gc 2>&1 >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Preparing code list rules...
echo.
echo Translating partner-agreed constraints into Schematron rules...
echo  xslt order-constraints.cva 
echo       ..\utility\Crane-cva2schXSLT.xsl
echo       order-constraints.sch.xsl
call ..\utility\xslt order-constraints.cva ..\utility\Crane-cva2schXSLT.xsl order-constraints.sch.xsl >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo  xslt order-constraints.sch.xsl order-constraints.sch.xsl order-constraints.sch
call ..\utility\xslt order-constraints.sch.xsl order-constraints.sch.xsl order-constraints.sch >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo.
echo  xslt order-combined.cva 
echo       ..\utility\Crane-cva2schXSLT.xsl
echo       order-combined.sch.xsl
call ..\utility\xslt order-combined.cva ..\utility\Crane-cva2schXSLT.xsl order-combined.sch.xsl >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt
echo  xslt order-combined.sch.xsl order-combined.sch.xsl order-combined.sch
call ..\utility\xslt order-combined.sch.xsl order-combined.sch.xsl order-combined.sch >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Test 1 - standalone code list rules
echo.
echo Assembling rules into a Schematron schema...
echo   xslt codes-only-constraints.sch ..\utility\iso_schematron_assembly.xsl 
echo                                                      order-codes-only.sch
call ..\utility\xslt codes-only-constraints.sch ..\utility\iso_schematron_assembly.xsl order-codes-only.sch >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Translating Schematron into validation stylesheet...
echo   xslt order-codes-only.sch ..\utility\Message-Schematron-terminator.xsl 
echo                                                      order-codes-only.xsl
call ..\utility\xslt order-codes-only.sch ..\utility\Message-Schematron-terminator.xsl order-codes-only.xsl >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Document validation...
echo.
echo Testing order-test-good1.xml...
echo   xslt order-test-good1.xml order-codes-only.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-good1.xml order-codes-only.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.
echo.
echo Testing order-test-good2.xml...
echo   xslt order-test-good2.xml order-codes-only.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-good2.xml order-codes-only.xsl nul 2>test-constraints.txt   
echo Result: %errorlevel%
type test-constraints.txt
echo.
echo.
echo Testing order-test-bad1.xml...
echo   xslt order-test-bad1.xml order-codes-only.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-bad1.xml order-codes-only.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.
echo.
echo Testing order-test-bad2.xml...
echo   xslt order-test-bad2.xml order-codes-only.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-bad2.xml order-codes-only.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.
echo.
echo Testing order-test-bad3.xml...
echo   xslt order-test-bad3.xml order-codes-only.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-bad3.xml order-codes-only.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.

echo.
echo Test 2 - with business rule expressed as a value test
echo.
echo Assembling rules into a Schematron schema...
echo   xslt order-combined-only.sch ..\utility\iso_schematron_assembly.xsl 
echo                                                      order-codes-combined.sch
call ..\utility\xslt order-combined-only.sch ..\utility\iso_schematron_assembly.xsl order-codes-combined.sch >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Translating Schematron into validation stylesheet...
echo   xslt order-codes-combined.sch ..\utility\Message-Schematron-terminator.xsl 
echo                                                      order-codes-combined.xsl
call ..\utility\xslt order-codes-combined.sch ..\utility\Message-Schematron-terminator.xsl order-codes-combined.xsl >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Document validation...
echo.
echo Testing order-test-bad3.xml...
echo   xslt order-test-bad3.xml order-codes-combined.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-bad3.xml order-codes-combined.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.

echo.
echo Test 3 - with business rule expressed as Schematron
echo.
echo Assembling rules into a Schematron schema...
echo   xslt total-constraints.sch ..\utility\iso_schematron_assembly.xsl 
echo                                                      order-codes-total.sch
call ..\utility\xslt total-constraints.sch ..\utility\iso_schematron_assembly.xsl order-codes-total.sch >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Translating Schematron into validation stylesheet...
echo   xslt order-codes-total.sch ..\utility\Message-Schematron-terminator.xsl 
echo                                                      order-codes-total.xsl
call ..\utility\xslt order-codes-total.sch ..\utility\Message-Schematron-terminator.xsl order-codes-total.xsl >test-constraints.txt
if %errorlevel% neq 0 goto :error
type test-constraints.txt

echo.
echo Document validation...
echo.
echo Testing order-test-bad3.xml...
echo   xslt order-test-bad3.xml order-codes-total.xsl nul "2>test-constraints.txt"
call ..\utility\xslt order-test-bad3.xml order-codes-total.xsl nul 2>test-constraints.txt
echo Result: %errorlevel%
type test-constraints.txt
echo.

echo.
echo Done.
goto :done

:nofile
echo.
echo Document model for constraints not found: ..\utility\ContextValueAssociation.xsd
goto :done

:error
type test-constraints.txt
echo.
echo Error; process terminated!
goto :done

:done

Crane-ods2obdgc.xsl

This is a stylesheet to convert instances of spreadsheet ODS binary or
ODS XML into a genericode file suitable for processing according to the
OASIS Business Document (OBD) Naming and Design Rules (NDR).

Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/training-gctk.htm

Portions copyright (C) - OASIS Open 2015. All Rights Reserved.
                       - http://www.oasis-open.org/who/intellectualproperty.php

This documentation and the URI resolution of the XSLT processor both presume
the use of the free Saxon9HE XSLT processor from http://saxon.sf.net ... if
that XSLT 2.0 processor is not being used, then the results may not be as
expected.

Input file (choose one of the following three options):

 (a) -s:{filename} - an XML file listing as the input invocation argument
       that lists the directories and files in which to find the names of
       files that can be either an ODS XML content file or an ODS binary
       file to be amalgamated into a single output file (see below for a
       copy of the ubl21files.xml example file)
 (b) -it:ods-uri ods-uri={filename,filename,filename}
      - comma-separated list of names of ODS binary files to be amalgamated
        into a single output file
      - both arguments shown must be supplied
 (c) -s:{filename} - an ODS XML content file as the input invocation argument

Additional invocation arguments:

 - stylesheet file:              -xsl:Crane-ods2obdgc.xsl
 - output genericode file:       -o:{filename}
 
Additional optional invocation parameters:

 - add row as a column value:  row-number-column-name={string}
   - use this argument to add the row number of each row as a genericode
     column simple value, by naming the new column to be added

 - identification metadata:      identification-uri={filename}
   - an XML document to use in place of defaulted metadata; the file is
     of the form of the identification element:

    <Identification>
      <ShortName>OBDNDRSkeleton</ShortName>
      <LongName>OASIS Business Document NDR skeleton genericode file</LongName>
      <Version>1</Version>
      <CanonicalUri>urn:X-CraneSoftwrights.com</CanonicalUri>
      <CanonicalVersionUri>urn:X-CraneSoftwrights.com</CanonicalVersionUri>
    </Identification>

   (note that a relative URI is relative to the stylesheet, not the data;
    use an absolute URI to avoid using a relative URI)

 - indentation of the result:    indent=yes/no (default 'yes')
 
 - indication of raw output:     raw-sheet-long-name={long name of sheet field}
   - the raw output is used when the output is not destined for the OBD NDR
   - the raw output has no key fields and all fields are marked as optional
   - the raw sheet long name, and the derived short name, are used as column
     identifiers for the sheet name value
   - set the raw sheet long name to the empty string to suppress output of the
     sheet name value

 - selective worksheet outputs:  included-sheet-name-regex={regex}
   - all worksheets are output unless this regular expression is specified
     with the names of the worksheets that are to be output

 - massaging worksheet names:    lengthen-model-name-uri={filename}
   this points to an XML document with regular expressions used to reverse
   the act of shortening worksheet names; the example in the file (copied
   below) massageModelName-2.1.xml illustrates the shortening and lengthening
   of names to sidestep the bug in Google Docs (see *)
   (note that a relative URI is relative to the stylesheet, not the data;
    use an absolute URI to avoid using a relative URI)

Spreadsheet assumptions:

Each worksheet tab of the spreadsheet is assumed to be a separate model.  The 
first row of the worksheet tab is assumed to be item headings.  The order of 
the columns is not significant.  Empty rows are ignored.  A row whose entire 
text content of the concatenation of all columns is the word "END" signals 
that any subsequent rows are ignored because they are documentary.

Note that if your spreadsheet is in Microsoft Excel format it can be translated
into OpenDocument Format Spreadsheet (ODS) by one of these free approaches:

 (a) - uploading the XLS to Google Drive, opening the spreadsheet on Google,
       then using File/"Download as..." as an "OpenDocument format (.ods)" file
       unless the worksheet names are longer than 31 characters (see *)
 (b) - use the http://www.CraneSoftwrights.com/resources/index.htm#xls2ods2xml
       package after installing it in Open Office

Google Docs:

*  As of April 2016 Google Docs has a bug in that it imports worksheet
   names longer than 31 characters but truncates those names to 31 characters
   when exporting as an ODS file.  Even when this bug is repaired, the maximum
   ODS sheet name appears to be 50 characters.  The special massaging will be
   needed for document type names that are longer than worksheet name limits.

Seed stylesheet:

This package includes the file "Empty CCTS Model.ods" that includes an empty 
row for each of the ABIE, BBIE and ASBIE component types, plus the appropriate
column headers and guidance pop-ups.

The specification for OASIS genericode is here:

    http://docs.oasis-open.org/codelist/genericode
    
The rows of the spreadsheet are converted into rows of genericode, stopping
at either the end of the spreadsheet worksheet or at the row whose entire
content is the word "END" (whichever comes first).

THE AUTHOR MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS CODE FOR ANY
PURPOSE. THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR 
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN 
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--------------------

Example input XML file of document names (included as ubl21files.xml):

<directory name=".">
  <directory name="maindoc">
    <file name="UBL-ApplicationResponse-2.1.ods"/>
    <file name="UBL-AttachedDocument-2.1.ods"/>
    <file name="UBL-AwardedNotification-2.1.ods"/>
    <file name="UBL-BillOfLading-2.1.ods"/>
    <file name="UBL-CallForTenders-2.1.ods"/>
    <file name="UBL-Catalogue-2.1.ods"/>
    <file name="UBL-CatalogueDeletion-2.1.ods"/>
    <file name="UBL-CatalogueItemSpecificationUpdate-2.1.ods"/>
    <file name="UBL-CataloguePricingUpdate-2.1.ods"/>
    <file name="UBL-CatalogueRequest-2.1.ods"/>
    <file name="UBL-CertificateOfOrigin-2.1.ods"/>
    <file name="UBL-ContractAwardNotice-2.1.ods"/>
    <file name="UBL-ContractNotice-2.1.ods"/>
    <file name="UBL-CreditNote-2.1.ods"/>
    <file name="UBL-DebitNote-2.1.ods"/>
    <file name="UBL-DespatchAdvice-2.1.ods"/>
    <file name="UBL-DocumentStatus-2.1.ods"/>
    <file name="UBL-DocumentStatusRequest-2.1.ods"/>
    <file name="UBL-ExceptionCriteria-2.1.ods"/>
    <file name="UBL-ExceptionNotification-2.1.ods"/>
    <file name="UBL-Forecast-2.1.ods"/>
    <file name="UBL-ForecastRevision-2.1.ods"/>
    <file name="UBL-ForwardingInstructions-2.1.ods"/>
    <file name="UBL-FreightInvoice-2.1.ods"/>
    <file name="UBL-FulfilmentCancellation-2.1.ods"/>
    <file name="UBL-GoodsItemItinerary-2.1.ods"/>
    <file name="UBL-GuaranteeCertificate-2.1.ods"/>
    <file name="UBL-InstructionForReturns-2.1.ods"/>
    <file name="UBL-InventoryReport-2.1.ods"/>
    <file name="UBL-Invoice-2.1.ods"/>
    <file name="UBL-ItemInformationRequest-2.1.ods"/>
    <file name="UBL-Order-2.1.ods"/>
    <file name="UBL-OrderCancellation-2.1.ods"/>
    <file name="UBL-OrderChange-2.1.ods"/>
    <file name="UBL-OrderResponse-2.1.ods"/>
    <file name="UBL-OrderResponseSimple-2.1.ods"/>
    <file name="UBL-PackingList-2.1.ods"/>
    <file name="UBL-PriorInformationNotice-2.1.ods"/>
    <file name="UBL-ProductActivity-2.1.ods"/>
    <file name="UBL-Quotation-2.1.ods"/>
    <file name="UBL-ReceiptAdvice-2.1.ods"/>
    <file name="UBL-Reminder-2.1.ods"/>
    <file name="UBL-RemittanceAdvice-2.1.ods"/>
    <file name="UBL-RequestForQuotation-2.1.ods"/>
    <file name="UBL-RetailEvent-2.1.ods"/>
    <file name="UBL-SelfBilledCreditNote-2.1.ods"/>
    <file name="UBL-SelfBilledInvoice-2.1.ods"/>
    <file name="UBL-Statement-2.1.ods"/>
    <file name="UBL-StockAvailabilityReport-2.1.ods"/>
    <file name="UBL-Tender-2.1.ods"/>
    <file name="UBL-TendererQualification-2.1.ods"/>
    <file name="UBL-TendererQualificationResponse-2.1.ods"/>
    <file name="UBL-TenderReceipt-2.1.ods"/>
    <file name="UBL-TradeItemLocationProfile-2.1.ods"/>
    <file name="UBL-TransportationStatus-2.1.ods"/>
    <file name="UBL-TransportationStatusRequest-2.1.ods"/>
    <file name="UBL-TransportExecutionPlan-2.1.ods"/>
    <file name="UBL-TransportExecutionPlanRequest-2.1.ods"/>
    <file name="UBL-TransportProgressStatus-2.1.ods"/>
    <file name="UBL-TransportProgressStatusRequest-2.1.ods"/>
    <file name="UBL-TransportServiceDescription-2.1.ods"/>
    <file name="UBL-TransportServiceDescriptionRequest-2.1.ods"/>
    <file name="UBL-UnawardedNotification-2.1.ods"/>
    <file name="UBL-UtilityStatement-2.1.ods"/>
    <file name="UBL-Waybill-2.1.ods"/>
  </directory>
  <directory name="common">
    <file name="UBL-CommonLibrary-2.1.ods"/>
  </directory>
</directory>

Example input file of regular expressions to shorten or lengthen names:

<!--
  $Id: massageModelName-2.1.xml,v 1.3 2015/05/06 14:49:29 admin Exp $
  
  Use this file to express the regular expressions that shorten model
  names in document order and lengthen model names in reverse document order.

  Use this expression in the mod/maindoc directory to establish which names
  need shortening to 31 characters or less:

ls *.ods | sed s/UBL-// | sed s/-2.1.ods// | sed -E "s/(.{1,31})(.*)/\1    \2/"

-->
<!DOCTYPE modelNameMassage
[
<!ELEMENT modelNameMassage ( pass+ )>
<!ELEMENT pass ( shorten, lengthen )>
<!ELEMENT shorten EMPTY>
<!ELEMENT lengthen EMPTY>
<!ATTLIST shorten find CDATA #REQUIRED replace CDATA #REQUIRED>
<!ATTLIST lengthen find CDATA #REQUIRED replace CDATA #REQUIRED>
]>
<modelNameMassage>
  <pass>
    <shorten find="UBL-(.+)-2.1" replace="$1"/>
    <lengthen find="(.+)" replace="UBL-$1-2.1"/>
  </pass>
  <pass>
    <shorten find="Catalogue" replace="Ctlg"/>
    <lengthen find="Ctlg" replace="Catalogue"/>
  </pass>
  <pass>
    <shorten find="Transport([^a])" replace="Txp$1"/>
    <lengthen find="Txp" replace="Transport"/>
  </pass>
  <pass>
    <shorten find="Signature" replace="Sgnt"/>
    <lengthen find="Sgnt" replace="Signature"/>
  </pass>
  <pass>
    <shorten find="Confirmation" replace="Conf"/>
    <lengthen find="Conf" replace="Confirmation"/>
  </pass>
</modelNameMassage>


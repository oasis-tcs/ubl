Crane-gc2odsxml.xsl

This is a stylesheet to create the contents of an ODS file from a combination
of a skeleton ODS file and a genericode file.  The end result is a directory
of files to be ZIPped to create the ODS file.  This program does not do the
ZIPping, but all of the files needed are created and the ZIP is the only step
to be done.

Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/training-gctk.htm

Portions copyright (C) - OASIS Open 2015. All Rights Reserved.
                       - http://www.oasis-open.org/who/intellectualproperty.php

This documentation and the URI resolution of the XSLT processor both presume
the use of the free Saxon9HE XSLT processor from http://saxon.sf.net ... if
that XSLT 2.0 processor is not being used, then the results may not be as
expected.

Invocation arguments:

 - input genericode file:      -s:{filename}
 - stylesheet file:            -xsl:Crane-gc2odsxml.xsl
 - output ODS file directory:  -o:{output-directory-name}/dummy

Mandatory invocation parameter:

 - ODS file used as a model:   skeleton-ods-uri={filename}
   - note that two examples of model ODS files are included:
     - skeleton-edit.ods  - read/write; colours highlight protected cells
     - skeleton-display.ods  - read-only; no colour highlighting of cells
   - as of the time of writing the formulae in these spreadsheets meet the
     requirements of the UBL Naming and Design Rules Version 3.0
     
Additional optional invocation parameters:

 - signal for single output:   single-output=yes/no (default 'yes')
   a single output has all of the worksheets in a single spreadsheet; when
   set to 'no' each worksheet is placed in an independent spreadsheet

 - massaging worksheet names:  shorten-model-name-uri={filename}
   this points to an XML document with regular expressions used to perform
   the act of shortening worksheet names; the example in the file (copied
   below) massageModelName-2.1.xml illustrates the shortening and lengthening
   of names to sidestep the bug in Google Docs (see *)
   - note that an example of a set of massaging directives is included:
     massageModelName-2.1.xml  - suitable to shorten UBL 2.1 names for Google

 - ordering worksheets:        common-first=yes/no (default 'no')
   set this to 'yes' to order at the start of the spreadsheet any worksheet
   with the case-insensitive string "common" in it 

 - identifying common library: common-name-regex=string (default 'Common')
   change this if the common library model name needs to be more uniquely
   specified
 
 - selecting worksheets:       model-name-regex=string (no default)
   set this to a regular expression matching model names (other than the
   common library) to be included in the result; otherwise all models
   will be included in the result

 - a particular subset of some models       subset-model-regex={string}

 - a particular subset of some constructs   subset-column-name={string-no-sp}
   - the genericode column short name (no white-space), typically compressed
     from the spreadsheet column name; a subset cardinality of 0 does not emit
     the BBIE or ASBIE in the result; when all BIEs of an ABIE have a
     cardinality of 0, the ABIE is not emitted
   - the output column 'Cardinality' is filled with the subset cardinality
     and the subset cardinality column (if present) is blanked; the original
     cardinality is not preserved unless a copied column name is specified

 - preserving original cardinality          old-cardinality-column-name={name}
   - when this column exists, copy into it the input cardinality value

 - lazy pruning of the model                subset-absent-is-zero={no(def)/yes}
   - this only applies to items that have a minimum cardinality of 0; to
     preserve the item the original cardinality must be included in the subset

 - only minimum subset of all models        subset-result={no(default)/yes}
   - this prunes away ABIEs that are never used by any model ASBIEs


Google Docs:

*  As of May 2015 Google Docs has a bug in that it imports worksheet
   names longer than 31 characters but truncates those names to 31 characters
   when exporting as an ODS file.  When this bug is repaired, no special
   massaging will be needed for worksheet names.


The specification for OASIS genericode is here:

    http://docs.oasis-open.org/codelist/genericode

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

Example input file of regular expressions to shorten or lengthen names:

<?xml version="1.0" encoding="UTF-8"?>
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

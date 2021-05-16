Crane-gc2obdndr.xsl - 20200413-1840z

This is a stylesheet to generate the validation artefacts (XSD schemas and
CVA assertions) described by a document described by a CCTS model expressed
using genericode. The version of NDR implemented by these stylesheets is
found at:

  http://docs.oasis-open.org/ubl/UBL-NDR/v3.0/UBL-NDR-v3.0.html

For best results the Crane-gcublndrcheck-obfuscated.xsl stylesheet should be
used to analyze the genericode file expressing the CCTS model.  Doing so will
highlight changes to make to prevent certain nonsensical results when
generating the artefacts.

Please see "CreatingExtensionsWithUBLNDR.html" for an illustration of using
these stylesheets

Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/training-gctk.htm

Portions copyright (C) - OASIS Open 2016. All Rights Reserved.
                       - http://www.oasis-open.org/who/intellectualproperty.php

This documentation and the URI resolution of the XSLT processor both presume
the use of the free Saxon9HE XSLT processor from http://saxon.sf.net ... if
that XSLT 2.0 processor is not being used, then the results may not be as
expected.

Typical invocation:

  java -jar saxon9he.jar {arguments}

Mandatory invocation arguments (URIs are relative to input genericode file):

 - stylesheet file:                         -xsl:Crane-gc2obdndr-obfuscated.xsl
 - input genericode file                    -s:{filename}
 - placebo output in target directory       -o:{dir}/junk.out
 - configuration detail file                config-uri={filename}

Optional invocation arguments:

 - only minimum subset of all models        subset-result={no(default)/yes}
   - this prunes away ABIEs that are never used by any model
 - a particular subset of some models       subset-model-regex={string}
 - a particular subset of some constructs   subset-column-name={string-no-sp}
   - the genericode column short name (no white-space), typically compressed
     from the spreadsheet column name
 - lazy pruning of the model                subset-absent-is-zero={no(def)/yes}
   - this only applies to items that have a minimum cardinality of 0; to
     preserve the item the original cardinality must be included in the subset
 - document the exclusion of items          subset-exclusions={yes(default)/no}
 - include elements for all types    subset-include-type-elements={yes(def)/no}
   - this allows one to ignore OBDNDR DCL04
 - include ignored types             subset-include-ignored-types={yes(def)/no}
   - this will suppress declarations that are not needed because not referenced
 - skip creation of QDT fragment            skip-qdt={no(default)/yes}
   - (deprecated) creating a QDT fragment according to the NDRs must be skipped
     if one has already been created with the desired qualifications that are
     differently declared than according to the NDRs
 - add extension point to every ABIE     extensions-for-abies={no(default)/yes}

Optional invocation arguments (URIs are relative to input genericode file):
(only used when creating extensions or additional documents)

 - config file for base vocabulary          base-config-uri={filename}
 - genericode file for base vocabulary      base-gc-uri={filename}

Necessary invocation argument when the common library has exactly one ABIE:

 - specify the model name          common-library-singleton-model-name={string}

Deprecated invocation argument to mimic archaic declarations:

 - mimic UBL 2.1 declarations              qdt-for-UBL-2.1-only={no(def)/yes}
   - this property should only be used when recreating schemas from before
     the release of the OASIS Business Document Naming and Design Rules
   - this is not to be used in the normal course of creating schemas

Example invocations:

To create the UBL 2.1 base vocabulary artefacts:

    java -jar ../saxon9he/saxon9he.jar -s:mod/UBL-Entities-2.1.gc
         -xsl:../Crane-gc2obdndr-obfuscated.xsl
         -o:junk.out
         config-uri=../config-ubl-2.1.xml 
         qdt-for-UBL-2.1-only=yes

To create the Signature Extension for UBL 2.1:

    java -jar ../saxon9he/saxon9he.jar -s:mod/UBL-Signature-Entities-2.1.gc
         -xsl:../Crane-gc2obdndr-obfuscated.xsl 
         -o:junk.out
         config-uri=../config-ubl-2.1-ext.xml
         base-gc-uri=UBL-Entities-2.1.gc
         base-config-uri=../config-ubl-2.1.xml 
         qdt-for-UBL-2.1-only=yes
         common-library-singleton-model-name=UBL-SignatureLibrary-2.1

To create a user extension for UBL 2.1:

    java -jar ../saxon9he.jar -s:mod/MyTimesheetExtension-Entities.gc
         -xsl:../Crane-gc2obdndr-obfuscated.xsl 
         -o:junk.out
         config-uri=../config-myext.xml
         base-gc-uri=UBL-Entities-2.1.gc
         base-config-uri=../config-ubl-2.1.xml
         qdt-for-UBL-2.1-only=yes

To create an additional document that uses the UBL 2.1 library:

    java -jar ../saxon9he/saxon9he.jar -s:mod/MyRARequestResponse-Entities.gc
         -xsl:../Crane-gc2obdndr-obfuscated.xsl 
         -o:junk.out
         config-uri=../config-rar.xml 
         base-gc-uri=UBL-Entities-2.1.gc 
         base-config-uri=../config-ubl-2.1.xml
         qdt-for-UBL-2.1-only=yes

Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.


Note: for your reference, the above is the "BSD-3-Clause license"; this text
      was obtained 2017-07-24 at https://opensource.org/licenses/BSD-3-Clause

THE COPYRIGHT HOLDERS MAKE NO REPRESENTATION ABOUT THE SUITABILITY OF THIS
CODE FOR ANY PURPOSE.


Configuration details file:

The configuration file has two major sections, the <ndr> section and the 
<schema> section.

The <ndr> section describes properties of the use of the naming and design 
rules, such as abbreviations, equivalences, expected BIEs and data types.  This
information is not used in the schema generation.  See the documentation for 
the NDR checking program for details.

The <schema> section describes all of the directories and files that are 
created or files that are needed by the files that are created as part of 
schema generation. The file types are indicated using the type= attribute. The
files that are created are:

    CVA - created context/value association file
        - there are as many of these entries as CVA files need to be created
        - each CVA file points to a skeleton CVA file in which <Context> 
          elements have ignored address= attributes that are each replaced 
          with a valid address= attribute of the union of all BBIE elements, 
          by name using the BBIE namespace prefix, that use the given 
          qualified data type as in these two examples:
          <Context values="checkMax" address="">
             <Annotation>
               <AppInfo>
                 <c:DataType>Max_ Numeric. Type</c:DataType>
               </AppInfo>
             </Annotation>
          </Context>
          <Context values="Chip-2.0" metadata="cctsV2.01-code" address="">
            <Annotation>
              <AppInfo>
                <c:DataType>Chip_ Code. Type</c:DataType>
              </AppInfo>
            </Annotation>
          </Context>
  SABIE - created supplemental library ABIE schema file
  SBBIE - created supplemental library BBIE schema file
  XABIE - created extension point ABIE schema file
  AABIE - created additional document ABIE schema file
  CABIE - created common library ABIE schema file
  CBBIE - created common library BBIE schema file
  DABIE - created document ABIE schema file
        - there are as many of these DABIE entries as document schemas need to 
          be created
        - when supplemental/extension/additional schema files are being 
          created, and only one set of such schema files can be created in any 
          given execution, the common schema files are not created
        - when the element name is <file>, a single file is created with the 
          given file name
        - when the element name is <files>, all document ABIE files are 
          created using the name and namespace as a substitution pattern
    DOC - documentation namespace (no actual file)
    EXT - referenced extension content file (optional)
        - the child of this entry is an XSD reference to the extension point 
          to be included in every document schema as the first child of the 
          document element 

A common comment can be defined for all files for which a specific comment is 
not provided. This comment is placed at the start of the file created. There 
are a number of substitution variables available for this comment:

    %% - a single percent sign
    %f - the output filename (with config path)
    %n - the output ABIE name (no config path)
    %t - the local time of file creation
    %z - the UTC (Zulu) time of file creation

The configuration file is organized by multiple directory parent elements that 
are used to calculate relative URI references for XSD import directives. There 
need not be any directory entries. The directory entry with the attribute 
runtime-name= triggers the recreation of the suite of contained files in the 
given alternative directory, but with XSD documentation constructs removed.

The configuration file used for UBL 2.1 is as follows:

<!DOCTYPE configuration
[
<!ENTITY versionDisplay "2.1 OS">
<!ENTITY versionDirectory   "os-UBL-2.1">
<!ENTITY versionDate        "04 November 2013">
]>
<configuration xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <!--
    This is the configuration of the base schema fragments for UBL 2.1
  -->
 <ndr>
  <abbreviations>
    <abbreviation short="CV2">Card Verification Value</abbreviation>
    <abbreviation short="ID">Identifier</abbreviation>
    <abbreviation short="URI">Uniform Resource Identifier</abbreviation>
    <abbreviation short="UNDG">United Nations Development Group</abbreviation>
    <abbreviation short="UBL">Universal Business Language</abbreviation>
    <abbreviation short="UUID">Universally Unique Identifier</abbreviation>
    <abbreviation short="XPath">XML Path Language</abbreviation>
  </abbreviations>
  <equivalences>
    <equivalence>
      <primary-noun>URI</primary-noun>
      <representation-term>Identifier</representation-term>
    </equivalence>
    <equivalence>
      <primary-noun>UUID</primary-noun>
      <representation-term>Identifier</representation-term>
    </equivalence>
  </equivalences>
  <expected-maindoc-BIEs>
    <property-term type="BBIE" cardinality="0..1" order="1"
                                  >UBL Version Identifier</property-term>
    <property-term type="BBIE" cardinality="0..1" order="2"
                                  >Customization Identifier</property-term>
    <property-term type="BBIE" cardinality="0..1" order="3"
                                  >Profile Identifier</property-term>
    <property-term type="BBIE" cardinality="0..1" order="4"
                                  >Profile Execution Identifier</property-term>
    <property-term type="ASBIE" cardinality="0..n"
                                  >Signature</property-term>
  </expected-maindoc-BIEs>
  <types>
    <type>Amount</type>
    <type>Binary Object</type>
    <type>Code</type>
    <type>Date Time</type>
    <type>Date</type>
    <type>Graphic</type>t
    <type>Identifier</type>
    <type>Indicator</type>
    <type>Measure</type>
    <type>Name</type>
    <type>Numeric</type>
    <type>Percent</type>
    <type>Picture</type>
    <type>Quantity</type>
    <type>Rate</type>
    <type>Sound</type>
    <type>Text</type>
    <type>Time</type>
    <type>Value</type>
    <type>Video</type>
  </types>
 </ndr>
 <schema version="2.1">
  <comment>
  Library:           OASIS Universal Business Language (UBL) &versionDisplay;
                     http://docs.oasis-open.org/ubl/&versionDirectory;/
  Release Date:      &versionDate;
  Module:            %f
  Generated on:      %z
  Copyright (c) OASIS Open 2016. All Rights Reserved.
</comment>
    <copyright position="end">
  OASIS takes no position regarding the validity or scope of any 
  intellectual property or other rights that might be claimed to pertain 
  to the implementation or use of the technology described in this 
  document or the extent to which any license under such rights 
  might or might not be available; neither does it represent that it has 
  made any effort to identify any such rights. Information on OASIS's 
  procedures with respect to rights in OASIS specifications can be 
  found at the OASIS website. Copies of claims of rights made 
  available for publication and any assurances of licenses to be made 
  available, or the result of an attempt made to obtain a general 
  license or permission for the use of such proprietary rights by 
  implementors or users of this specification, can be obtained from 
  the OASIS Executive Director.

  OASIS invites any interested party to bring to its attention any 
  copyrights, patents or patent applications, or other proprietary 
  rights which may cover technology that may be required to 
  implement this specification. Please address the information to the 
  OASIS Executive Director.
  
  This document and translations of it may be copied and furnished to 
  others, and derivative works that comment on or otherwise explain 
  it or assist in its implementation may be prepared, copied, 
  published and distributed, in whole or in part, without restriction of 
  any kind, provided that the above copyright notice and this 
  paragraph are included on all such copies and derivative works. 
  However, this document itself may not be modified in any way, 
  such as by removing the copyright notice or references to OASIS, 
  except as needed for the purpose of developing OASIS 
  specifications, in which case the procedures for copyrights defined 
  in the OASIS Intellectual Property Rights document must be 
  followed, or as required to translate it into languages other than 
  English. 

  The limited permissions granted above are perpetual and will not be 
  revoked by OASIS or its successors or assigns. 

  This document and the information contained herein is provided on 
  an "AS IS" basis and OASIS DISCLAIMS ALL WARRANTIES, 
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY 
  WARRANTY THAT THE USE OF THE INFORMATION HEREIN 
  WILL NOT INFRINGE ANY RIGHTS OR ANY IMPLIED 
  WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A 
  PARTICULAR PURPOSE.    
</copyright>
  <type-documentation>
    <ccts:Component xmlns:ccts="urn:un:unece:uncefact:documentation:2">
       <ccts:ComponentType>ComponentType</ccts:ComponentType>
       <ccts:DictionaryEntryName>DictionaryEntryName</ccts:DictionaryEntryName>
       <ccts:Version>Version</ccts:Version>
       <ccts:Definition>Definition</ccts:Definition>
       <ccts:Cardinality>Cardinality</ccts:Cardinality>
       <ccts:ObjectClassQualifier>ObjectClassQualifier</ccts:ObjectClassQualifier>
       <ccts:ObjectClass>ObjectClass</ccts:ObjectClass>
       <ccts:PropertyTermQualifier>PropertyTermQualifier</ccts:PropertyTermQualifier>
       <ccts:PropertyTerm>PropertyTerm</ccts:PropertyTerm>
       <ccts:AssociatedObjectClass>AssociatedObjectClass</ccts:AssociatedObjectClass>
       <ccts:RepresentationTerm>RepresentationTerm</ccts:RepresentationTerm>
       <ccts:DataTypeQualifier>DataTypeQualifier</ccts:DataTypeQualifier>
       <ccts:DataType>DataType</ccts:DataType>
       <ccts:AlternativeBusinessTerms>AlternativeBusinessTerms</ccts:AlternativeBusinessTerms>
       <ccts:Examples>Examples</ccts:Examples>
    </ccts:Component>
  </type-documentation>
  <dir name="cva">
    <file type="CVA" name="UBL-DefaultDTQ-2.1.cva"
          skeleton-uri="UBL-2.1-CVA-Skeleton.cva"/>
  </dir>
  <dir name="xsd" runtime-name="xsdrt">
    <dir name="common">
      <file type="CABIE" name="UBL-CommonAggregateComponents-2.1.xsd"
            prefix="cac"
namespace="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"/>
      <file type="CBBIE" name="UBL-CommonBasicComponents-2.1.xsd"
            prefix="cbc"
namespace="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"/>
      <file type="QDT" name="UBL-QualifiedDataTypes-2.1.xsd"
            prefix="qdt"
namespace="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2"/>
      <file type="UDT" name="UBL-UnqualifiedDataTypes-2.1.xsd"
            prefix="udt"
namespace="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2"/>
      <file type="EXT" name="UBL-CommonExtensionComponents-2.1.xsd"
            prefix="ext"
namespace="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">
        <elements>
         <xsd:element ref="ext:UBLExtensions" minOccurs="0" maxOccurs="1">
            <xsd:annotation>
               <xsd:documentation>A container for all extensions present in the document.</xsd:documentation>
            </xsd:annotation>
         </xsd:element>
        </elements>
      </file>
    </dir>
    <dir name="maindoc">
      <files type="DABIE" name="UBL-%n-2.1.xsd"
             namespace="urn:oasis:names:specification:ubl:schema:xsd:%n-2">
        <element-documentation>This element MUST be conveyed as the root element in any instance document based on this Schema expression</element-documentation>
      </files>
    </dir>
  </dir>
 </schema>
</configuration>

Note that all the DABIE filenames do not correlate to the DABIE name, then
the individual <file> declaration is needed, specifically naming the ABIE:

  <file type="DABIE" name="DocInvoice-1.0.xsd" abie="Invoice"
         namespace="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
    <element-documentation>This element MUST be conveyed as the root element in any instance document based on this Schema expression</element-documentation>
  </file>
  <file type="DABIE" name="DocResponse-1.0.xsd" abie="ApplicationResponse"
         namespace="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2">
    <element-documentation>This element MUST be conveyed as the root element in any instance document based on this Schema expression</element-documentation>
  </file>


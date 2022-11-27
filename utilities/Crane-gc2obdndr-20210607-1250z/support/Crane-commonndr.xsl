<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs gu xsd"
                version="2.0">

<xs:doc info="$Id: Crane-commonndr.xsl,v 1.35 2017/01/13 19:27:46 admin Exp $"
        filename="Crane-commonndr.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Common components to Crane's NDR stylesheets</xs:title>
  <para> 
    This stylesheet includes the common bits between Crane's stylesheets
    acting on genericode files of CCTS entities.
  </para>

  <section>
    <title>Copyright and disclaimer</title>
<programlisting>Copyright (C) - Crane Softwrights Ltd.
              - <ulink url="http://www.CraneSoftwrights.com/links/res-dev.htm">http://www.CraneSoftwrights.com/links/res-dev.htm</ulink>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Note: for your reference, the above is the "Modified BSD license", this text
      was obtained 2003-07-26 at <ulink
url="http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5">http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5</ulink>

THE AUTHOR MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS CODE FOR ANY
PURPOSE.</programlisting>
    </section>
</xs:doc>

<xsl:include href="Crane-utilndr.xsl"/>

<!--========================================================================-->
<xs:doc id="ingc">
  <xs:title>Input genericode file assumptions</xs:title>
  <para>
    The main input genericode file defines the business information entities
    of the schema fragments being generated.  When generating the common
    fragments, this is the common genericode file definition.  When generating
    an extension or additional document schema fragments, this is the
    genericode file definition for those fragments, and the common genericode
    file definition is supplied in an invocation argument.
  </para>
  <para>
    The column names of the input genericode file serialization of the UBL
    NDR spreadsheets are assumed to include at a minimum the following:
  </para>
  <itemizedlist>
    <listitem><literal>ModelName</literal> - the full model name</listitem>
    <listitem><literal>UBLName</literal> or <literal>ComponentName</literal> - the component name</listitem>
    <listitem><literal>ComponentType</literal> - ABIE, BBIE or ASBIE</listitem>
    <listitem><literal>Cardinality</literal> - 1, 0..1, 0..n or 1..n</listitem>
    <listitem><literal>ObjectClass</literal> - ISO/IEC 11179 classification part</listitem>
    <listitem><literal>AssociatedObjectClass</literal> - ISO/IEC 11179 classification part</listitem>
    <listitem><literal>DataType</literal> - CCTS V2.01 qualified data type</listitem>
  </itemizedlist>
  <para>
    The OASIS genericode specification is available at
    <ulink url="http://docs.oasis-open.org/codelist/genericode/">
      <literal>http://docs.oasis-open.org/codelist/genericode/</literal>
    </ulink>.
  </para>
  <para>
    An example serialization is found in the UBL 2.1 PRD2 distribution at
    <ulink url="http://docs.oasis-open.org/ubl/prd2-UBL-2.1/mod/UBL-Entities-2.1.gc">
      <literal>http://docs.oasis-open.org/ubl/prd2-UBL-2.1/mod/UBL-Entities-2.1.gc</literal>
    </ulink>.
  </para>
</xs:doc>

<!--========================================================================-->
<xs:doc>
  <xs:title>Invocation parameters</xs:title>
</xs:doc>

<xs:param name="base-config-uri" ignore-ns="yes">
  <para>
    This is the location of the common configuration file used to express
    where common components are found when creating extension or additional
    document schemas.  No schema fragments are created for the artefacts
    described in this file, only the artefacts in the 
    <literal>config-uri=</literal> file.
    It is assumed that the base output directory
    expressed by this configuration file is the same as that expressed by
    the main configuration file, such that common subdirectories can be
    matched.
  </para>
</xs:param>
<xsl:param name="base-config-uri" select="()" as="xsd:anyURI?"/>

<xs:param ignore-ns="yes">
  <para>
    The model details; when using Saxon use +details=filename
  </para>
</xs:param>
<xsl:param name="config" as="document-node()?" 
           select="if( not($config-uri) ) 
                   then ()
                   else doc(resolve-uri($config-uri,base-uri(/)))"/>

<xs:param ignore-ns="yes">
  <para id="invoke">
    The filename of the main configuration file as a URI.  A relative URI
    is resolved relative to the base URI of the input genericode file.
  </para>
  <para>
    The configuration file describes all of the directories and files that are
    created or files that are needed by the files that are created.
    The file types are indicated using the <literal>type=</literal> attribute.
    The files that are created are:
  </para>
  <itemizedlist>
    <listitem><literal>CVA</literal> - created context/value association file
     <itemizedlist>
       <listitem>
         there are as many of these entries as CVA files need to be created
       </listitem>
       <listitem>
         each CVA file points to a skeleton CVA file in which
         <literal>&lt;Context></literal> elements have annotations that
         signal the modification of the <literal>address=</literal> attribute
         with the union of all BBIE elements, by name, using the BBIE namespace
         prefix
       </listitem>
       <listitem>
         <programlisting><![CDATA[<Annotation>
  <AppInfo>
    <c:DataType>Measure. Type</c:DataType>
  </AppInfo>
</Annotation>]]></programlisting>
       </listitem>
               
     </itemizedlist>
    </listitem>
    <listitem><literal>SABIE</literal> - created supplemental library ABIE schema file</listitem>
    <listitem><literal>SBBIE</literal> - created supplemental library BBIE schema file</listitem>
    <listitem><literal>XABIE</literal> - created extension point ABIE schema file</listitem>
    <listitem><literal>AABIE</literal> - created additional document ABIE schema file</listitem>
    <listitem><literal>CABIE</literal> - created common library ABIE schema file</listitem>
    <listitem><literal>CBBIE</literal> - created common library BBIE schema file</listitem>
    <listitem><literal>DABIE</literal> - created document ABIE schema file
      <itemizedlist>
        <listitem>
          there are as many of these <literal>DABIE</literal> entries as
          document schemas need to be created
        </listitem>
        <listitem>
          when supplemental/extension/additional schema files are being created,
          and only one set of such schema files can be created in any given
          execution, the common schema files are not created
        </listitem>
        <listitem>
          when the element name is <literal>&lt;file></literal>, a single
          file is created with the given file name
        </listitem>
        <listitem>
          when the element name is <literal>&lt;files></literal>, all
          document ABIE files are created using the name and namespace as
          a substitution pattern where "<literal>%n</literal>" is replaced
          with the name of the document ABIE (not the model name)
        </listitem>
        <listitem>
          note that the <literal>&lt;files></literal> directive will not
          create a file for a document ABIE for which there is a corresponding
          <literal>&lt;file></literal> directive
        </listitem>
      </itemizedlist>
    </listitem>
  </itemizedlist>
  <para>The files that are referenced are:</para>
  <itemizedlist>
    <listitem><literal>QDT</literal> - referenced qualified data types file</listitem>
    <listitem><literal>UDT</literal> - referenced unqualified data types file</listitem>
    <listitem><literal>DOC</literal> - documentation namespace (no actual file)</listitem>
    <listitem><literal>EXT</literal> - referenced extension content file (optional)
      <itemizedlist>
        <listitem>
          the child of this entry is an XSD reference to the extension point
          to be included in every document schema as the first child of the
          document element
        </listitem>
      </itemizedlist>
    </listitem>
  </itemizedlist>
  <para>
    The configuration file is organized by multiple directory
    parent elements that are used to calculate relative URI references for
    XSD import directives.  There need not be any directory entries.
    The directory entry with the attribute <literal>runtime-name=</literal>
    triggers the recreation of the suite of contained files in the given
    alternative directory, but with XSD documentation constructs removed.
  </para>
  <para>
    All allowed abbreviations must be itemized as these are the portions of
    element names that do not satisfy the UpperCamelCase convention.
  </para>
  <para>
    All allowed unqualified data types must be itemized to ensure nothing
    unsupported is asked for.
  </para>
  <para>
    A common comment can be defined for all files for which a specific comment
    is not provided.  This comment is placed at the start of the file created.
    There are a number of substitution variables available for this comment:
  </para>
  <itemizedlist>
    <listitem><literal>%%</literal> - a single percent sign</listitem>
    <listitem><literal>%f</literal> - the output filename (with config path)</listitem>
    <listitem><literal>%n</literal> - the output ABIE name (no config path)</listitem>
    <listitem><literal>%t</literal> - the local time of file creation</listitem>
    <listitem><literal>%z</literal> - the UTC (Zulu) time of file creation</listitem>
  </itemizedlist>
  <para>
    The example for a test file similar to the UBL project (but modified to 
    illustrate distinctions between
    <literal>&lt;files></literal> and <literal>&lt;file></literal> for
    documents) is as follows:
  </para>
<programlisting><![CDATA[<!DOCTYPE configuration
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
  Copyright (c) OASIS Open 2013. All Rights Reserved.
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
]]></programlisting>
  <para>
    The example for a user-defined extension for UBL 2.1 is as follows for
    the committee's signature extension (note how there is no duplication
    needed for the copyright or other metadata to be reused from UBL 2.1):
  </para>
<programlisting><![CDATA[<configuration xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               version="2.1">
    <dir name="xsd" runtime-name="xsdrt">
      <dir name="common">
        <file type="XABIE" name="UBL-CommonSignatureComponents-2.1.xsd"
              abie="UBLDocumentSignatures"
namespace="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2"/>
        <file type="SABIE" name="UBL-SignatureAggregateComponents-2.1.xsd"
              prefix="sac"
namespace="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2">
          <imports>

   <!-- ===== Incorporate W3C signature specification-->
   <xsd:import namespace="http://www.w3.org/2000/09/xmldsig#" 
               schemaLocation="UBL-xmldsig-core-schema-2.1.xsd"/>

   <!-- ===== Incorporate ETSI signature specifications-->
   <xsd:import namespace="http://uri.etsi.org/01903/v1.3.2#" 
               schemaLocation="UBL-XAdESv132-2.1.xsd"/>
   <xsd:import namespace="http://uri.etsi.org/01903/v1.4.1#"
               schemaLocation="UBL-XAdESv141-2.1.xsd"/>
          </imports>
          <elements xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                    abie="SignatureInformation">
         <xsd:element ref="ds:Signature" minOccurs="0" maxOccurs="1">
           <xsd:annotation>
             <xsd:documentation>This is a single digital signature as defined by the W3C specification.</xsd:documentation>
           </xsd:annotation>
         </xsd:element>
          </elements>
        </file>
        <file type="SBBIE" name="UBL-SignatureBasicComponents-2.1.xsd"
              prefix="sbc"
namespace="urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2"/>
      </dir>
    </dir>
  </configuration>]]></programlisting>
  <para>
    The example for a user-defined additional document for UBL 2.1 is as
    follows for a fictional pair of Return Authorization documents:
  </para>
<programlisting><![CDATA[<configuration xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               version="2.1">
  <!--
    This is the configuration of an example of additional documents for UBL 2.1
  -->
    <comment>
  Library:           My library of Return Authorization documents
  Module:            %f
  Generated on:      %z
</comment>
    <copyright position="end">
  Test copyright
</copyright>
    <dir name="cva">
      <file type="CVA" name="MyRA-Qualifications.cva"
            skeleton-uri="UBL-2.1-CVA-Skeleton.cva"/>
    </dir>
    <dir name="xsd" runtime-name="xsdrt">
      <dir name="mydoc">
        <file type="SABIE" name="MyRAAggregateComponents.xsd" prefix="raa"
      namespace="urn:X-MyCompany:xsd:MyRARequestResponse:AggregateComponents"/>
        <file type="SBBIE" name="MyRABasicComponents.xsd" prefix="rab" 
          namespace="urn:X-MyCompany:xsd:MyRARequestResponse:BasicComponents"/>
        <files type="AABIE" name="My%n.xsd"
               namespace="urn:X-MyCompany:xsd:My%n"/>
      </dir>
    </dir>
  </configuration>]]></programlisting>

</xs:param>
<xsl:param name="config-uri" as="xsd:string?"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Global variables and lookup tables</xs:title>
</xs:doc>

<xs:variable>
  <para>
    This is the access to the "main" configuration file as a node tree.
  </para>
</xs:variable>
<xsl:variable name="gu:configMain" as="document-node()?" select="$config"/>

<xs:variable>
  <para>
    This is the access to the file specifications from the 
  </para>
</xs:variable>
<xsl:variable name="gu:outputFiles" as="element()*">
 <xsl:variable name="gu:files"
               select="$gu:configMain/*/schema//(file | files)"/>
 <xsl:if test="$gu:configMain/*/schema">
  <xsl:variable name="gu:message">
    <xsl:if
      test="count( ( $gu:files[@type='DABIE'][1], $gu:files[@type='XABIE'][1],
                     $gu:files[@type='AABIE'][1] ) ) != 1 or
            $gu:files[not(@type=('DABIE','CABIE','CBBIE','QDT','UDT','EXT',
                                 'XABIE','AABIE','SABIE','SBBIE','CVA'))]">
      <xsl:text>Files can be created only for one type of output, </xsl:text>
      <xsl:text>either UBL documents (DABIE), extensions (XABIE) or </xsl:text>
      <xsl:text>additional non-UBL documents (AABIE).&#xa;</xsl:text>
    </xsl:if>
    <xsl:if test="$gu:files[@type=('SABIE','SBBIE')] and
                  not($gu:files[@type=('XABIE','AABIE')])">
      <xsl:text>Supplementary common library schemas can only be </xsl:text>
      <xsl:text>created for extensions or additional documents.&#xa;</xsl:text>
    </xsl:if>
    <xsl:if test="$gu:files[@type=('CABIE','CBBIE')] and
                  $gu:files[@type=('XABIE','AABIE')]">
      <xsl:text>Common library schemas can only be created when not </xsl:text>
      <xsl:text>creating extensions or additional documents. </xsl:text>
      <xsl:text>Reference common library schemas used in a common </xsl:text>
      <xsl:text>library configuration.&#xa;</xsl:text>
    </xsl:if>
    <xsl:if test="count($gu:files[@type='CVA'])>1">
      <xsl:text>Can create only a single CVA file at a time.&#xa;</xsl:text>
    </xsl:if>
    <xsl:for-each select="$gu:files[self::files and @prefix]">
      <xsl:text>A prefix cannot be specified when creating multiple </xsl:text>
      <xsl:text>files.</xsl:text>
      <xsl:value-of select="gu:reportElement(.)"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:if test="not($gu:files)">
   <xsl:text>Some files must be specified for schema generation&#xa;</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:if test="normalize-space($gu:message)">
    <xsl:message terminate="yes" select="$gu:message"/>
  </xsl:if>  
 <xsl:sequence select="$gu:files"/>  
 </xsl:if>
</xsl:variable>

<xs:variable>
  <para>
    This is the access to the "other" configuration file as a node tree.
  </para>
</xs:variable>
<xsl:variable name="gu:configOther" as="document-node()?"
              select="if( $base-config-uri ) 
                      then for $u in resolve-uri( $base-config-uri,
                                                  document-uri(/) ) return
                           if( doc-available($u) ) then doc($u) 
                           else error( (),concat(
                           'Unable to open resolved base configuration file: ',
                           $u ) )
                      else ()"/>

<xs:variable>
  <para>
    This is the access to the combination configuration file as a node tree.
  </para>
</xs:variable>
<xsl:variable name="gu:config" as="document-node()">
  <xsl:document>
    <combination>
      <xsl:for-each select="$gu:configMain,$gu:configOther">
        <xsl:for-each select="*">
          <!--copy the document element-->
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--this ensures relative URIs are relative to original
                configuration file and not this temporary tree-->
            <xsl:attribute name="xml:base" select="base-uri(.)"/>
            <!--copy the rest of the tree-->
            <xsl:copy-of select="node()"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:for-each>
    </combination>
  </xsl:document>
</xsl:variable>

<xs:key>
  <para>
    Index the files in the directory structure of the configuration file.
  </para>
</xs:key>
<xsl:key name="gu:files" match="file|files" use="@type"/>

<xs:variable>
 <para>
   Determine the library model from all models in the common genericode file
   for an extension/addition.
 </para>
</xs:variable>
<xsl:variable name="gu:otherCommonLibraryModel" as="xsd:string?"
              select="gu:lookupCommonLibraryModel($gu:gcOther)"/>

<xs:variable>
  <para>
    Summary set of all document ABIEs.
  </para>
</xs:variable>
<xsl:variable name="gu:allDocumentABIEs" as="element(Row)*">
  <xsl:variable name="gu:specifiedDocumentABIEnames"
                select="(key('gu:files','XABIE',$gu:config),
                         key('gu:files','AABIE',$gu:config))/@abie"/>
  <xsl:choose>
    <xsl:when test="$gu:specifiedDocumentABIEnames">
      <xsl:sequence select="$gu:specifiedDocumentABIEnames/
                         key('gu:abie-by-name',.,$gu:gc)
                   [if( not( $subset-model-regex ) ) then true()
                    else matches(gu:col(.,'ModelName'),$subset-model-regex)]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each-group select="/*/SimpleCodeList/
                         Row[gu:col(.,'ModelName')!=$gu:thisCommonLibraryModel]
                            [gu:col(.,'ComponentType')='ABIE']
                            [ if( not( $subset-model-regex ) ) then true()
                 else matches(gu:col(.,'ModelName'),$subset-model-regex)]"
                          group-by="gu:col(.,$gu:names)">
        <xsl:sequence select="."/>
      </xsl:for-each-group>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
              
<xs:variable>
  <para>
    Summary list of all document ABIE names.
  </para>
</xs:variable>
<xsl:variable name="gu:allDocumentABIEnames" as="element(SimpleValue)*"
              select="$gu:allDocumentABIEs/gu:col(.,$gu:names)"/>
              
<xs:variable>
  <para>
    Summary set of all document ABIEs.
  </para>
</xs:variable>
<xsl:variable name="gu:subsetDocumentABIEs" as="element(Row)*"
              select="$gu:allDocumentABIEs
                 [ if( not( $subset-model-regex ) ) then true()
                   else matches(gu:col(.,'ModelName'),$subset-model-regex) ]"/>
              
<xs:variable>
  <para>
    Summary list of document model names is found by the name of every ABIE
    that is not in the common library.
  </para>
</xs:variable>
<xsl:variable name="gu:subsetDocumentABIEmodelNames" as="element(SimpleValue)*"
              select="$gu:subsetDocumentABIEs/gu:col(.,'ModelName')"/>
              
<xs:variable>
  <para>
    Summary list of documents classes is found by the name of every ABIE
    that is not in the common library. 
  </para>
</xs:variable>
<xsl:variable name="gu:subsetDocumentABIEclasses" as="element(SimpleValue)*"
              select="$gu:subsetDocumentABIEs/gu:col(.,'ObjectClass')"/>
              
<xs:variable>
  <para>
    Handy prefix definition so as not to keep looking it up.
  </para>
</xs:variable>
<xsl:variable name="gu:cbbiePrefixColon" as="xsd:string"
              select="concat(key('gu:files','CBBIE',$gu:config)/@prefix,':')"/>
              
<xs:variable>
  <para>
    Handy prefix definition so as not to keep looking it up.
  </para>
</xs:variable>
<xsl:variable name="gu:cabiePrefixColon" as="xsd:string"
              select="concat(key('gu:files','CABIE',$gu:config)/@prefix,':')"/>

<xs:variable>
  <para>
    Handy prefix definition so as not to keep looking it up.
  </para>
</xs:variable>
<xsl:variable name="gu:sbbiePrefixColon" as="xsd:string"
              select="concat(key('gu:files','SBBIE',$gu:config)/@prefix,':')"/>
              
<xs:variable>
  <para>
    Handy prefix definition so as not to keep looking it up.
  </para>
</xs:variable>
<xsl:variable name="gu:sabiePrefixColon" as="xsd:string"
              select="concat(key('gu:files','SABIE',$gu:config)/@prefix,':')"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Utility templates and functions</xs:title>
</xs:doc>
  
<xs:function>
  <para>Substitute key replacement strings in a given string</para>
  <xs:param name="name">
    <para>That value to use to substitute for the ABIE name value</para>
  </xs:param>
  <xs:param name="string">
    <para>The string in which are found the substitution requests.</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:substituteFields" as="xsd:string">
  <xsl:param name="name" as="xsd:string"/>
  <xsl:param name="string" as="xsd:string"/>
  <xsl:value-of>
    <xsl:analyze-string select="$string" regex="%(.)">
      <xsl:matching-substring><xsl:value-of select="
        if(regex-group(1)='%') then '%' else
        if(regex-group(1)='f') then $name else
        if(regex-group(1)='n') then replace($name,'.*/','') else
        if(regex-group(1)='t') then format-dateTime( current-dateTime(), 
                                   '[Y0001]-[M01]-[D01] [H01]:[m01][Z]' ) else
        if(regex-group(1)='z') then format-dateTime( 
   adjust-dateTime-to-timezone(current-dateTime(),xsd:dayTimeDuration('PT0H')),
                                '[Y0001]-[M01]-[D01] [H01]:[m01]z' ) else
         ."/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:value-of>
</xsl:function>

<xs:function>
  <para>Report a start tag for error messages.</para>
  <xs:param name="this">
    <para>The element being reported</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:reportElement" as="xsd:string">
  <xsl:param name="this" as="element()"/>
  <xsl:value-of>
    <xsl:for-each select="$this/ancestor-or-self::*">
      <xsl:text/>/<xsl:value-of select="name(.)"/>
      <xsl:if test="parent::*">[<xsl:number/>]</xsl:if>
    </xsl:for-each>
    <xsl:text>: </xsl:text>
    <xsl:for-each select="$this">
      <xsl:text/>&lt;<xsl:value-of select="name(.)"/>
      <xsl:for-each select="@*">
        <xsl:value-of select="concat(' ',name(.),'=&#34;',.,'&#34;')"/>
      </xsl:for-each>
      <xsl:text>></xsl:text>
    </xsl:for-each>
  </xsl:value-of>
</xsl:function>

</xsl:stylesheet>

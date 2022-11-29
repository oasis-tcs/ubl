<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<!--
    Convert a UBL genericode CCTS model into a Schematron schema to
    check the Additional Document Constraints possible using XSLT

    The main input file is the genericode of the CCTS model
-->
  
<!--
    Use this parameter to identify the common library model name only when the
    common library consists of only a single ABIE.  If the common library
    contains more than one ABIE then it will be automatically detected. Note
    that there cannot be more than one common library, that is, a model with
    more than one ABIE.
-->
<xsl:param name="common-library-singleton-model-name"
           as="xsd:string?" select="()"/>

<!--
    The namespace of the library basics.
-->
<xsl:param name="bbie-ns" as="xsd:string" 
           select=
"'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'"/>

<!--
    The namespace of the extension metadata.
-->
<xsl:param name="ext-ns" as="xsd:string" 
           select=
"'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2'"/>

<!--
    The prefix of the library basics namespace.
-->
<xsl:param name="bbie-prefix" as="xsd:string" select="'cbc'"/>

<!--
    The prefix of the extension metadata namespace.
-->
<xsl:param name="ext-prefix" as="xsd:string" select="'ext'"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Globals</xs:title>
</xs:doc>

<xs:output>
  <para>Easier to read output</para>
</xs:output>
<xsl:output indent="yes"/>

<xs:variable>
  <para>Keep track of name columns</para>
</xs:variable>
<xsl:variable name="c:names" as="xsd:string+"
              select="('UBLName','ComponentName')"/>

<xs:function>
  <para>Obtain a piece of information from a genericode column</para>
  <xs:param name="c:row">
    <para>From this row.</para>
  </xs:param>
  <xs:param name="c:col">
    <para>At this column name.</para>
  </xs:param>
</xs:function>
<xsl:function name="c:col" as="element(SimpleValue)?">
  <xsl:param name="c:row" as="element(Row)"/>
  <xsl:param name="c:col" as="xsd:string+"/>
  <xsl:sequence select="$c:row/Value[@ColumnRef=$c:col]/SimpleValue"/>
</xsl:function>

<xs:template>
  <para>
    Synthesize the required Schematron schema
  </para>
</xs:template>
<xsl:template match="/">
    <schema xmlns="http://purl.oclc.org/dsdl/schematron"
            queryBinding="xslt2">
      <ns prefix="{$bbie-prefix}" uri="{$bbie-ns}"/>
      <ns prefix="{$ext-prefix}" uri="{$ext-ns}"/>
      
      <xsl:comment>
A set of Schematron rules against which UBL 2.4 document constraints are
tested in the scope of a second pass validation after schema validation
has been performed.

Required namespace declarations as indicated in this set of rules:

&lt;ns prefix="ext" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"/>
&lt;ns prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"/>

The following is a summary of the additional document constraints:

[IND1] All UBL instance documents SHALL validate to a corresponding schema.

 - this is tested in the first pass by schema validation, not in the second
   pass with Schematron validation

[IND2] All UBL instance documents SHALL identify their character encoding
       within the XML declaration.

 - this cannot be tested using Schematron as the information is not part of
   XDM (the XML Data Model)

[IND3] In conformance with ISO IEC ITU UN/CEFACT eBusiness Memorandum of
       Understanding Management Group (MOUMG) Resolution 01/08 (MOU/MG01n83)
       as agreed to by OASIS, all UBL XML SHOULD be expressed using UTF-8.

 - this cannot be tested using Schematron as the information is not part of
   XDM (the XML Data Model)

[IND4] (This archaic test no longer exists)

[IND5] UBL-conforming instance documents SHALL NOT contain an element devoid of content or containing null values.

 - implemented below
 - per the documentation, this does not apply to the arbitrary content of
   an extension

[IND6] The absence of a construct or data in a UBL instance document SHALL NOT carry meaning.

 - this cannot be tested using Schematron as it is an application constraint
   on the interpretation of the document

[IND7] Where two or more sibling “Text. Type” elements of the same name exist in a document, no two can have the same “languageID” attribute value.

 - implemented below

[IND8] Where two or more sibling “Text. Type” elements of the same name exist in a document, no two can omit the “languageID” attribute.

 - implemented below

[IND9] UBL-conforming instance documents SHALL NOT contain an attribute devoid of content or containing null values.

 - implemented below
 - per the documentation, this does not apply to the arbitrary content of
   an extension
      </xsl:comment>
      <pattern>
         <rule context="ext:*">
           <xsl:comment select="'no constraints for extension elements'"/>
           <report test="false()"/>
         </rule>
         <rule context="ext:*//*">
           <xsl:comment select="'no constraints in extension elements'"/>
           <report test="false()"/>
         </rule>
        <rule context="*[not(*)]">
          <assert test="normalize-space(.)"
            >UBL rule [IND5] states that elements cannot be void of content.
</assert>
        </rule>
      </pattern>
      
      <pattern>
        <rule context="@*[normalize-space(.)='']">
          <assert test="normalize-space(.)"
            >UBL rule [IND5] infers that attributes cannot be void of content.
</assert>
        </rule>
      </pattern>

      <pattern>
        <rule context="*[@languageID]">
          <!--check using string() to equate absent with empty-->
          <assert test="not(../*[name(.)=name(current())]
                          [generate-id(.)!=generate-id(current())]
                          [string(@languageID)=string(current()/@languageID)])"
>UBL rule [IND7] states that two sibling elements of the same name cannot have the same languageID= attribute value
</assert>
        </rule>
        <xsl:variable name="c:textBBIEnames" as="xsd:string*">
        <xsl:for-each-group select="/*/SimpleCodeList/Row"
                            group-by="c:col(.,'ModelName')">
          <xsl:variable name="c:modelName" select="c:col(.,'ModelName')"/>
      <xsl:if test="count(current-group()[c:col(.,'ComponentType')='ABIE'])>1
                    or $c:modelName = $common-library-singleton-model-name">
        <!--then this is the common library-->
        <xsl:for-each-group group-by="c:col(.,$c:names)"
                     select="current-group()[c:col(.,'ComponentType')='BBIE']">
          <xsl:sort select="c:col(.,$c:names)"/>
          <!--look at all of the BBIEs with the same name-->
          <xsl:variable name="c:bbieTypes" as="xsd:string*"
      select="distinct-values(current-group()/c:col(.,'RepresentationTerm'))"/>
          <xsl:if test="some $c:type in $c:bbieTypes 
                        satisfies $c:type='Text'">
            <xsl:if test="count($c:bbieTypes)>1">
              <xsl:message terminate="yes">
          <xsl:text>The code needs to be upgraded to accommodate </xsl:text>
          <xsl:text>non-homogenous types for the element named: </xsl:text>
                <xsl:value-of select="c:col(.,$c:names)"/>
              </xsl:message>
            </xsl:if>
            <xsl:value-of select="c:col(.,$c:names)"/>
          </xsl:if>
        </xsl:for-each-group>
      </xsl:if>
        </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="count($c:textBBIEnames)">
          <rule>
            <xsl:attribute select="for $c:name in $c:textBBIEnames
                                   return concat($bbie-prefix,':',$c:name)"
                           separator=" | " name="context"/>
            <assert test="not(../*[name(.)=name(current())]
                                  [generate-id(.)!=generate-id(current())]
                                  [not(@languageID)])"
>UBL rule [IND8] states that two sibling elements of the same name cannot both omit the languageID= attribute
</assert>
          </rule>
        </xsl:if>
      </pattern>
    </schema>
</xsl:template>

</xsl:stylesheet>

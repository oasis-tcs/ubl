<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: checkgc4obdndr-schema.xsl,v 1.2 2016/04/28 20:33:08 admin Exp $"
    filename="checkgc4obdndr-schema.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Report schema rule violations</xs:title>
  <para>
    This reports the problems found in the schemas
  </para>
</xs:doc>

<!--========================================================================-->
<xs:doc>
  <xs:title>XSD access</xs:title>
</xs:doc>

<xs:param ignore-ns="yes">
  <para>The root directory of the created XSD maindoc files</para>
</xs:param>
<xsl:param name="xsd-maindoc-dir-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The root directory of the created XSD common files</para>
</xs:param>
<xsl:param name="xsd-common-dir-uri" as="xsd:string?"/>

<xs:variable>
  <para>Indication of checking XSD rules</para>
</xs:variable>
<xsl:variable name="gu:xsd-check" as="xsd:boolean"
        select="exists($xsd-maindoc-dir-uri) and exists($xsd-common-dir-uri)
                and false()"/>

<xs:variable>
  <para>Collection of XSD main deocument schemas</para>
</xs:variable>
<xsl:variable name="gu:xsd-maindoc-fragments" as="document-node()*"
              select="if( empty( $xsd-maindoc-dir-uri) ) then () else 
   collection(concat(resolve-uri($xsd-maindoc-dir-uri,base-uri(/)),
                     '/?select=*.xsd;on-error=ignore'))"/>

<xs:variable>
  <para>Collection of XSD maindoc element declarations</para>
</xs:variable>
<xsl:variable name="gu:xsd-maindoc-elements" as="element(xsd:element)*"
              select="$gu:xsd-maindoc-fragments/xsd:schema/xsd:element"/>
  
<xs:variable>
  <para>Collection of XSD maindoc type declarations</para>
</xs:variable>
<xsl:variable name="gu:xsd-maindoc-types" as="element(xsd:complexType)*"
              select="$gu:xsd-maindoc-fragments/xsd:schema/xsd:complexType
                      [@name=../xsd:element/@type]"/>

<xs:variable>
  <para>Collection of XSD common schemas</para>
</xs:variable>
<xsl:variable name="gu:xsd-common-fragments" as="document-node()*"
              select="if( empty( $xsd-common-dir-uri) ) then () else 
   collection(concat(resolve-uri($xsd-common-dir-uri,base-uri(/)),
                     '/?select=*.xsd;on-error=ignore'))"/>

<xs:variable>
  <para>Collection of XSD common element declarations</para>
</xs:variable>
<xsl:variable name="gu:xsd-common-elements" as="element(xsd:element)*"
              select="$gu:xsd-common-fragments/xsd:schema/xsd:element"/>
  
<xs:variable>
  <para>Collection of XSD common type declarations</para>
</xs:variable>
<xsl:variable name="gu:xsd-common-types" as="element(xsd:complexType)*"
              select="$gu:xsd-common-fragments/xsd:schema/xsd:complexType
                      [@name=../xsd:element/@type]"/>

<xs:variable>
  <para>
    The collection of all element and type declarations in a single variable.
  </para>
</xs:variable>
<xsl:variable name="gu:allXSD" as="element()*">
  <xsl:for-each select="$gu:xsd-maindoc-elements">
    <xsl:sequence select="."/>
  </xsl:for-each>
</xsl:variable>

<!--========================================================================-->
<xs:doc>
  <xs:title>XSD access</xs:title>
</xs:doc>

<xs:variable>
  <para>One schema fragment for each Document ABIE</para>
</xs:variable>
<xsl:variable name="gu:FRG01-maindoc-fragments" as="element(ndrbad)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs">
    <xsl:variable name="gu:nameDABIE" select="gu:col(.,$gu:names)"/>
    <xsl:variable name="gu:declDABIE"
                  select="$gu:xsd-maindoc-elements[@name=$gu:nameDABIE]"/>
    <xsl:variable name="gu:countDABIE"
                  select="count($gu:declDABIE)"/>
    <xsl:choose>
      <xsl:when test="$gu:countDABIE > 1">
        <ndrbad gu:name="{$gu:nameDABIE}" gu:tooMany="{$gu:countDABIE}"
                gu:den="{gu:col(.,'DictionaryEntryName')}"
            gu:uris="{string-join($gu:declDABIE/
                              replace(document-uri(root(.)),'.*/',''),', ')}"/>
      </xsl:when>
      <xsl:when test="$gu:countDABIE = 0">
        <ndrbad gu:name="{$gu:nameDABIE}" gu:tooFew=""
                gu:den="{gu:col(.,'DictionaryEntryName')}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>
  
<xs:variable>
  <para>One element declaration for each DABIE fragment</para>
</xs:variable>
<xsl:variable name="gu:FRG02-fragment-declarations" as="element(ndrbad)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs">
    <xsl:variable name="gu:nameDABIE" select="gu:col(.,$gu:names)"/>
    <xsl:variable name="gu:denDABIE" select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:declDABIE"
                  select="$gu:xsd-maindoc-elements[@name=$gu:nameDABIE]"/>
    <xsl:for-each-group select="$gu:declDABIE"
                        group-by="generate-id(root(.))">
      <xsl:for-each select="current-group()">
        <xsl:variable name="gu:elemDecl"
                      select="root(.)//xsd:element[@name]"/>
        <xsl:if test="count($gu:elemDecl) > 1">
          <ndrbad gu:name="{$gu:nameDABIE}"
                  gu:den="{$gu:denDABIE}"
                  gu:names="{string-join($gu:elemDecl/@name,', ')}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:for-each>
</xsl:variable>
  
<xs:variable>
  <para>One element declaration for each DABIE fragment</para>
</xs:variable>
<xsl:variable name="gu:FRG03-fragment-type-declarations" as="element(ndrbad)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs">
    <xsl:variable name="gu:nameDABIE" select="gu:col(.,$gu:names)"/>
    <xsl:variable name="gu:denDABIE" select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:declDABIE"
                  select="$gu:xsd-maindoc-elements[@name=$gu:nameDABIE]"/>
    <xsl:for-each-group select="$gu:declDABIE"
                        group-by="generate-id(root(.))">
      <xsl:for-each select="current-group()">
        <xsl:variable name="gu:elemDecl" select="root(.)//xsd:element"/>
        <xsl:variable name="gu:typeDecl"
                      select="root(.)//xsd:complexType[@name]"/>
        <xsl:if test="count($gu:typeDecl) > 1">
          <ndrbad gu:name="{$gu:nameDABIE}"
                  gu:den="{$gu:denDABIE}"
                  gu:names="{string-join($gu:typeDecl/@name,', ')}"/>
        </xsl:if>
        <!--this lazily ignores namespace prefixes and shouldn't ignore them
            to be complete-->
        <xsl:if test="not($gu:elemDecl/@type = $gu:typeDecl/@name)">
          <ndrbad gu:name="{$gu:nameDABIE}"
                  gu:den="{$gu:denDABIE}"
                  gu:type="{$gu:elemDecl/@type}"
                  gu:found="{$gu:typeDecl/@name}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:for-each>
</xsl:variable>
  
<xs:variable>
  <para>One library for all library ABIEs</para>
</xs:variable>
<xsl:variable name="gu:FRG04-library-ABIE-fragment" as="element(ndrbad)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs">
    <xsl:variable name="gu:nameDABIE" select="gu:col(.,$gu:names)"/>
    <xsl:variable name="gu:denDABIE" select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:declDABIE"
                  select="$gu:xsd-maindoc-elements[@name=$gu:nameDABIE]"/>
    <xsl:for-each-group select="$gu:declDABIE"
                        group-by="generate-id(root(.))">
      <xsl:for-each select="current-group()">
        <xsl:variable name="gu:elemDecl" select="root(.)//xsd:element"/>
        <xsl:variable name="gu:typeDecl"
                      select="root(.)//xsd:complexType[@name]"/>
        <xsl:if test="count($gu:typeDecl) > 1">
          <ndrbad gu:name="{$gu:nameDABIE}"
                  gu:den="{$gu:denDABIE}"
                  gu:names="{string-join($gu:typeDecl/@name,', ')}"/>
        </xsl:if>



        <xsl:variable name="gu:foundURIs" select="()"/>
        <!--this lazily ignores namespace prefixes and shouldn't ignore them
            to be complete-->
        <xsl:if test="count($gu:foundURIs) > 1">
          <ndrbad gu:name="{$gu:nameDABIE}"
                  gu:den="{$gu:denDABIE}"
                  gu:count="{count($gu:foundURIs)}"
                  gu:found="{string-join($gu:foundURIs,', ')}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each-group>
  </xsl:for-each>
</xsl:variable>
  
<!--========================================================================-->
<xs:doc>
  <xs:title>XSD reporting</xs:title>
</xs:doc>

<xs:template>
  <para>Check XSD files against NDR rules</para>
</xs:template>
<xsl:template name="gu:reportAllSchemaProblems">

  <h4>Schema-related NDRs</h4>
<pre>

  <xsl:copy-of select="gu:titleOBDNDR(
    'FRG01 - Document ABIE schema fragment errors',
    $gu:FRG01-maindoc-fragments,
    'There shall be one schema fragment created for each Document ABIE.'
    )"/>
  <xsl:for-each select="$gu:FRG01-maindoc-fragments">
    <xsl:copy-of select="gu:issue(.,concat(@gu:name,': ',if(@gu:tooFew)
     then 'missing' else concat( 'found ',@gu:tooMany,' (',@gu:uris,')') ) )"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR(
    'FRG02 - Document ABIE schema declaration errors',
    $gu:FRG02-fragment-declarations,
    'Each Document ABIE schema fragment shall include a single element
     declaration, that being for the Document ABIE.'
    )"/>
  <xsl:for-each select="$gu:FRG02-fragment-declarations">
    <xsl:copy-of select="gu:issue(.,concat(@gu:name,': ',@gu:names ) )"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR(
    'FRG03 - Document ABIE type declaration errors',
    $gu:FRG03-fragment-type-declarations,
    'Each Document ABIE schema fragment shall include a single type
     declaration, that being for the content of the Document ABIE.'
    )"/>
  <xsl:for-each select="$gu:FRG03-fragment-type-declarations">
    <xsl:copy-of select="gu:issue(.,concat(@gu:name,': ',
                   if( @gu:names ) then concat( 'too many (',@gu:names,')' )
                   else concat( 'mismatch (',@gu:type,' ',@gu:found,')' )) )"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR(
    'FRG04 - Library ABIE schema fragment',
    $gu:FRG04-library-ABIE-fragment,
    'There shall be one common schema fragment created to contain
    all ASBIEs (that is, from every Document ABIE and every
    Library ABIE) and all Library ABIEs.'
    )"/>
  <xsl:for-each select="$gu:FRG03-fragment-type-declarations">
    <xsl:copy-of select="gu:issue(.,concat(@gu:name,': ',
                   if( @gu:names ) then concat( 'too many (',@gu:names,')' )
                   else concat( 'mismatch (',@gu:type,' ',@gu:found,')' )) )"/>
  </xsl:for-each>

</pre>
  
</xsl:template>

</xsl:stylesheet>

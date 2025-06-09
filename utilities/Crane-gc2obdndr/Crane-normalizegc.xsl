<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: Crane-normalizegc.xsl,v 1.4 2017/08/01 18:02:48 admin Exp $"
     filename="Crane-normalizegc.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Normalize a genericode file</xs:title>
  <para>
    This reads a genericode file, normalizing the order of ABIEs.  When a
    base genericode file is supplied, the CCTS components are normalized into
    the same order and subset of those found in the base file.
  </para>
</xs:doc>

<xsl:include href="support/Crane-utilndr.xsl"/>

<xs:output>
  <para>Indented results are easier to review in editing</para>
</xs:output>
<xsl:output indent="yes"/>

<xs:param ignore-ns="yes">
  <para>The base entities open file; when using Saxon use +base=filename</para>
</xs:param>
<xsl:param name="base" as="document-node()?" 
           select="if( $base-uri)
                   then doc(resolve-uri($base-uri,base-uri($existing)))
                   else ()"/>

<xs:param ignore-ns="yes">
  <para>The base entities filename when not opening on invocation</para>
</xs:param>
<xsl:param name="base-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The existing entities open file</para>
</xs:param>
<xsl:param name="existing" as="document-node()" select="/"/>

<xs:template ignore-ns="yes">
  <para>Start the reports</para>
</xs:template>
<xsl:template match="/">
  <xsl:if test="not($existing/gc:CodeList)"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>Input file is not a genericode file: </xsl:text>
      <xsl:value-of select="document-uri($existing)"/>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$base[not(gc:CodeList)]"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>base file is not a genericode file: </xsl:text>
      <xsl:value-of select="document-uri($base)"/>
    </xsl:message>
  </xsl:if>

  <xsl:for-each select="*">
    <xsl:variable name="gu:columnSet" 
                  select="($base,$existing)[1]/*/ColumnSet"/>
    <xsl:variable name="gu:modelName" select="$gu:columnSet/Column[1]/@Id"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!--preserve metadata-->
      <xsl:copy-of select="Identification"/>
      <!--re-order existing to same subset and order of base-->
      <xsl:for-each select="ColumnSet">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:for-each select="$gu:columnSet/Column/@Id">
            <xsl:copy-of select="$existing/*/ColumnSet/Column[@Id=current()]"/>
          </xsl:for-each>
          <!--preserve key-->
          <xsl:copy-of select="Key"/>
        </xsl:copy>
      </xsl:for-each>
      <!--now do the rows-->
      <xsl:for-each select="SimpleCodeList">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:for-each-group select="Row" group-by="gu:col(.,$gu:modelName)">
       <xsl:sort select="gu:col(.,$gu:modelName)!=$gu:thisCommonLibraryModel"/>
       <xsl:sort select="gu:col(.,$gu:modelName)"/>
            <xsl:for-each select="current-group()">
              <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:variable name="gu:thisRowsValues" select="Value"/>
                <xsl:for-each select="$gu:columnSet/Column/@Id">
               <xsl:copy-of select="$gu:thisRowsValues[@ColumnRef=current()]"/>
                </xsl:for-each>
              </xsl:copy>
            </xsl:for-each>
          </xsl:for-each-group>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:for-each>

</xsl:template>

</xsl:stylesheet>

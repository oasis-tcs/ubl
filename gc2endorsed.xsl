<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<!--
    Convert a UBL genericode CCTS model that may or may not have columns
    of endorsed information reflecting deprecated constructs into a CCTS
    model reflecting the endorsed changes.
-->
  
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
    Copy all content using the identity template
  </para>
</xs:template>
<xsl:template mode="#all" match="node() | @*">
  <xsl:copy>
    <xsl:apply-templates mode="#current" select="@*,node()"/>
  </xsl:copy>
</xsl:template>
  
<xs:template>
  <para>
    Column definitions and column values no longer needed in the output
  </para>
</xs:template>
<xsl:template match="Column[starts-with(@Id,'Endorsed')] |
                     Value[starts-with(@ColumnRef,'Endorsed')]"/>

<xs:key>
  <para>Find all rows associated with ABIEs that are removed</para>
</xs:key>
<xsl:key name="c:BIEsRemovedByABIEs"
      use="Value[@ColumnRef='ObjectClass']/SimpleValue"
match="Row[Value[@ColumnRef='ComponentType']/SimpleValue='ABIE']
          [Value[@ColumnRef='EndorsedCardinality']/SimpleValue=('0','0..0')]"/>

<xs:template>
  <para>
    BIEs no longer needed due to deleted endorsed cardinality of ABIE
  </para>
</xs:template>
<xsl:template priority="2" match="Row[exists(key('c:BIEsRemovedByABIEs',
                              Value[@ColumnRef='ObjectClass']/SimpleValue))]"/>

<xs:template>
  <para>
    BIEs no longer needed due to deleted endorsed cardinality of BIE
  </para>
</xs:template>
<xsl:template priority="1" match="
       Row[Value[@ColumnRef='EndorsedCardinality']/SimpleValue=('0','0..0')]"/>

<xs:template>
  <para>
    Values replaced by their endorsed value
  </para>
</xs:template>
<xsl:template match="Value[@ColumnRef='Cardinality']
                          [../Value[@ColumnRef='EndorsedCardinality']]/
                     SimpleValue" priority="1">
  <xsl:copy-of select="../../Value[@ColumnRef='EndorsedCardinality']/
                             SimpleValue"/>
</xsl:template>


</xsl:stylesheet>

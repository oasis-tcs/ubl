<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<xs:doc info="schema summary update"
        filename="updateSchemaSummary.xsl" vocabulary="DocBook">
  <xs:title>Update the titles in the schema summary from a GC file</xs:title>
  <para>
    The schema summary is maintained separately from the spreadsheets, and
    so the descriptions can get out of sync. This brings them back into sync.
  </para>
</xs:doc>

<xs:output>
  <para>Indent the output</para>
</xs:output>
<xsl:output indent="yes"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Invocation parameters and input file</xs:title>
  <para>
    The input file is the old schema summary file
  </para>
</xs:doc>

<xs:param ignore-ns='yes'>
  <para>
    The GC file with the new definitions must be supplied
  </para>
</xs:param>
<xsl:param name="gc-uri" as="xsd:string" required="yes"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Main processing</xs:title>
</xs:doc>
  
<xs:template>
  <para>Put out a prologue before the content</para>
</xs:template>
<xsl:template match="/">
  <xsl:text disable-output-escaping="yes"><![CDATA[
<!--
  Instructions: Add new document types to the end of this document
  
  (see hub document XML comments for instructions)
-->
<!DOCTYPE schemadocs [
	<!ELEMENT schemadocs (schema+)>
	<!ELEMENT schema (name, description, processes, submitterRole, receiverRole, examples)>
	<!ELEMENT name (#PCDATA)>
	<!ELEMENT description (#PCDATA | link)*>
	<!ELEMENT process (#PCDATA)>
	<!ELEMENT link (#PCDATA)>
	<!ATTLIST link
		schema CDATA #IMPLIED
	>
	<!ATTLIST link
		figure CDATA #IMPLIED
	>
	<!ELEMENT example (#PCDATA)>
	<!ELEMENT submitterRole (#PCDATA)>
	<!ELEMENT receiverRole (#PCDATA)>
	<!ELEMENT processes (process*)>
	<!ELEMENT examples (example*)>
]>
]]></xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xs:template>
  <para>The top-level comments are handled by the CDATA section</para>
</xs:template>
<xsl:template match="/comment()"/>

<xs:template>
  <para>Replace the definition</para>
</xs:template>
<xsl:template match="description">
  <description>
    <xsl:value-of select="
  c:col(key('c:rows',concat(../name,'. Details'),doc($gc-uri)),'Definition')"/>
  </description>
</xsl:template>

<xs:template>
  <para>
    The identity template is used to copy all nodes not already being handled
    by other template rules.
  </para>
</xs:template>
<xsl:template match="@*|node()" mode="#all">
  <xsl:copy>
    <xsl:apply-templates mode="#current" select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Support</xs:title>
</xs:doc>

<xs:key>
  <para>Quick access to the GC file</para>
</xs:key>
<xsl:key name="c:rows" match="Row" use="c:col(.,'DictionaryEntryName')"/>

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

</xsl:stylesheet>

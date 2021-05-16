<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:c="urn:X-Crane"
                exclude-result-prefixes="xs xsd c"
                version="2.0">

<xs:doc info="$Id: namespaceCheck.xsl,v 1.4 2013/05/13 15:30:32 admin Exp $"
        filename="namespaceCheck.xsl" vocabulary="DocBook" internal-ns="c">
  <xs:title>Check XML instances for declared but unused namespaces</xs:title>
  <para>
    This reads a directory of XML instances and reports superfluous 
    namespace declarations.
  </para>
</xs:doc>

<xs:output>
  <para>Only producing text</para>
</xs:output>
<xsl:output method="text"/>

<xs:param ignore-ns="yes">
  <para>The directory of XML instances.</para>
</xs:param>
<xsl:param name="dir" as="xsd:string" required="yes"/>

<xs:template>
  <para>Report all problems.</para>
</xs:template>
<xsl:template match="/">
  <xsl:variable name="files"
                select="collection(concat(translate($dir,'\','/'),
                                   '/?select=*.xml;recurse=yes'))"/>
  <xsl:text>File count: </xsl:text><xsl:value-of select="count($files)"/>
  <xsl:text>
</xsl:text>
  <xsl:for-each select="$files">
    <xsl:value-of select="replace(document-uri(.),'.*/','')"/>:
<xsl:text/>
    <xsl:for-each select="//processing-instruction()">
      <xsl:text> PI: </xsl:text>
      <xsl:value-of select="name(.),."/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <!--
    <xsl:if test="position()=1">
      <xsl:value-of select="replace(document-uri(.),'[^/]+$','')"/>:
<xsl:text/>
    </xsl:if>
    -->
    <xsl:variable name="ns-decl" 
           select="distinct-values(//namespace::*[name(.)!='xml']/string(.))"/>
    <xsl:variable name="ns-used"
                  select="//*/namespace-uri(.)"/>
    <xsl:for-each select="$ns-decl[not(.=$ns-used)]">
      <xsl:text> </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>

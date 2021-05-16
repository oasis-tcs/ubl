<?xml version="1.0" encoding="US-ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
<!--
    Let the XML processor in the XSLT processor assemble all of the
    edited entities to create a monolithic XML document for publishing.
    
    Preserve top-level PIs for publishing/presentation purposes.
    
    Preserve the <!DOCTYPE> declaration for validation purposes.
-->

<xsl:template match="/">
  <xsl:result-document>
    <!--start on a new line, not immediately after the XML declaration-->
    <xsl:text>&#xa;</xsl:text>
    <!--preserve all top-level PIs-->
    <xsl:for-each  select="/processing-instruction()">
      <xsl:copy-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <!--preserve the document type declaration-->
    <xsl:for-each select="unparsed-text(document-uri(/))">
      <xsl:value-of disable-output-escaping="yes"
                 select="replace(.,'.+?(&lt;!DOCTYPE.+?)[>\[].+$','$1>','s')"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <!--preserve the document itself, with its resolved entities-->
    <xsl:copy-of select="*"/>
  </xsl:result-document>
</xsl:template>

</xsl:stylesheet>

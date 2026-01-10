<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:lxslt="http://xml.apache.org/xslt"
                xmlns:xalanredirect="org.apache.xalan.xslt.extensions.Redirect"
                xmlns:exsl="http://exslt.org/common"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                exclude-result-prefixes="saxon lxslt xalanredirect exsl axf"
                extension-element-prefixes="saxon xalanredirect lxslt exsl"
                version="1.0">
<!-- $Id: oasis-mathml-fo.xsl,v 1.1 2020/03/28 15:11:43 admin Exp $ -->

<!--some processors need MathML in the default namespace-->
<!--the overflow attribute is meaningless in the print medium-->
    
<xsl:template match="mml:math" xmlns:mml="http://www.w3.org/1998/Math/MathML">
  <fo:instream-foreign-object>
    <xsl:apply-templates select="." mode="oasis.mathml"/>
  </fo:instream-foreign-object>
</xsl:template>

<xsl:template match="mml:*" xmlns:mml="http://www.w3.org/1998/Math/MathML"
              mode="oasis.mathml" priority="1">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="oasis.mathml"/>
    <xsl:apply-templates mode="oasis.mathml"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="mml:math/@overflow" mode="oasis.mathml"
              xmlns:mml="http://www.w3.org/1998/Math/MathML"/>

<xsl:template match="@* | text() | comment() | processing-instruction()"
              mode="oasis.mathml">
  <xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>

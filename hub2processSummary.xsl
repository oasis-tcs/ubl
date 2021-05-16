<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">

<!--this is not at all optimized since it is a one-off each revision-->
<!--this needs to point to the old version of the hub document in
    order to know which entries have to be emphasized
-->

<xsl:output indent="yes" omit-xml-declaration="yes"/>
  
<xsl:param name="old" required="yes" as="xs:string"/>

<xsl:variable name="oldDoc" select="document($old,/)"/>

<xsl:key name="ids" match="*[@id]" use="@id"/>
  
<xsl:template match="/">
  <xsl:message select="'Creating process summary'"/>
  <xsl:comment>
To get an updated version of this entity file, please run the build process
and obtain a copy from the archive-only-not-in-final-distribution/new-entities
directory.
</xsl:comment><xsl:text>&#xa;</xsl:text>
  <xsl:for-each select="//section[@role='processes']">
    <itemizedlist spacing="compact" mark="none" role="processLinkSummary">
      <xsl:apply-templates select="section[position()>1]"/>
    </itemizedlist>
  </xsl:for-each>
</xsl:template>

<xsl:template match="section">
  <listitem>
    <para>
      <xsl:choose>
        <xsl:when test="not(key('ids',@id,$oldDoc))">
          <emphasis><emphasis role="bold">
            <xref linkend="{@id}"/>
          </emphasis></emphasis>
        </xsl:when>
        <xsl:otherwise>
          <xref linkend="{@id}"/>
        </xsl:otherwise>
      </xsl:choose>
    </para>
    <xsl:if test="section">
      <itemizedlist spacing="compact" mark="none">
        <xsl:apply-templates select="section"/>
      </itemizedlist>
    </xsl:if>
  </listitem>
</xsl:template>

</xsl:stylesheet>
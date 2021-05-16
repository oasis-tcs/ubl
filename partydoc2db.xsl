<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">

<xsl:output indent="yes" omit-xml-declaration="yes"/>
  
<xsl:template match="/">
  <xsl:comment>
To get an updated version of this entity file, please run the build process
and obtain a copy from the archive-only-not-in-final-distribution/new-entities
directory.
</xsl:comment>
  <xsl:message
       select="'Creating entity with party roles:',count(/*/entry),'entries'"/>
  <table role="font-size-70%" id="T-PARTY-ROLES">
    <title>Party Roles</title>
    <tgroup cols="7">
      <colspec colwidth="1.08*"/>
      <colspec colwidth="1.08*"/>
      <colspec colwidth="2.07*"/>
      <colspec colwidth="1.53*"/>
      <colspec colwidth="1*"/>
      <colspec colwidth="1.15*"/>
      <colspec colwidth="1.08*"/>
      <thead>
        <row valign="middle">
          <entry align="left"><para><emphasis role="bold"
            >Actor</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Role</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Description</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Example</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Synonyms</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Sends</emphasis></para></entry>
          <entry align="left"><para><emphasis role="bold"
            >Receives</emphasis></para></entry>
        </row>
      </thead>
      <tbody>
        <xsl:for-each select="/roletable/entry">
          <row>
            <xsl:for-each select="*">
              <entry align="left">
                <xsl:apply-templates/>
              </entry>
            </xsl:for-each>
          </row>
        </xsl:for-each>
      </tbody>
    </tgroup>
  </table>
</xsl:template>

<xsl:template match="schema">
  <link 
     linkend="S-{translate(upper-case(normalize-space(.)),' ,()','-')}-SCHEMA">
    <xsl:value-of select="normalize-space(.)"/>
  </link>
</xsl:template>

<xsl:template match="*">
  <xsl:message terminate="yes" select="'Not handled:',name(.)"/>
</xsl:template>

</xsl:stylesheet>
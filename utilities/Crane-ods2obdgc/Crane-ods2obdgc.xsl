<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
  xmlns:c="urn:X-Crane:stylesheets:gc-toolkit"
  xmlns:o="urn:X-Crane:stylesheets:odf-access"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  exclude-result-prefixes="xs xsd gc c o office table text"
  version="2.0"> 
<!-- xmlns:f="urn:X-Crane:stylesheets:obfuscation" -->

<xs:doc info="$Id: Crane-ods2obdgc.xsl,v 1.8 2020/08/08 16:53:12 admin Exp $"
        filename="Crane-ods2odsgc.xsl" vocabulary="DocBook">
  <xs:title>Open Document Spreadsheet to Business Document ODS Genericode</xs:title>
  <para>
    This converts an instance of a subset of OASIS ODF 1.1 into an 
    instance of OASIS Genericode 1.0, presuming that the genericode
    is a set of CCTS information destined for use in creating schemas.
  </para>
<programlisting role="copyright">
Copyright (C) - Crane Softwrights Ltd.
              - http://www.CraneSoftwrights.com/links/res-dev.htm

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Note: for your reference, the above is the "Modified BSD license", this text
      was obtained 2003-07-26 at http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5

THE AUTHOR MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS CODE FOR ANY
PURPOSE.
</programlisting>
</xs:doc>

<xs:param ingore-ns="yes">
  <para>Name the column with which to store the row number.</para>
</xs:param>
<xsl:param name="row-number-column-name" as="xsd:string?" select="()"/>
  
<xs:param ingore-ns="yes">
  <para>Name the file of replacement Identification information.</para>
</xs:param>
<xsl:param name="identification-uri" as="xsd:string?" select="()"/>
  
<xs:param ingore-ns="yes">
  <para>
    Comma-separated names of ODS files when not supplying input XML.
  </para>
</xs:param>
<xsl:param name="ods-uri" as="xsd:string?" select="()"/>

<xs:param ingore-ns="yes">
  <para>
    Indicate that the output is raw (all columns optional, no keys, no
    constraints) by indicating the long name of the column to contain
    the sheet name.
  </para>
</xs:param>
<xsl:param name="raw-sheet-long-name" as="xsd:string?" select="()"/>

<xs:param ingore-ns="yes">
  <para>
    Indicate which worksheet/table names are to be included.
  </para>
</xs:param>
<xsl:param name="included-sheet-name-regex" as="xsd:string?" select="'^.+$'"/>

<xs:param ingore-ns="yes">
  <para>Establish the indentation of the result.</para>
</xs:param>
<xsl:param name="indent" as="xsd:string" select="'yes'"/>

<xs:function>
  <para>Determine actual URI to use</para>
  <xs:param name="c:ods-uri">
    <para>The basis on which to calculate a JAR URI</para>
  </xs:param>
</xs:function>
<xsl:function name="c:ods-uri" as="xsd:string?">
  <xsl:param name="c:ods-uri" as="xsd:string?"/>
  <xsl:variable name="c:ods-uri" select="translate($c:ods-uri,'\','/')"/>
  <xsl:sequence select="concat('jar:file:',$c:ods-uri,'!/content.xml')"/>
</xsl:function>

<xs:variable>
  <para>Base stylesheet URI needed for relative resolution</para>
</xs:variable>
<xsl:variable name="c:baseSSuri" select="document-uri(document(''))" 
              as="xsd:string"/>
<!--========================================================================-->
<xs:doc>
  <xs:title>Emitting genericode XML from spreadsheet content</xs:title>
</xs:doc>

<xs:template>
  <para>Starting with a set of input ZIP files</para>
</xs:template>
<xsl:template name="ods-uri">
  <xsl:variable name="c:ods-uri-use" 
                select="for $each in tokenize( $ods-uri, ',' ) 
                        return c:ods-uri($each)"/>
  <xsl:variable name="c:odsOverride" as="document-node()*">
    <xsl:for-each select="$c:ods-uri-use">
      <xsl:if test="not(doc-available(.))">
        <xsl:message terminate="yes">
         <xsl:text>The given URI "</xsl:text>
         <xsl:value-of
            select="replace(.,'^jar:file:(/(.:))?(.*)!/content.xml$','$2$3')"/>
         <xsl:text>" does not appear to </xsl:text>
         <xsl:text>point to a ZIP package with a "content.xml" file.</xsl:text>
        </xsl:message>
      </xsl:if>
      <xsl:sequence select="doc(.)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:call-template name="c:documentElement">
    <xsl:with-param name="c:roots" select="$c:odsOverride"/>
  </xsl:call-template>
</xsl:template>

<xs:template>
  <para>Establish indentation based on parameter.</para>
</xs:template>
<xsl:template match="/" priority="1">
  <xsl:result-document 
    indent="{if( lower-case($indent)=('y','yes') ) then 'yes' else 'no'}">
    <xsl:apply-templates/>
  </xsl:result-document>
</xsl:template>
 
<xs:template>
  <para>The handling of a file of file names.</para>
</xs:template>
<xsl:template match="/directory" priority="3">
  <xsl:variable name="c:roots" as="document-node()*">
    <xsl:for-each select="//file">
      <xsl:variable name="c:uri" select="replace(
     resolve-uri(string-join(ancestor-or-self::*/@name,'/'),document-uri(/)),
                                          '^file:(/(.:))?','$2')"/>
      <xsl:choose>
        <xsl:when test="doc-available($c:uri)">
          <!--then the file better be an ODS XML file-->
          <xsl:choose>
            <xsl:when test="not(doc($c:uri)/
                                (office:document | office:document-content)/
                                office:body/office:spreadsheet/table:table)">
             <xsl:message terminate="yes">
              <xsl:text>The given URI "</xsl:text>
              <xsl:value-of select="$c:uri"/>
              <xsl:text>" does not appear to </xsl:text>
              <xsl:text>point to an XML ODS file.</xsl:text>
             </xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="doc($c:uri)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!--the file better be an ODS binary file-->
          <xsl:variable name="c:open-uri" select="c:ods-uri($c:uri)"/>
          <xsl:choose>
            <xsl:when test="not(doc-available($c:open-uri))">
             <xsl:message terminate="yes">
              <xsl:text>The given URI "</xsl:text>
              <xsl:value-of select="$c:uri"/>
              <xsl:text>" does not appear to </xsl:text>
              <xsl:text>point to a binary ODF file.</xsl:text>
             </xsl:message>
            </xsl:when>
            <xsl:when test="not(doc($c:open-uri)/
                                (office:document | office:document-content)/
                                office:body/office:spreadsheet/table:table)">
             <xsl:message terminate="yes">
              <xsl:text>The given URI "</xsl:text>
              <xsl:value-of select="$c:uri"/>
              <xsl:text>" does not appear to </xsl:text>
              <xsl:text>point to a binary ODS file.</xsl:text>
             </xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="doc($c:open-uri)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  <!--check to make sure every file opened-->
  <xsl:if test="count(//file) != count($c:roots)">
    <xsl:message terminate="yes"/>
  </xsl:if>
  <xsl:call-template name="c:documentElement">
    <xsl:with-param name="c:roots" select="$c:roots"/>
  </xsl:call-template>
</xsl:template>

<xs:template>
  <para>Only allow instances with expected content.</para>
  <xs:param name="c:roots">
    <para>The root of each input genericode file being processed.</para>
  </xs:param>
</xs:template>
<xsl:template match="/office:document | /office:document-content"
              priority="2" name="c:documentElement">
  <xsl:param name="c:roots" select=".." as="document-node()+"/>
  <xsl:variable name="c:tables" 
                select="$c:roots/*/office:body/office:spreadsheet/table:table
                           [matches(@table:name,$included-sheet-name-regex)]"/>
  <xsl:variable name="c:columnMetadata" as="element(Column)*">
    <xsl:for-each-group group-by="normalize-space(string-join(text:p,' '))"
 select="($c:tables//table:table-row)[1]/table:table-cell[normalize-space(.)]">
      <xsl:variable name="c:longName" 
                    select="normalize-space(current-grouping-key())"/>
      <xsl:variable name="c:shortName"
                    select="replace($c:longName,'\W+','')"/>
      <Column Id="{$c:shortName}" 
              Use="{if( $c:shortName = 'DictionaryEntryName' and
                        empty( $raw-sheet-long-name ) ) 
                    then 'required' else 'optional'}">
        <ShortName><xsl:value-of select="$c:shortName"/></ShortName>
        <LongName><xsl:value-of select="$c:longName"/></LongName>
        <Data Type="string"/>
      </Column>
    </xsl:for-each-group>
  </xsl:variable>
  <!--check for violations or absent column data-->
  <xsl:if test="empty($raw-sheet-long-name)">
    <!--then constraints apply for using with BD Naming and Design Rules-->
    <xsl:variable name="c:messages">
      <xsl:if test="($c:columnMetadata/@Id,$row-number-column-name)=
                    'ModelName'">
        <xsl:text>Cannot have a column named "ModelName" as this is </xsl:text>
        <xsl:text>reserved to be defined by the worksheet name.&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="not($c:columnMetadata/@Id='DictionaryEntryName')">
        <xsl:text>Must have a column named "DictionaryEntryName" as </xsl:text>
      <xsl:text>this is the key column for the genericode file.&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="$c:columnMetadata/@Id=$row-number-column-name">
        <xsl:text>Cannot have a column with the same name as the </xsl:text>
        <xsl:text>column designated to store the row number.&#xa;</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="normalize-space($c:messages)">
      <xsl:message terminate="yes" select="$c:messages"/>
    </xsl:if>  
  </xsl:if>
<gc:CodeList xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
  <xsl:call-template name="c:Identification"/>
  <ColumnSet>
    <xsl:choose>
      <xsl:when test="empty($raw-sheet-long-name)">
        <!--make presumptions regarding BD NDR-->
        <Column Id="ModelName" Use="required">
          <ShortName>ModelName</ShortName>
          <LongName>Model Name</LongName>
          <Data Type="string"/>
        </Column>
        <xsl:for-each select="$row-number-column-name">
          <Column Id="{translate(normalize-space(.),' ','')}" Use="required">
            <ShortName>
              <xsl:value-of select="translate(normalize-space(.),' ','')"/>
            </ShortName>
            <LongName><xsl:value-of select="."/></LongName>
            <Data Type="integer"/>
          </Column>
        </xsl:for-each>
        <xsl:copy-of select="$c:columnMetadata"/>
        <Key Id="key">
          <ShortName>Key</ShortName>
          <ColumnRef Ref="DictionaryEntryName"/>
        </Key>
      </xsl:when>
      <xsl:when test="string($raw-sheet-long-name)">
        <!--the sheet name is being saved-->
        <Column Id="{$worksheetIdentifier}" Use="optional">
          <ShortName><xsl:value-of select="$worksheetIdentifier"/></ShortName>
          <LongName><xsl:value-of select="$raw-sheet-long-name"/></LongName>
          <Data Type="string"/>
        </Column>
        <xsl:copy-of select="$c:columnMetadata"/>
      </xsl:when>
      <xsl:otherwise>
        <!--the sheet name is not being saved-->
        <xsl:copy-of select="$c:columnMetadata"/>
      </xsl:otherwise>
    </xsl:choose>
  </ColumnSet>
  <SimpleCodeList>
    <xsl:call-template name="c:emitGenericode">
      <xsl:with-param name="c:tables" select="$c:tables"/>
    </xsl:call-template>
  </SimpleCodeList>
</gc:CodeList>
</xsl:template>

<xs:template>
  <para>Only allow instances with expected content.</para>
</xs:template>
<xsl:template match="/*" priority="1">
  <!--don't know what is going on; unexpected input-->
  <xsl:apply-templates mode="c:reportStartupError" select=".">
    <xsl:with-param name="c:problemMessage" tunnel="yes" as="text()*">
      <xsl:text>This filter does not support an XML instance </xsl:text>
      <xsl:value-of select="concat('starting with {',namespace-uri(*),'}',
                                   name(*))"/>
    </xsl:with-param>
  </xsl:apply-templates>
</xsl:template>

<xs:template>
  <para>
    Replace identification information if provided
  </para>
</xs:template>
<xsl:template name="c:Identification">
  <xsl:choose>
    <xsl:when test="exists($identification-uri)">
      <xsl:choose>
        <xsl:when test="not(doc-available($identification-uri))">
          <xsl:message terminate="yes">
            <xsl:text>The file at parameter identification-uri= </xsl:text>
            <xsl:text>is not found or is not an XML file.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="not(doc($identification-uri)/Identification)">
          <xsl:message terminate="yes">
            <xsl:text>The file at parameter identification-uri= </xsl:text>
            <xsl:text>does not have "{}Identification" as the </xsl:text>
            <xsl:text>document element.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="doc($identification-uri)/Identification"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Using built-in placebo Identification metadata'"/>
      <Identification>
        <ShortName>OBDNDRSkeleton</ShortName>
        <LongName>OASIS Business Document NDR skeleton genericode file</LongName>
        <Version>1</Version>
        <CanonicalUri>urn:X-CraneSoftwrights.com</CanonicalUri>
        <CanonicalVersionUri>urn:X-CraneSoftwrights.com</CanonicalVersionUri>
      </Identification>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Skeleton genericode output file</xs:title>
</xs:doc>

<!--bring incommon functionality-->
<xsl:include href="support/gcExportSubset.xsl"/>

</xsl:stylesheet>
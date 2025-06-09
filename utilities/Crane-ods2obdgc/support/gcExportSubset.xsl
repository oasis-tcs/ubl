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
  exclude-result-prefixes="xs xsd gc c o office table"
  version="2.0">
<!-- xmlns:f="urn:X-Crane:stylesheets:obfuscation" -->

<xs:doc info="$Id: gcExportSubset.xsl,v 1.20 2020/08/08 17:55:21 admin Exp $"
        filename="gcExportSubset.xsl" vocabulary="DocBook">
  <xs:title>Open Document Spreadsheet to Genericode Subset Transformation</xs:title>
  <para>
    This converts an instance of a subset of OASIS ODF 1.1 into an 
    instance of OASIS Genericode 1.0.
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
  <para>Name the worksheet identifying column reference identifier.</para>
  <para>
    When this value is the empty string, the worksheet column is not emitted.
  </para>
</xs:param>
<xsl:param name="worksheetIdentifier" as="xsd:string?" 
           select="if( exists( $raw-sheet-long-name ) ) 
                   then if( string( $raw-sheet-long-name ) )
                       then replace($raw-sheet-long-name,'\W+','')
                       else ()
                   else 'ModelName'"/>

<xs:param ignore-ns="yes">
  <para>Instructions to lengthen the model name</para>
</xs:param>
<xsl:param name="lengthen-model-name-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>Instructions to lengthen the model name</para>
</xs:param>
<xsl:param name="c:lengthenModelNameAbsURI" as="xsd:string?"
           select="resolve-uri($lengthen-model-name-uri,$c:baseSSuri)"/>

<xs:param ignore-ns="yes">
  <para>Instructions to lengthen the model name</para>
</xs:param>
<xsl:param name="c:lengthen-model-name-file" as="document-node()?"
      select="if( empty($lengthen-model-name-uri) ) then ()
              else if( doc-available( $c:lengthenModelNameAbsURI ) )
                   then for $d in doc( $c:lengthenModelNameAbsURI ) return
                        if ( $d/modelNameMassage )
                        then $d
                        else error((),
                                 'Unexpected document element in lengthen URI')
                   else error((),'Unable to open lengthen-model-name URI')"/>

<xs:output>
  <para>This file is most legible when indented.</para>
</xs:output>
<xsl:output indent="yes"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Emitting genericode XML from spreadsheet content</xs:title>
</xs:doc>

<xs:template>
  <para>Only allow instances with expected content.</para>
</xs:template>
<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="not(office:document or office:document-content)">
      <!--don't know what is going on-->
      <xsl:apply-templates mode="c:reportStartupError" select="node()">
        <xsl:with-param name="c:problemMessage" tunnel="yes" as="text()*">
          <xsl:text>This filter does not support an instance </xsl:text>
          <xsl:value-of select="concat('starting with {',namespace-uri(*),'}',
                                       name(*))"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="c:emitGenericode">
        <xsl:with-param name="c:tables"
                       select="/*/office:body/office:spreadsheet/table:table"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:template>
  <para>Handle a genericode element with column info in spreadsheet.</para>
  <xs:param name="c:tables">
    <para>All of the tables of sheets contributing to output</para>
  </xs:param>
</xs:template>
<xsl:template name="c:emitGenericode">
  <xsl:param name="c:tables" as="element(table:table)*"/>
  <xsl:for-each select="$c:tables">
    <xsl:variable name="c:modelName" select="c:lengthen(@table:name)"/>
    <xsl:variable name="c:columnCount" as="xsd:integer"
                  select="o:column((.//table:table-row)[1]/
                                table:table-cell[normalize-space()][last()])"/>
    <xsl:variable name="c:columnHeads" as="element()*">
      <xsl:for-each select="(.//table:table-row)[1]">
        <xsl:variable name="c:thisRow" select="."/>
        <xsl:for-each select="1 to 
                  xsd:integer( o:column(table:table-cell[last()])[last()] )">
          <guess>
            <xsl:value-of select="normalize-space(string-join(
                            $c:thisRow/table:table-cell[o:column(.)=current()]/
                            replace(o:odsCell2Text(.),'\W+',''),''))"/>
          </guess>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="c:lastTableRow"
                  select="( (.//table:table-row)[normalize-space(
                  string-join(table:table-cell/o:odsCell2Text(.),''))='END']/
                                    preceding::table:table-row[1],
                            (.//table:table-row)[last()] )[1]"/>
    <xsl:for-each select="(.//table:table-row)[position()>1]
                                         [ .    is    $c:lastTableRow or
                                           . &lt;&lt; $c:lastTableRow ]
                     [string-join(table:table-cell/o:odsCell2Text(.),'')!='']">
      <Row>
        <xsl:if test="not($row-number-column-name)">
          <xsl:comment select="position()+1"/>
        </xsl:if>
        <xsl:if test="lower-case($indent)=('y','yes')">
          <xsl:text>&#xa;         </xsl:text>
        </xsl:if>
        <xsl:if test="$worksheetIdentifier">
          <Value ColumnRef="{$worksheetIdentifier}">
            <SimpleValue><xsl:value-of select="$c:modelName"/></SimpleValue>
          </Value>
        </xsl:if>
        <xsl:if test="$row-number-column-name">
          <Value
    ColumnRef="{translate(normalize-space($row-number-column-name),'\W+','')}">
            <SimpleValue>
              <xsl:value-of select="position()+1"/>
            </SimpleValue>
          </Value>
        </xsl:if>
        <xsl:variable name="c:thisRow" select="."/>
        <xsl:for-each select="1 to $c:columnCount">
          <xsl:variable name="c:thisColumn" select="."/>
          <xsl:if test="normalize-space($c:columnHeads[$c:thisColumn])">
            <xsl:for-each select="o:odsColumn2Text($c:thisRow,$c:thisColumn)
                                  [normalize-space(.)]">
              <Value ColumnRef="{$c:columnHeads[$c:thisColumn]}">
                <SimpleValue>
                  <xsl:value-of select="."/>
                </SimpleValue>
              </Value>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </Row>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Utility</xs:title>
</xs:doc>

<xs:function>
  <para>Apply, in reverse order, regular expressions on a string.</para>
  <xs:param name="c:value">
    <para>The value to be massaged.</para>
  </xs:param>
</xs:function>
<xsl:function name="c:lengthen" as="xsd:string?">
  <xsl:param name="c:value" as="xsd:string?"/>
  <xsl:sequence select="if( exists($c:value) ) 
then c:lengthen($c:value,$c:lengthen-model-name-file/*/pass[last()]) else ()"/>
</xsl:function>

<xs:function>
  <para>Apply, in reverse order, regular expressions on a string.</para>
  <xs:param name="c:value">
    <para>The value to be massaged.</para>
  </xs:param>
  <xs:param name="c:pass">
    <para>A pass of the conversion</para>
  </xs:param>
</xs:function>
<xsl:function name="c:lengthen" as="xsd:string?">
  <xsl:param name="c:value" as="xsd:string?"/>
  <xsl:param name="c:pass" as="element(pass)?"/>
  <xsl:sequence select="if( $c:pass ) then c:lengthen( 
        replace( $c:value, $c:pass/lengthen/@find, $c:pass/lengthen/@replace ),
                                           $c:pass/preceding-sibling::pass[1] )
                                      else $c:value"/>
</xsl:function>

<!--========================================================================-->
<xs:doc>
  <xs:title>Input/output templates</xs:title>
</xs:doc>

<xs:variable ignore-ns='yes'>
  <para>
    From the command-line, this is an overriding template file.  
    Without using the command line the template file referenced by the entity
    is used.
    In the assembled stylesheet this becomes inline.
  </para>
</xs:variable>
<xsl:variable name="odsTemplate" as="document-node()">
 <xsl:document xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0">
   <office:document/>
 </xsl:document>
</xsl:variable>

<!--bring incommon functionality-->
<xsl:include href="odsCommon.xsl"/>

</xsl:stylesheet>
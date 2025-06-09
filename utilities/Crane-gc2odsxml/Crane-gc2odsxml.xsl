<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
  xmlns:c="urn:X-Crane:stylesheets:gc-toolkit"
  xmlns:o="urn:X-Crane:stylesheets:odf-access"
  xmlns:gu="urn:X-gc2obdndr"  
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"  
  xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
  exclude-result-prefixes="xs xsd gc c o office table text dc config"
  version="2.0">

<xs:doc info="$Id: Crane-gc2odsxml.xsl,v 1.19 2017/07/27 02:19:04 admin Exp $"
        filename="Crane-gc2odsxml.xsl" vocabulary="DocBook">
  <xs:title>UBL Genericode to Open Document Spreadsheet XML</xs:title>
  <para>
    This converts an instance of OASIS Genericode 1.0 into one or more
    instances of a subset of OASIS ODF 1.1.
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

<xsl:include href="support/Crane-commonndr.xsl"/>
<xsl:include href="support/ndrSubset.xsl"/>

<xs:param ingore-ns="yes">
  <para>Name the ODS file being used as a model</para>
</xs:param>
<xsl:param name="skeleton-ods-uri" as="xsd:string?" required="yes"/>

<xs:param ingore-ns="yes">
  <para>Signal for one or many output files</para>
</xs:param>
<xsl:param name="single-output" as="xsd:string?" select="'yes'"/>

<xs:variable>
  <para>Signal for one or many output files as boolean</para>
</xs:variable>
<xsl:variable name="c:single-output" as="xsd:boolean" 
             select="lower-case($single-output)=('y','yes')"/>

<xs:param ingore-ns="yes">
  <para>Signal for ordering common library files first</para>
</xs:param>
<xsl:param name="common-first" as="xsd:string?" select="'no'"/>

<xs:variable>
  <para>Signal for ordering common library files first</para>
</xs:variable>
<xsl:variable name="c:common-first" as="xsd:boolean" 
             select="lower-case($common-first)=('y','yes')"/>

<xs:param ignore-ns="yes">
  <para>Instructions to shorten the model name</para>
</xs:param>
<xsl:param name="shorten-model-name-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>Preservation of the cardinality column</para>
</xs:param>
<xsl:param name="old-cardinality-column-name" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>Instructions to shorten the model name</para>
</xs:param>
<xsl:param name="c:shorten-model-name-file" as="document-node()?"
      select="if( empty($shorten-model-name-uri) ) then ()
              else if( doc-available( $shorten-model-name-uri ) )
                   then for $d in doc( $shorten-model-name-uri ) return
                        if ( $d/modelNameMassage )
                        then $d
                        else error((),
                                  'Unexpected document element in shorten URI')
                   else error((),'Unable to open shorten-model-name URI')"/>

<xs:param ignore-ns="yes">
  <para>Identifying the common library model</para>
</xs:param>
<xsl:param name="common-name-regex" as="xsd:string" select="'Common'"/>

<xs:variable>
  <para>Source of the genericode content</para>
</xs:variable>
<xsl:variable name="c:gc" as="document-node()" select="/"/>

<xs:variable>
  <para>Valid values for the "name" column</para>
</xs:variable>
<xsl:variable name="c:names" as="xsd:string*"
              select="('Name','UBLName','ComponentName')"/>

<xs:function>
  <para>Determine actual URI to use</para>
  <xs:param name="c:ods-uri">
    <para>The basis on which to calculate a JAR URI</para>
  </xs:param>
  <xs:param name="c:dir">
    <para>Which directory to look in for files</para>
  </xs:param>
  <xs:param name="c:filename">
    <para>Which of the files to obtain</para>
  </xs:param>
</xs:function>
<xsl:function name="c:ods-uri" as="xsd:string?">
  <xsl:param name="c:ods-uri" as="xsd:string?"/>
  <xsl:param name="c:dir" as="xsd:string?"/>
  <xsl:param name="c:filename" as="xsd:string"/>
  <xsl:variable name="c:ods-uri" select="translate($c:ods-uri,'\','/')"/>
  <xsl:sequence
              select="concat('jar:file:',$c:ods-uri,'!/',$c:dir,$c:filename)"/>
</xsl:function>

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

<xs:variable>
  <para>Declare a newline so that obfuscation is not affected</para>
</xs:variable>
<xsl:variable name="c:newline" as="xsd:string">
  <xsl:text>
</xsl:text>
</xsl:variable>

<!--Indentation causes not-nice things to happen in Google.-->
<!--<xsl:output indent="yes"/>-->

<!--========================================================================-->
<xs:doc>
  <xs:title>Emitting spreadsheet XML from genericode content</xs:title>
</xs:doc>

<xs:template>
  <para>Starting with an input genericode file.</para>
</xs:template>
<xsl:template match="/">
  <!--check input-->
  <xsl:if test="not(gc:CodeList)"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>Unexpected input file document element "</xsl:text>
      <xsl:value-of select="concat('{',namespace-uri(*),'}',name(I))"/>
      <xsl:text>"; expected "</xsl:text>
  <xsl:text>{http://docs.oasis-open.org/codelist/ns/genericode/1.0/}</xsl:text>
      <xsl:text>CodeList".</xsl:text>
    </xsl:message>   
  </xsl:if>
  <!--check subsetting; stop if meaningless-->
  <xsl:if test="$gu:activeSubsetting and $subset-column-name and
                ( every $c:subset in 
                  $c:gc/*/SimpleCodeList/Row/c:col(.,$subset-column-name)
                  satisfies normalize-space($c:subset)='' )">
    <xsl:message terminate="yes">
      <xsl:text>No subset information found for named column: </xsl:text>
      <xsl:value-of select="$subset-column-name"/>
    </xsl:message>
  </xsl:if>

  <!--create output-->
  <xsl:choose>
    <xsl:when test="$c:single-output">
      <!--create only a single set of output files-->
      <xsl:call-template name="c:outputFiles">
        <xsl:with-param name="c:modelName" 
                  select="$c:gc/*/SimpleCodeList/Row[1]/c:col(.,'ModelName')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <!--create a set of output files for each model in the input-->
      <xsl:for-each-group select="$c:gc/*/SimpleCodeList/Row"
                          group-by="c:col(.,'ModelName')">
    <xsl:if test="if( empty( $subset-model-regex ) or
                      matches( current-grouping-key(),$common-name-regex ) )
                  then true()
                  else matches( current-grouping-key(),$subset-model-regex )">
        <xsl:call-template name="c:outputFiles">
          <xsl:with-param name="c:baseDir"
                          select="concat(current-grouping-key(),'/')"/>
          <xsl:with-param name="c:modelName" select="current-grouping-key()"/>
        </xsl:call-template>
    </xsl:if>
      </xsl:for-each-group>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<c:files>
  <c:file type="copy" name="styles.xml"/>
  <c:file type="massage" name="settings.xml"/>
  <c:file type="copy" name="meta.xml" required="no"/>
  <c:file type="copy" name="manifest.xml" dir="META-INF/"/>
  <c:file type="copy" name="current.xml" dir="Configurations2/accelerator/"
          required="no"/>
  <c:file type="massage" name="content.xml"/>
  <c:file type="copy" name="mimetype" required="no"/>
</c:files>

<xs:template>
  <para>
    Create a suite of output files copying the input ODS file.
  </para>
  <xs:param name="c:baseDir">
    <para>The base directory in the input ODS where the file is found.</para>
  </xs:param>
  <xs:param name="c:modelName">
    <para>The name of the model.</para>
  </xs:param>
</xs:template>
<xsl:template name="c:outputFiles">
  <xsl:param name="c:baseDir" as="xsd:string" select="''"/>
  <xsl:param name="c:modelName" as="xsd:string" required="yes"/>

  <!--check that the ODS file exists by looking for content.xml-->
  <xsl:if
      test="not(doc-available(c:ods-uri($skeleton-ods-uri,'','content.xml')))">
    <xsl:message terminate="yes">
      <xsl:text>The given URI "</xsl:text>
      <xsl:value-of select="
  replace($skeleton-ods-uri,'^jar:file:(/(.:))?(.*)!/content.xml$','$2$3')"/>
       <xsl:text>" does not appear to </xsl:text>
      <xsl:text>point to a ZIP package with a "content.xml" file.</xsl:text>
    </xsl:message>
  </xsl:if>
  
  <!--copy all of the files listed in the stylesheet-->
  <xsl:for-each select="document('')/*/c:files/c:file">
    <!--determine the input URI to access the file in its directory-->
    <xsl:variable name="c:ods-in-uri" 
                  select="c:ods-uri($skeleton-ods-uri,@dir,@name)"/>
    <!--process that file-->
    <xsl:choose>
      <xsl:when test="@type='copy'">
        <!--no massaging needs to be done, so simply copy the text-->
        <xsl:choose>
         <xsl:when test="not(unparsed-text-available($c:ods-in-uri))">
           <xsl:if test="not(@required='no')">
            <xsl:message terminate="yes">
              <xsl:text>Cannot open the URI to copy: </xsl:text>
              <xsl:value-of select="$c:ods-in-uri"/>
            </xsl:message>
           </xsl:if>
         </xsl:when>
         <xsl:otherwise>
           <xsl:result-document method="text" href="{$c:baseDir}{@dir}{@name}">
             <xsl:value-of select="unparsed-text($c:ods-in-uri)"/>
           </xsl:result-document>
         </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!--the file cannot go out as is and needs to be massaged-->
        <xsl:if test="not(doc-available($c:ods-in-uri))">
          <xsl:message terminate="yes">
            <xsl:text>Cannot open the URI to massage: </xsl:text>
            <xsl:value-of select="$c:ods-in-uri"/>
          </xsl:message>
        </xsl:if>
        <xsl:result-document method="xml" href="{$c:baseDir}{@dir}{@name}">
          <xsl:apply-templates select="doc($c:ods-in-uri)/*">
            <xsl:with-param name="c:modelName" tunnel="yes"
                            select="c:shorten($c:modelName)"/>
          </xsl:apply-templates>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Pruning and changing ODS content</xs:title>
</xs:doc>

<xs:template>
  <para>These ODS elements are not to be preserved.</para>
</xs:template>
<xsl:template match="office:meta | office:master-styles |
                     table:named-expressions | @table:print-ranges |
                     dc:creator | dc:date"/>

<xs:template>
  <para>Accommodate an output table</para>
</xs:template>
<xsl:template match="table:table[$c:single-output]" priority="1">
  <xsl:variable name="c:here" select="."/>
  <xsl:for-each-group select="$c:gc/*/SimpleCodeList/Row"
                      group-by="c:col(.,'ModelName')">
    <xsl:sort select="$c:common-first and
                      not(matches(c:col(.,'ModelName'),$common-name-regex))"/>
    <!--create a worksheet tab for every model; but only for those
        that are needed-->
    <xsl:if test="if( empty( $subset-model-regex ) or
                      matches( current-grouping-key(),$common-name-regex ) )
                  then true()
                  else matches( current-grouping-key(),$subset-model-regex )">
      <xsl:for-each select="$c:here">
        <xsl:call-template name="c:do-a-table">
          <xsl:with-param name="c:modelName" tunnel="yes"
                          select="c:shorten(current-grouping-key())"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:for-each-group>
</xsl:template>

<xs:template>
  <para>Accommodate an output table</para>
  <xs:param name="c:modelName">
    <para>The name of the model.</para>
  </xs:param>
</xs:template>
<xsl:template match="table:table" name="c:do-a-table">
  <xsl:param name="c:modelName" tunnel="yes" as="xsd:string" required="yes"/>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:attribute name="table:name" select="$c:modelName"/>
    <xsl:apply-templates select="* except table:table-row"/>
    <xsl:variable name="c:tableRows" select="table:table-row"/>
    <xsl:variable name="c:columnTitles"
          select="$c:tableRows[1]/table:table-cell/text:p[normalize-space(.)]/
                  replace(.,'\W','')"/>
    <!--prune title row to only those with consecutive entries with titles-->
    <xsl:for-each select="$c:tableRows[1]">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="table:table-cell[text:p[normalize-space(.)]]"/>
      </xsl:copy>
    </xsl:for-each>
    <!--add the rows of the current group-->
    <xsl:for-each select="current-group()">
      <!--only include the row if required when subsetting-->
      <xsl:if test="gu:isSubsetBIE(.)">
        <xsl:call-template name="c:createRowFromBIE">
          <xsl:with-param name="c:tableRows" select="$c:tableRows"/>
          <xsl:with-param name="c:columnTitles" select="$c:columnTitles"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
    <!--add the end row-->
    <xsl:apply-templates select="$c:tableRows[5]"/>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>The current node is a genericode row, make a table row out of it</para>
  <xs:param name="c:tableRows">
    <para>The raw rows from which a new row is created</para>
  </xs:param>
  <xs:param name="c:columnTitles">
    <para>The columns being included in the spreadsheet</para>
  </xs:param>
</xs:template>
<xsl:template name="c:createRowFromBIE">
  <xsl:param name="c:tableRows" as="element(table:table-row)*"/>
  <xsl:param name="c:columnTitles" as="xsd:string*"/>
  <xsl:variable name="c:type" select="c:col(., 'ComponentType')"/>
  <xsl:variable name="c:oldRowNumber" select="
      if ($c:type = 'BBIE') then 3 else if ($c:type = 'ASBIE') then 4 else 2"/>
  <xsl:apply-templates select="$c:tableRows[$c:oldRowNumber]"
    mode="c:modifyContent">
    <xsl:with-param name="c:columnTitles" select="$c:columnTitles"/>
    <xsl:with-param name="c:gcRow" select="."/>
    <xsl:with-param name="c:newRowNumber" select="position() + 1"
      tunnel="yes"/>
    <xsl:with-param name="c:oldRowNumber" select="$c:oldRowNumber"
      tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xs:template>
  <para>Modify the skeleton row with the content from the gcRow</para>
  <xs:param name="c:columnTitles">
    <para>The list of strings of column titles, in column order.</para>
  </xs:param>
  <xs:param name="c:gcRow">
    <para>The genericode row being output.</para>
  </xs:param>
</xs:template>
<xsl:template match="table:table-row" mode="c:modifyContent">
  <xsl:param name="c:columnTitles" as="xsd:string*"/>
  <xsl:param name="c:gcRow" as="element(Row)"/>
  <!--the current node is the skeleton ODS row-->
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:for-each select=
                     "table:table-cell[position()&lt;=count($c:columnTitles)]">
      <xsl:variable name="c:this" select="position()"/>
      <xsl:variable name="c:column" select="$c:columnTitles[$c:this]"/>
      <xsl:variable name="c:column" 
               select="if( $c:column=$c:names ) then $c:names else $c:column"/>
      <xsl:variable name="c:value" 
                    select="if( empty($c:column) )
                            then () else c:col($c:gcRow,$c:column)"/>
      <!--recreate the cell with the gc values-->
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:choose>
          <xsl:when test="$c:column='Cardinality'">
            <xsl:variable name="c:newCardinality"
               select="(normalize-space(gu:col($c:gcRow,$gu:subsetColumnName))
                                        [$gu:activeSubsetting][string(.)],
                        normalize-space(gu:col($c:gcRow,'Cardinality')))[1]"/>
            <xsl:attribute name="office:string-value"
                           select="$c:newCardinality"/>
            <text:p><xsl:value-of select="$c:newCardinality"/></text:p>
          </xsl:when>
          <xsl:when test="$c:column=$old-cardinality-column-name">
            <xsl:variable name="c:oldCardinality"
               select="normalize-space(gu:col($c:gcRow,'Cardinality'))"/>
            <xsl:attribute name="office:string-value"
                           select="$c:oldCardinality"/>
            <text:p><xsl:value-of select="$c:oldCardinality"/></text:p>
          </xsl:when>
          <xsl:when test="$c:column=$gu:subsetColumnName and
                          $gu:activeSubsetting">
            <!--the subset is no longer applicable as it is now cardinality-->
            <xsl:attribute name="office:string-value"/>
            <text:p/>
          </xsl:when>
          <xsl:when test="empty($c:value)">
            <!--there is no genericode, so the cell is blank-->
            <xsl:attribute name="office:string-value"/>
            <text:p/>
          </xsl:when>
          <xsl:when test="@office:string-value | @table:formula">
            <!--this must be a calculation, so store the string value-->
            <xsl:attribute name="office:string-value" select="$c:value"/>
            <!--a formula's text value preserves newlines as line breaks-->
            <text:p>
              <xsl:analyze-string select="$c:value" regex="$c:newline">
                <xsl:matching-substring>
                  <text:line-break/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:copy-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </text:p>
          </xsl:when>
          <xsl:otherwise>
            <!--a non-formula's text value preserves newlines as multiples-->
            <xsl:analyze-string select="$c:value" regex="$c:newline">
              <xsl:non-matching-substring>
                <text:p><xsl:copy-of select="."/></text:p>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    Massage a table formula based on the current row number.
  </para>
  <xs:param name="c:oldRowNumber">
    <para>The row being matched.</para>
  </xs:param>
  <xs:param name="c:newRowNumber">
    <para>The row being generated.</para>
  </xs:param>
</xs:template>
<xsl:template match="@table:formula">
  <xsl:param name="c:oldRowNumber" as="xsd:integer" tunnel="yes"/>
  <xsl:param name="c:newRowNumber" as="xsd:integer" tunnel="yes"/>
  <xsl:attribute name="table:formula">
    <xsl:analyze-string select="." regex="(\w+){$c:oldRowNumber}">
      <xsl:matching-substring>
        <xsl:value-of select="concat(regex-group(1),$c:newRowNumber)"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:copy-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:attribute>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Pruning and changing ODS settings</xs:title>
</xs:doc>

<xs:template>
  <para>
    Create as many map entries as there are tables.
  </para>
</xs:template>
<xsl:template match="config:config-item-map-entry[$c:single-output]">
  <xsl:variable name="c:thisElement" select="."/>
  <xsl:for-each
           select="distinct-values($c:gc/*/SimpleCodeList/Row/
                                   Value[@ColumnRef='ModelName']/SimpleValue)">
    <xsl:sort select="$c:common-first and
                      not(matches(.,$common-name-regex))"/>
    <xsl:variable name="c:thisModel" select="."/>
    <xsl:if test="if( empty( $subset-model-regex ) or
                      matches( .,$common-name-regex ) )
                  then true()
                  else matches( .,$subset-model-regex )">
      <xsl:for-each select="$c:thisElement">
        <xsl:copy>
          <xsl:apply-templates select="@*,node()">
          <xsl:with-param name="c:modelName" tunnel="yes" 
                          select="c:shorten($c:thisModel)"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:for-each>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xs:template>
  <para>Reflect the name of the table in the configuration</para>
  <xs:param name="c:modelName">
    <para>The name of the model.</para>
  </xs:param>
</xs:template>
<xsl:template match="config:config-item-map-entry/@config:name">
  <xsl:param name="c:modelName" tunnel="yes" as="xsd:string" required="yes"/>
  <xsl:attribute name="config:name" select="$c:modelName"/>
</xsl:template>

<xs:template>
  <para>Reflect the name of the table as active</para>
  <xs:param name="c:modelName">
    <para>The name of the model.</para>
  </xs:param>
</xs:template>
<xsl:template match="config:config-item[@config:name='ActiveTable']/text()">
  <xsl:param name="c:modelName" tunnel="yes" as="xsd:string" required="yes"/>
  <xsl:value-of select="$c:modelName"/>
</xsl:template>

<xs:template>
  <para>Elide any personal content.</para>
</xs:template>
<xsl:template match="config:config-item-set
                     [@config:name='ooo:configuration-settings']">
  <!--suppress Ken's environment-->
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Preserving content</xs:title>
</xs:doc>

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
  <xs:title>Utility</xs:title>
</xs:doc>

<xs:function>
  <para>Apply, in order, regular expressions on a string.</para>
  <xs:param name="c:value">
    <para>The value to be massaged.</para>
  </xs:param>
</xs:function>
<xsl:function name="c:shorten" as="xsd:string?">
  <xsl:param name="c:value" as="xsd:string?"/>
<xsl:sequence select="if( exists($c:value) ) 
       then c:shorten($c:value,$c:shorten-model-name-file/*/pass[1]) else ()"/>
</xsl:function>

<xs:function>
  <para>Apply, in order, regular expressions on a string.</para>
  <xs:param name="c:value">
    <para>The value to be massaged.</para>
  </xs:param>
  <xs:param name="c:pass">
    <para>A pass of the conversion</para>
  </xs:param>
</xs:function>
<xsl:function name="c:shorten" as="xsd:string?">
  <xsl:param name="c:value" as="xsd:string?"/>
  <xsl:param name="c:pass" as="element(pass)?"/>
  <xsl:sequence select="if( exists($c:pass) ) then c:shorten( 
          replace( $c:value, $c:pass/shorten/@find, $c:pass/shorten/@replace ),
                                           $c:pass/following-sibling::pass[1] )
                                              else $c:value"/>
</xsl:function>

</xsl:stylesheet>
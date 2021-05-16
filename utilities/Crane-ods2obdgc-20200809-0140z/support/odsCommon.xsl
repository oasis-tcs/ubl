<?xml version="1.0" encoding="US-ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:o="urn:X-Crane:stylesheets:odf-access"
  exclude-result-prefixes="xs xsd o"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  version="2.0">

<xs:doc info="$Id: odsCommon.xsl,v 1.20 2020/08/09 01:36:01 admin Exp $"
        filename="odsCommon.xsl" vocabulary="DocBook">
  <xs:title>Common support ODF access by Crane styesheets</xs:title>
  <para>
    This is a collection of facilities for accessing OpenOffice document files
    from XSLT stylesheets.  There is no knowledge of the target non-ODF
    vocabularies in this module.
  </para>
<!--
Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/train.htm

Redistribution in source or binary forms in any way is strictly prohibited.

There is no charge for the purchase of this code but this use of this code is
restricted to bona-fide users of Crane Softwrights Ltd. books as dictated by
the stylesheet fragment that includes this fragment.

THE AUTHOR MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS CODE FOR ANY
PURPOSE. THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR 
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN 
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->
</xs:doc>

<!--========================================================================-->
<xs:doc>
  <xs:title>ODS file access</xs:title>
</xs:doc>

<!-- Removed for multiple file access; will need recoding in old modules
<xs:variable>
  <para>
    When input is ODS, use the input, otherwise use the template.
  </para>
</xs:variable>
<xsl:variable name="o:ods" 
              select="if( exists( $o:odsOverride ) ) then $o:odsOverride
                      else if( /office:document ) then (/) else $odsTemplate"
              as="document-node()"/>
-->

<xs:function>
  <para>
    All of the tables in the ODS document
  </para>
  <xs:param name="o:odsRoot">
    <para>The root of the ODS tree</para>
  </xs:param>
</xs:function>
<xsl:function name="o:odsTables" as="element(table:table)*">
  <xsl:param name="o:odsRoot" as="element()"/>
  <xsl:sequence
             select="$o:odsRoot/*/office:body/office:spreadsheet/table:table"/>
</xsl:function>

<xs:key>
  <para>A look-up of style names for all styles styles</para>
</xs:key>
<xsl:key name="o:styles" match="style:style" use="@style:name"/>

<xs:function>
  <para>
    Walk up the style tree finding the closest hieararchical Crane style 
    the given style is considered.  Returns closest Crane name as a string.
  </para>
  <xs:param name="o:style">
    <para>The style used in the stylesheet.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:craneStyle" as="xsd:string">
  <xsl:param name="o:style" as="attribute()*"/>
  <xsl:sequence select="if( not( $o:style ) ) then ''
                     else if( starts-with($o:style,'Crane') ) then $o:style
                     else o:craneStyle(key('o:styles',$o:style,root($o:style))/
                                       @style:parent-style-name)"/>
</xsl:function>

<xs:key>
  <para>A table of all "labeled" table cells in the ODS instance</para>
  <para>
    It is assumed that there is exactly one table:table-cell between the
    cell with the label and the cell with the information.
  </para>
  <para>
    Intuitively you would think we could just label the actual cell itself,
    but most of the cells we need have some conditional formatting applied
    to the cell to decorate the background.  Conditional formatting is ignored
    when there is a style directly applied to the cell.
  </para>
</xs:key>
<xsl:key name="o:labeledCells" 
         match="table:table-cell[
     o:craneStyle(preceding-sibling::table:table-cell[2]/@table:style-name)]"
use="substring-after(
     o:craneStyle(preceding-sibling::table:table-cell[2]/@table:style-name),
     'CraneLabel')"/>

<xs:key>
  <para>
    A copy of the "labeled" cells, but with a fixed lookup value for
    diagnostic purposes.
  </para>
</xs:key>
<xsl:key name="o:labeledCellsDebug" 
         match="table:table-cell[
     o:craneStyle(preceding-sibling::table:table-cell[2]/@table:style-name)]"
         use="1"/>

<xs:key>
  <para>A table of all "Crane styled" table cells in the ODS instance</para>
</xs:key>
<xsl:key name="o:craneStyledCells" 
         match="table:table-cell[o:craneStyle(@table:style-name)]"
         use="o:craneStyle(@table:style-name)"/>

<!--commented out to use only labelled cell
<xs:function>
  <para>Obtain given Crane labeled cell from entire table</para>
  <xs:param name="o:labelSuffix">
    <para>The suffix to "CraneLabel" of the cell being obtained</para>
  </xs:param>
</xs:function>
<xsl:function name="o:labeledCell" as="node()?">
  <xsl:param name="o:labelSuffix" as="xsd:string"/>
  <xsl:sequence select="o:labeledCell($o:labelSuffix,$o: ods)"/>
</xsl:function>
-->

<xs:function>
  <para>Obtain given Crane labeled cell below given point in table.</para>
  <xs:param name="o:labelSuffix">
    <para>The suffix to "CraneLabel" of the cell being obtained</para>
  </xs:param>
  <xs:param name="o:tableTopNode">
    <para>The point under which the item is found</para>
  </xs:param>
</xs:function>
<xsl:function name="o:labeledCell" as="node()?">
  <xsl:param name="o:labelSuffix" as="xsd:string"/>
  <xsl:param name="o:tableTopNode" as="node()"/>
  <xsl:sequence select="key('o:labeledCells',$o:labelSuffix,$o:tableTopNode)"/>
</xsl:function>

<xs:function>
  <para>Get the text value of the table cell current node.</para>
  <xs:param name="o:cell">
    <para>Which cell is needed?</para>
  </xs:param>
</xs:function>
<xsl:function name="o:odsCell2Text" as="xsd:string?">
  <xsl:param name="o:cell" as="element(table:table-cell)?"/>
  <xsl:sequence select="string-join($o:cell/text:p/string(.),'&#xa;')"/>
</xsl:function>

<xs:function>
  <para>Get the text value of the table cell current node.</para>
  <xs:param name="o:row">
    <para>Which row?</para>
  </xs:param>
  <xs:param name="o:column">
    <para>Which column is needed?</para>
  </xs:param>
</xs:function>
<xsl:function name="o:odsColumn2Text" as="xsd:string?">
  <xsl:param name="o:row" as="element(table:table-row)"/>
  <xsl:param name="o:column" as="xsd:decimal"/>
  <xsl:for-each select="$o:row/(table:table-cell|table:covered-table-cell)
                               [o:column(.) = $o:column]">
    <xsl:choose>
      <xsl:when test="self::table:covered-table-cell">
        <!--the value is spanned rows from above-->
        <xsl:sequence select="
    o:odsColumn2Text($o:row/preceding-sibling::table:table-row[1],$o:column)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="o:odsCell2Text(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:function>

<xs:template>
  <para>Set the text value of the table cell current node.</para>
</xs:template>
<xsl:template name="o:text2odsCellContent">
  <xsl:analyze-string select="." regex=".+">
    <xsl:matching-substring>
      <text:p><xsl:value-of select="."/></text:p>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Serializing XML to text</xs:title>
</xs:doc>

<xs:template>
  <para>
    For any given ODS table cell, if there is a genericode item for the cell,
    the replace it preserving XML syntax ... otherwise preserve the cell.
  </para>
  <xs:param name="o:item">
    <para>Item whose value replaces that which is in the cell</para>
  </xs:param>
  <xs:param name="o:noAttributes">
    <para>Skip the preservation of attributes in the copied item</para>
  </xs:param>
  <xs:param name="o:noPreserve">
    <para>Skip the preservation of the value if no value supplied.</para>
  </xs:param>
</xs:template>
<xsl:template name="o:XML2odsCell">
  <xsl:param name="o:item" as="document-node()" required="yes"/>
  <xsl:param name="o:noAttributes" tunnel="yes" as="xsd:boolean" 
             select="false()"/>
  <xsl:param name="o:noPreserve" tunnel="yes" as="xsd:boolean"
             select="false()"/>
  <!--preserve the ODS cell-->
  <xsl:copy>
    <xsl:if test="not($o:noAttributes)">
      <!--preserve any attributes-->
      <xsl:apply-templates select="@*"/>
    </xsl:if>
    <!--replace or preserve content-->
    <xsl:choose>
      <!--explicitly supplied parent value-->
      <xsl:when test="$o:item">
        <!--serialize into a text node under a document node-->
        <xsl:variable name="o:local-node" as="document-node()">
          <xsl:document>
            <xsl:apply-templates select="$o:item/node()" 
                                 mode="o:XML2odsCell"/>
          </xsl:document>
        </xsl:variable>
        <!--add the text-->
        <xsl:for-each select="$o:local-node">
          <xsl:call-template name="o:text2odsCellContent"/>
        </xsl:for-each>
      </xsl:when>
      <!--explicit no preservation-->
      <xsl:when test="$o:noPreserve">
        <!--add nothing because old contents are not to be preserved-->
      </xsl:when>
      <!--preserve the content of the cell-->
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>Set the XML text file of the table cell current node.</para>
  <para>
    Note that it is impossible to know what literal delimeters are being used
    for attributes, so this code assumes double quotes are being used.
  </para>
  <xs:param name="o:ignoredNamespaceURIs">
    <para>
      Which namespace URI strings are covered off by other declarations?
    </para>
  </xs:param>
</xs:template>
<xsl:template mode="o:XML2odsCell" match="*">
  <xsl:param name="o:ignoredNamespaceURIs" tunnel="yes" as="xsd:string*" 
             select="()"/>
  <xsl:text/>&lt;<xsl:value-of select="name(.)"/>
  <xsl:for-each select="namespace::*[not(.=
                                (../namespace::xml,$o:ignoredNamespaceURIs))]">
    <xsl:if test="not(name(.)=../../namespace::*/name(.))">
      <xsl:value-of select="concat(' xmlns',if(name()) then ':' else '',
                                   name(.),'=&#34;',.,'&#34;')"/>
    </xsl:if>
  </xsl:for-each>
  <xsl:for-each select="@*">
    <xsl:choose>
      <xsl:when test="contains(.,'&#34;')">
        <!--the value has a quote, so use apostrophes-->
        <xsl:value-of select='concat(" ",name(.),"=&#39;",.,"&#39;")'/>
      </xsl:when>
      <xsl:otherwise>
        <!--the value doesn't have a quote, so use quotes-->
        <xsl:value-of select="concat(' ',name(.),'=&#34;',.,'&#34;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  <xsl:choose>
    <xsl:when test="node()">
      <xsl:text>></xsl:text>
      <xsl:apply-templates mode="o:XML2odsCell" select="node()"/>
      <xsl:text/>&lt;/<xsl:value-of select="name(.)"/>><xsl:text/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>/></xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:template>
  <para>Set the XML text file of the table cell current node.</para>
</xs:template>
<xsl:template mode="o:XML2odsCell" match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<xs:template>
  <para>Set the XML text file of the table cell current node.</para>
</xs:template>
<xsl:template mode="o:XML2odsCell" match="comment()">
  <xsl:value-of select="concat('&lt;!--',.,'-->')"/>
</xsl:template>

<xs:template>
  <para>Set the XML text file of the table cell current node.</para>
</xs:template>
<xsl:template mode="o:XML2odsCell" match="processing-instruction()">
  <xsl:value-of select="concat('&lt;?',name(.),' ',.,'?>')"/>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Identity-related processes</xs:title>
</xs:doc>

<xs:template>
  <para>
    The identity template is used to copy all nodes not already being handled
    by other template rules.
  </para>
  <para>
    Note there are two modes here: the default mode handles most of the
    nodes in the entire document; the o:skipCurrentMatch mode will copy the
    current node only and then switches to the default mode.  This allows
    a matched node not to be re-matched but just simply copied.
  </para>
</xs:template>
<xsl:template match="@*|node()" mode="#default o:skipCurrentMatch">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="#default"/>
  </xsl:copy>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Miscellaneous</xs:title>
</xs:doc>

<xs:function>
  <para>Sort the supplied set of atomic items.</para>
  <xs:param name="o:items">
    <para>The items to be sorted</para>
  </xs:param>
</xs:function>
<xsl:function name="o:sort" as="xsd:anyAtomicType*">
  <xsl:param name="o:items" as="xsd:anyAtomicType*"/>
  <xsl:perform-sort select="$o:items">
    <xsl:sort/>
  </xsl:perform-sort>
</xsl:function>

<xs:function>
  <para>Sort the supplied set of nodes.</para>
  <xs:param name="o:nodes">
    <para>The nodes to be sorted</para>
  </xs:param>
</xs:function>
<xsl:function name="o:sortNodes" as="node()*">
  <xsl:param name="o:nodes" as="node()*"/>
  <xsl:perform-sort select="$o:nodes">
    <xsl:sort/>
  </xsl:perform-sort>
</xsl:function>

<xs:function>
  <para>
    Return the sequence of 1-origin column numbers corresponding to the
    given table-cell, covered-table-cell, or table-column.
  </para>
  <para>
    This will return a runtime error if the node passed is neither a
    table-cell nor a table-column.
  </para>
  <xs:param name="o:cell">
    <para>The table cell being counted within it's row.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:column" as="xsd:integer*">
  <xsl:param name="o:cell" as="node()"/>
  <xsl:for-each select="$o:cell[self::table:covered-table-cell]">
    <xsl:variable name="o:prevCells"
                  select="preceding-sibling::table:table-cell"/>
    <xsl:variable name="o:prevRowSpans"
                  select="preceding-sibling::table:covered-table-cell
                                                       [exists(o:column(.))]"/>
    <xsl:variable name="o:start"
                  select="1
                    + count($o:prevCells)
                    + sum(  $o:prevCells/@table:number-columns-repeated )
                    - count($o:prevCells[@table:number-columns-repeated])
                    + count($o:prevRowSpans)
                    + sum(  $o:prevRowSpans/@table:number-columns-repeated )
                    - count($o:prevRowSpans[@table:number-columns-repeated])"/>
    <xsl:choose>
      <xsl:when test="$o:prevCells[last()]/o:column(.) = $o:start">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="xsd:integer($o:start) to 
                              xsd:integer($o:start - 1  +
                                      (@table:number-columns-repeated,1)[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  <xsl:for-each select="$o:cell[self::table:table-cell]">
    <xsl:variable name="o:prevCells"
                  select="preceding-sibling::table:table-cell"/>
    <xsl:variable name="o:prevRowSpans"
                  select="preceding-sibling::table:covered-table-cell
                                                       [exists(o:column(.))]"/>
    <xsl:variable name="o:start"
                  select="count($o:prevCells) + 1
      + sum($o:prevCells/@table:number-columns-spanned)
      + sum($o:prevCells/@table:number-columns-repeated)
      + sum($o:prevRowSpans/(xsd:integer(@table:number-columns-repeated),1)[1])
      - count($o:prevCells[@table:number-columns-spanned])
      - count($o:prevCells[@table:number-columns-repeated])"/>
    <xsl:sequence select="xsd:integer($o:start) to 
                          xsd:integer( $o:start - 1  +
                                  (@table:number-columns-spanned,1)[1] +
                                  (@table:number-columns-repeated,1)[1] - 1)"/>
  </xsl:for-each>
  <xsl:for-each select="$o:cell[self::table:table-column]">
    <xsl:variable name="start"
                  select="count(preceding-sibling::table:table-column) + 1 +
  sum(preceding-sibling::table:table-column/@table:number-columns-repeated) -
count(preceding-sibling::table:table-column[@table:number-columns-repeated])"/>
    <xsl:sequence select="xsd:integer($start) to xsd:integer( $start - 1 + 
     ( if( @table:number-columns-repeated ) then @table:number-columns-repeated
                                            else 1 ) )"/>
  </xsl:for-each>
</xsl:function>

<xs:function>
  <para>
    Return the sequence of 1-origin row numbers corresponding to the
    given table-row.
  </para>
  <xs:param name="o:row">
    <para>The table row being counted within it's table.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:row" as="xsd:double+">
  <xsl:param name="o:row" as="element(table:table-row)"/>
  <xsl:for-each select="$o:row">
    <xsl:variable name="start"
                  select="count(preceding-sibling::table:table-row) + 1 +
  sum(preceding-sibling::table:table-row/@table:number-rows-repeated) -
  count(preceding-sibling::table:table-row[@table:number-rows-repeated])"/>
    <xsl:sequence select="xsd:integer($start) to xsd:integer( $start - 1 + 
     ( if( @table:number-rows-repeated ) then @table:number-rows-repeated
                                            else 1 ) )"/>
  </xsl:for-each>
</xsl:function>

<xs:template>
  <para>
    For the current ODS table cell, if there is a non-empty text item for the
    cell, then replace it with a simple text value ... otherwise preserve it.
  </para>
  <xs:param name="o:item">
    <para>Item whose value replaces that which is in the cell</para>
  </xs:param>
  <xs:param name="o:noAttributes">
    <para>Skip the preservation of attributes in the copied item</para>
  </xs:param>
  <xs:param name="o:noPreserve">
    <para>Skip the preservation of the value if no value supplied.</para>
  </xs:param>
</xs:template>
<xsl:template name="o:text2odsCell" 
              mode="o:text2odsCell" match="table:table-cell">
  <xsl:param name="o:item" as="node()?" required="yes"/>
  <xsl:param name="o:noAttributes" tunnel="yes" as="xsd:boolean" 
             select="false()"/>
  <xsl:param name="o:noPreserve" tunnel="yes" as="xsd:boolean"
             select="false()"/>
  <!--preserve the ODS cell-->
  <xsl:copy>
    <xsl:if test="not($o:noAttributes)">
      <!--preserve any attributes-->
      <xsl:apply-templates select="@*"/>
    </xsl:if>
    <!--replace or preserve content-->
    <xsl:choose>
      <!--explicitly supplied value-->
      <xsl:when test="string($o:item)">
        <!--check to preserve non-text children-->
        <xsl:if test="not($o:noPreserve)">
          <xsl:apply-templates select="* except text:*"/>
        </xsl:if>
        <!--provide content in place of any text:*, even if none-->
        <xsl:for-each select="$o:item">
          <xsl:call-template name="o:text2odsCellContent"/>
        </xsl:for-each>
      </xsl:when>
      <!--explicit no preservation-->
      <xsl:when test="$o:noPreserve">
        <!--add nothing because old contents are not to be preserved-->
      </xsl:when>
      <!--preserve the content of the cell-->
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<!--========================================================================-->

<xs:doc>
  <xs:title>Column letter representation</xs:title>
  <para>
    This algorithm was sketched out in Python and then translated to XSLT.
  </para>
<programlisting>
from string import atoi, find
from sys import exit

letters="_ABCDEFGHIJKLMNOPQRSTUVWXYZ"

def alpha2num( alpha ):
    alpha = "___"+alpha
    alpha = alpha[-3:]
    return find( letters, alpha[0:1] ) * 26*26 +\
           find( letters, alpha[1:2] ) * 26 +\
           find( letters, alpha[2:3] )

def num2alpha( num ):
    first = int( ( num - 1 ) / ( 27*26 ) )
    result = letters[ first ]
    result += letters[ int( ( ( num - 1 + ( first * 26 )) % ( 27 * 26 ) ) / 26 ) ]
    result += letters[ ( num - 1 ) % 26 + 1 ]
    return result

for each in range (1, 1025):
    alpha = num2alpha( each )
    this = alpha2num( alpha )
    print "%d=%s=%d" % (each,alpha,this ),
    if each != this:
       print "Problem!"
       exit(1)

for each in range (1, 1025):
    alpha = num2alpha ( each )
    if "_" in alpha: print alpha,
</programlisting>
</xs:doc>

<xs:function>
  <para>Translate a column alpha to a column number.</para>
  <xs:param name="o:alpha">
    <para>Up to three characters of a column alpha indicator.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:columnAlpha2Numeric" as="xsd:integer">
  <xsl:param name="o:alpha" as="xsd:string"/>
  <xsl:analyze-string select="$o:alpha" 
                      regex="\s*(([A-Z])?([A-Z]))?([A-Z])\s*">
    <xsl:matching-substring>
      <xsl:sequence select="o:alpha2ordinal(regex-group(2))*26*26 +
                            o:alpha2ordinal(regex-group(3))*26 +
                            o:alpha2ordinal(regex-group(4))"/>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<xs:function>
  <para>Translate a column letter to an ordinal number.</para>
  <xs:param name="o:alpha">
    <para>Nothing or a single letter.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:alpha2ordinal" as="xsd:integer">
  <xsl:param name="o:alpha" as="xsd:string"/>
  <xsl:sequence select="if($o:alpha='') then 0 
         else string-to-codepoints($o:alpha) - string-to-codepoints('A') + 1"/>
</xsl:function>

<xs:function>
  <para>Translate a column number to a column alpha.</para>
  <xs:param name="o:numeric">
    <para>An integer to be converted into a column number.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:columnNumeric2Alpha" as="xsd:string">
  <xsl:param name="o:numeric" as="xsd:integer"/>
  <xsl:variable name="o:first" select="( $o:numeric - 1 ) idiv (27*26)"/>
  <xsl:variable name="o:second" 
                select="(($o:numeric - 1 + $o:first*26) mod (27*26) idiv 26)"/>
  <xsl:variable name="o:third" select="( $o:numeric - 1 ) mod 26 + 1 "/>
  <xsl:sequence 
      select="concat( o:ordinal2alpha( $o:first ),
                      o:ordinal2alpha( $o:second ),
                      o:ordinal2alpha( $o:third ) )"/>
</xsl:function>

<xs:function>
  <para>Translate an ordinal number to a column letter</para>
  <xs:param name="o:ordinal">
    <para>The digit between 0 and 26, where zero is suppressed</para>
  </xs:param>
</xs:function>
<xsl:function name="o:ordinal2alpha" as="xsd:string">
  <xsl:param name="o:ordinal" as="xsd:integer"/>
  <xsl:sequence select="if($o:ordinal=0) then ''
     else codepoints-to-string( $o:ordinal + string-to-codepoints('A') - 1 )"/>
</xsl:function>

<xs:template>
  <para>Regression test for alpha to numeric</para>
</xs:template>
<xsl:template name="o:testAlpha2Numeric">
    <xsl:for-each select="1 to 1024">
      <xsl:variable name="o:this" select="."/>
      <xsl:variable name="o:alpha" select="o:columnNumeric2Alpha($o:this)"/>
      <xsl:variable name="o:that" select="o:columnAlpha2Numeric($o:alpha)"/>
      <xsl:message select="concat( $o:this,'=',$o:alpha,'=',$o:that )"/>
      <xsl:if test="$o:this != $o:that">
        <xsl:message terminate="yes" select="'o:Problem'"/>
      </xsl:if>
    </xsl:for-each>
</xsl:template>

<xs:function>
  <para>
    Translate any row/column position by augmenting row and column numbers
  </para>
  <xs:param name="o:formula">
    <para>The formula text to be translated.</para>
  </xs:param>
  <xs:param name="o:columnOffset">
    <para>The offset amount to be added to the column.</para>
  </xs:param>
  <xs:param name="o:rowOffset">
    <para>The offset amount to be added to the row.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:translateFormula" as="text()*">
  <xsl:param name="o:formula" as="xsd:anyAtomicType?"/>
  <xsl:param name="o:columnOffset" as="xsd:integer"/>
  <xsl:param name="o:rowOffset" as="xsd:integer"/>
  <xsl:analyze-string select="$o:formula" regex="(\$?)([A-Z])+(\$?)(\d+)">
    <xsl:matching-substring>
      <!--using the render column position, calculate column using 
          given as the base-->
      <xsl:value-of select="concat(regex-group(1),
o:columnNumeric2Alpha(o:columnAlpha2Numeric(regex-group(2)) + $o:columnOffset),
                                   regex-group(3),
                                xsd:integer(regex-group(4)) + $o:rowOffset )"/>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:value-of select="."/>
    </xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:function>

<xs:function>
  <para>Return the fully-qualified address of the current table cell.</para>
  <xs:param name="o:cell">
    <para>The table cell being asked about.</para>
  </xs:param>
</xs:function>
<xsl:function name="o:address" as="xsd:string">
  <xsl:param name="o:cell" as="element(table:table-cell)"/>
  <xsl:for-each select="$o:cell">
    <xsl:sequence select="concat(ancestor::table:table[1]/@table:name,'.',
                               o:columnNumeric2Alpha(xsd:integer(o:column(.))),
                                 o:row(..))"/>
  </xsl:for-each>
</xsl:function>

</xsl:stylesheet>
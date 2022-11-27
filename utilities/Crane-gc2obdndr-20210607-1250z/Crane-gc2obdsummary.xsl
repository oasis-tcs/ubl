<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#xa0;">]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs gu xsd"
                version="2.0">

<xs:doc info="$Id: Crane-gc2obdsummary.xsl,v 1.38 2020/04/11 01:45:39 admin Exp $"
      filename="Crane-gc2obdsummary.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Translating genericode to CCTS HTML summary reports</xs:title>
  <para>
    Create multiple HTML summary reports from a genericode expression of the
    document model.
  </para>
  <section>
    <title>Copyright and disclaimer</title>
<programlisting>Copyright (C) - Crane Softwrights Ltd.
              - <ulink url="http://www.CraneSoftwrights.com/links/res-dev.htm">http://www.CraneSoftwrights.com/links/res-dev.htm</ulink>

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
      was obtained 2003-07-26 at <ulink
url="http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5">http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5</ulink>

THE AUTHOR MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS CODE FOR ANY
PURPOSE.</programlisting>
    </section>
</xs:doc>

<xsl:include href="support/ndrSubset.xsl"/>
<xsl:include href="support/udt4html.xsl"/>
<xsl:include href="support/Crane-commonndr.xsl"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Invocation parameters</xs:title>
</xs:doc>

<xs:param ignore-ns="yes">
  <para>How to prefix the title of the summary report</para>
</xs:param>
<xsl:param name="title-prefix" as="xsd:string" required="yes"/>

<xs:param ignore-ns="yes">
  <para>Whose copyright is on the summary report</para>
</xs:param>
<xsl:param name="copyright-text" as="xsd:string" required="yes"/>

<xs:param ignore-ns="yes">
  <para>The base name of the summary report HTML.</para>
</xs:param>
<xsl:param name="all-documents-base-name" select="'AllDocuments'"/>

<xs:param ignore-ns="yes">
  <para>The desire to save time with only the "all" model.</para>
</xs:param>
<xsl:param name="do-all-only" select="'no'"/>

<xs:variable>
  <para>The desire to save time with only the "all" model.</para>
</xs:variable>
<xsl:variable name="gu:doAllOnly" as="xsd:boolean"
              select="starts-with('yes',lower-case($do-all-only))"/>

<xs:param ignore-ns="yes">
  <para>The relative URI to the summary report for the base model.</para>
</xs:param>
<xsl:param name="base-summary-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The report order for the ABIEs.</para>
</xs:param>
<xsl:param name="ABIE-sort-column-name" as="xsd:string?"/>

<xs:variable>
  <para>The report order for the ABIEs compressed.</para>
</xs:variable>
<xsl:variable name="gu:ABIEsortColumnName" as="xsd:string?"
           select="translate(normalize-space($ABIE-sort-column-name),' ','')"/>

<xs:param ignore-ns="yes">
  <para>
    An indication that a report is generated for compatibility with the
    anchor pattern used in UBL 2.1-era reports.
  </para>
</xs:param>
<xsl:param name="heritage-external-html" select="'no'"/>

<xs:variable>
  <para>The delimiter to use in table URI strings</para>
</xs:variable>
<xsl:variable name="gu:extDelimit" as="xsd:string"
           select="if( starts-with('yes',lower-case($heritage-external-html)) )
                   then '_' else '-'"/>

<xs:param ignore-ns="yes">
  <para>Which models to report on?</para>
</xs:param>
<xsl:param name="date-time" as="xsd:string"
           select="format-dateTime(
                      adjust-dateTime-to-timezone(current-dateTime(),
                                                  xsd:dayTimeDuration('PT0H')),
                      '[Y0001]-[M01]-[D01] [H01]:[m01]z')"/>

<xs:param ignore-ns="yes">
  <para>
    Parallel execution support - maximum number of parallel processes
  </para>
</xs:param>
<xsl:param name="parallel-group-count" as="xsd:integer" select="0"/>

<xs:param ignore-ns="yes">
  <para>
    Parallel execution support - indication of which of the available
    processes this particular run is part of.
  </para>
</xs:param>
<xsl:param name="parallel-group-index" as="xsd:integer" select="0"/>

<xs:variable>
  <para>Parallel group number, or 0 for all</para>
</xs:variable>
<xsl:variable name="gu:parallelGroup" as="xsd:integer"
    select="if( not( $parallel-group-index=(1 to $parallel-group-count) ) )
            then 0 else $parallel-group-index"/>

<xs:output>
  <para>Indent the output assuming humans will be reading this.</para>
</xs:output>
<xsl:output indent="yes" method="html"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Overall stylesheet flow</xs:title>
</xs:doc>

<xs:template>
  <para>
    Create HTML reports, one for all and one for each.
  </para>
</xs:template>

<xsl:template match="/">
  <!--check combination of arguments-->
  <xsl:if test="($base-summary-uri!='') != exists($gu:gcOther)">
    <xsl:message terminate="yes">
      <xsl:choose>
        <xsl:when test="empty($base-summary-uri)">
          <!--gcOther must have been specified-->
          <xsl:text>The base uri for the summary report must be </xsl:text>
          <xsl:text>specified when specifying the genericode file.</xsl:text>
        </xsl:when>
        <xsl:when test="empty($base-gc-uri)">
          <xsl:text>The base uri for the genericode file must be </xsl:text>
          <xsl:text>specified when specifying the summary file.</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>The given base uri for the genericode file does </xsl:text>
          <xsl:text>not resolve to an genericode file.</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:message>
  </xsl:if>
  <!--one amalgam report for all-->
  <xsl:if test="( count($gu:subsetDocumentABIEs)>1 or $gu:doAllOnly ) and
                $gu:parallelGroup=(0,$parallel-group-count)">
    <xsl:call-template name="gu:createSummaryReport"/>
  </xsl:if>
  <!--one individual report for each-->
  <xsl:for-each select="$gu:subsetDocumentABIEs[not($gu:doAllOnly)]
                        [$gu:parallelGroup = (0, (( (position()-1) idiv 
    ((last() + $parallel-group-count -1) idiv $parallel-group-count )) + 1))]">
    <xsl:call-template name="gu:createSummaryReport">
      <xsl:with-param name="gu:modelDocumentABIE" select="."/>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xs:template>
  <para>Create output for one or many models.</para>
  <xs:param name="gu:modelDocumentABIE">
    <para>The model to report on</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:createSummaryReport">
  <xsl:param name="gu:modelDocumentABIE" as="element(Row)?"/>

  <xsl:variable name="gu:thisModelNames" as="element(SimpleValue)*"
                select="if( $gu:modelDocumentABIE ) 
                        then $gu:modelDocumentABIE/gu:col(.,'ModelName')
                        else $gu:subsetDocumentABIEmodelNames"/>
  <xsl:variable name="gu:thisLibraryABIEs"
                select="if( $gu:modelDocumentABIE )
                        then gu:determineSubsetABIEs($gu:modelDocumentABIE)
                        else $gu:subsetLibraryABIEs"/>
  <xsl:variable name="gu:thisSubsetABIEs" 
        select="( if( $gu:modelDocumentABIE ) then $gu:modelDocumentABIE
                                              else $gu:subsetDocumentABIEs ) | 
                $gu:thisLibraryABIEs"/>
  <xsl:variable name="gu:thisSubsetBIEs"
                select="($gu:thisLibraryABIEs | $gu:thisSubsetABIEs)/
                        (.,
                        key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'))
                        [gu:isSubsetBIE(.)])"/>
  <xsl:variable name="gu:outfile" as="xsd:string"
                select="( $gu:modelDocumentABIE/gu:col(.,'ModelName'), 
                          $all-documents-base-name )[1]"/>
  <xsl:message select="concat( if( $gu:parallelGroup = 0 ) then '' else
       concat( '[',format-number($gu:parallelGroup,'00'),'] ' ),
       'Creating ',$gu:outfile,'.html',' ...')"/>
  <xsl:variable name="gu:title"
                select="$title-prefix,'-',$gu:outfile"/>
  
  <xsl:result-document href="{concat($gu:outfile,'.html')}">
    <html>
      <head>
        <title><xsl:value-of select="$gu:title"/></title>
        <style type="text/css">
.iT, .iR, .iC
{
  font-size:small;border:1px solid black; border-collapse:collapse;
  vertical-align:top;
}
.sC
{
  vertical-align:baseline;
}
.uT
{
  font-size:small;
}
        </style>
      </head>
      <body>
        <h2><xsl:value-of select="$gu:title"/></h2>
        <xsl:call-template name="gu:HTMLcopyright"/>
        
<p>
  <xsl:text>Index for all items: </xsl:text>
  <xsl:for-each-group select="$gu:thisSubsetBIEs"
           group-by="upper-case(substring(gu:col(.,$gu:names),1,3))">
   <xsl:sort select="upper-case(substring(gu:col(.,$gu:names),1,3))"
             lang="en"/>
    <a href="#Index_{current-grouping-key()}">
      <xsl:value-of select="current-grouping-key()"/>
    </a>
    <xsl:text> </xsl:text>
  </xsl:for-each-group>
  <!--also include the tables-->
  <xsl:for-each select="$gu:thisModelNames/../../gu:col(.,'ModelName'),
                        $gu:thisCommonLibraryModel">
    <xsl:sort select=".=$gu:thisCommonLibraryModel"/>
    <xsl:sort select="."/>
    <a href="#Table-{.}"><xsl:value-of select="."/></a>
    <xsl:text> </xsl:text>
  </xsl:for-each>
  <a href="#UDT">Unqualified Data Types</a>
  <xsl:text> </xsl:text>
  <a href="#Summary">Summary</a>
</p>

        <xsl:call-template name="gu:HTMLblurb"/>
<hr/>
  <!--produce tabular reports-->
  <xsl:for-each-group select="$gu:thisSubsetBIEs"
                      group-by="gu:col(.,'ModelName')">
    <xsl:sort select="gu:col(.,'ModelName')=$gu:thisCommonLibraryModel"/>
    <xsl:sort select="gu:col(.,'ModelName')"/>

    <xsl:variable name="gu:thisModelName" select="gu:col(.,'ModelName')"/>
    <h3>
       <a name="Table-{$gu:thisModelName}">
        <xsl:value-of select="$gu:thisModelName"/>
       </a>
    </h3>
    <xsl:if test="position()=last()">
      <small>
  This summary of elements only includes those members of the common
  library that are referenced directly or indirectly by
  <xsl:for-each
            select="distinct-values($gu:thisSubsetABIEs
                    [gu:col(.,'ModelName')!=$gu:thisCommonLibraryModel]/
                    gu:col(.,'ModelName'))">
    <xsl:choose>
      <xsl:when test="last()=1"/>
      <xsl:when test="position()=last()"> and </xsl:when>
      <xsl:when test="position()&gt;1">, </xsl:when>
    </xsl:choose>
    <xsl:value-of select="."/>
  </xsl:for-each>
  <xsl:text>.</xsl:text>
</small>
    </xsl:if>

    <xsl:variable name="gu:fast" select="false()"/>
    <xsl:variable name="gu:allBIEs"
                  select="(current-group() |
         current-group()/key('gu:bie-by-abie-class',gu:col(.,'ObjectClass')))
                         [$gu:subsetExclusions or gu:isSubsetBIE(.)]"/>
    <xsl:variable name="gu:headsInUse">
      <xsl:for-each select="$gu:heads/row">
        <row>
          <xsl:for-each select="h">
            <xsl:if test="( $gu:fast or @force='yes' or
                      $gu:allBIEs[gu:col(.,current()/
                               (if (n=('*pos','*name')) then $gu:names else n))
                                /normalize-space(.)] )">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </row>
      </xsl:for-each>
    </xsl:variable>
    <table class="iT" summary="Module summary">
      <xsl:variable name="gu:header">
        <tr class="iR">
          <xsl:for-each select="$gu:headsInUse/row/h">
            <xsl:if test="not(@span='all')">
              <th class="iC">
                <xsl:copy-of select="t/node()"/>
              </th>              
            </xsl:if>
          </xsl:for-each>
        </tr>
      </xsl:variable>
      <xsl:variable name="gu:span" 
                    select="count($gu:header/tr/th) -
                            count($gu:headsInUse/row[1]/h[not(@span='all')])"/>
      <xsl:copy-of select="$gu:header"/>
      <xsl:for-each-group select="$gu:allBIEs"
                          group-by="gu:col(.,'ObjectClass')">
       <xsl:sort select="if( $gu:ABIEsortColumnName )
             then (gu:col(.,$gu:ABIEsortColumnName),gu:col(.,'ObjectClass'))[1]
             else false()"/>
       <xsl:sort select="if( $gu:ABIEsortColumnName )
             then ()
             else gu:col(.,'ObjectClassQualifier')"/>
       <xsl:for-each select="current-group()">
        <xsl:variable name="gu:row" select="."/>
        <xsl:variable name="gu:type"
                      select="gu:col($gu:row,'ComponentType')"/>
        <xsl:variable name="gu:inSubset" select="gu:isSubsetBIE(.)"/>
        <xsl:variable name="gu:pos" select="
  count(preceding-sibling::Row[gu:col(.,'ModelName')=$gu:thisModelName]) + 2"/>
        <xsl:variable name="gu:card"
                      select="gu:col($gu:row,'Cardinality')"/>
        <xsl:variable name="gu:background-color"
                      select="if     ( $gu:type='ABIE')   then '#f898c8'
                              else if( $gu:type='ASBIE')  then '#cbfbcb'
                              else                             '#ffffff'"/>
        <xsl:variable name="gu:references"
                      select=".[$gu:type='ABIE']/
                              key('gu:asbie-by-referred-abie',
                                        gu:col($gu:row,'ObjectClass'),$gu:gc)
                              [some $gu:bie in $gu:thisSubsetBIEs
                               satisfies $gu:bie is .]"/>
        <xsl:variable name="gu:denComp"
                      select="gu:colcomp($gu:row,'DictionaryEntryName')"/>
        
        <xsl:if test="gu:isSubsetBIE(.) or $gu:subsetExclusions">
         <xsl:for-each select="$gu:headsInUse[$gu:subsetExclusions or
                                              $gu:inSubset]/row">
          <tr style="background-color:{$gu:background-color};{
          if(not($gu:inSubset)) then 'text-decoration:line-through;' else ''}"
              class="iR">
            <xsl:for-each select="h">
              <td class="iC">
                <xsl:if test="@span='all'">
                  <xsl:attribute name="colspan" select="$gu:span"/>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="n='*pos'">
                    <xsl:attribute name="rowspan" select="2"/>
                    <a name="Table-{$gu:denComp}">
                      <xsl:if test="$gu:inSubset">
                        <xsl:attribute name="href"
                                     select="concat('#Summary-',$gu:denComp)"/>
                      </xsl:if>
                      <xsl:value-of select="$gu:pos"/>
                    </a>
                    <xsl:if test="$gu:type!='ABIE'">
                      <br/>
                      <a
                href="#Table-{gu:colcomp($gu:row,'ObjectClass')}.Details">^</a>
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="n='*name'">
                    <xsl:attribute name="rowspan" select="2"/>
                    <xsl:if test="starts-with($gu:card,'1')">
                      <xsl:attribute name="style">
                        <xsl:text>font-weight:bold</xsl:text>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$gu:ABIEsortColumnName and
                                  gu:col($gu:row,'ComponentType')='ABIE' and
                                  gu:colcomp($gu:row,$gu:ABIEsortColumnName)!=
                                  gu:col($gu:row,$gu:names)">
                      <i>
                        <xsl:value-of select="concat(
                             '(',gu:col($gu:row,$gu:ABIEsortColumnName),')')"/>
                      </i>
                      <br/>
                    </xsl:if>
                    <xsl:value-of select="gu:col($gu:row,$gu:names)"/>
                    <xsl:if test="$gu:type='ABIE'">
                      <br/>
                      <xsl:for-each select="$gu:references">
                        <a href="#Table-{gu:colcomp(.,'DictionaryEntryName')}"
                           title="{gu:col(.,'DictionaryEntryName')}">&lt;</a>
                        <xsl:text> </xsl:text>
                      </xsl:for-each>
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="n[$gu:type='BBIE']=
                                            ('RepresentationTerm','DataType')">
                    <xsl:choose>
                      <xsl:when test="gu:isSubsetBIE($gu:row)">
                        <a href=
          "#{concat('UDT-',gu:colcomp($gu:row,'RepresentationTerm'),'.Type')}">
                          <xsl:value-of select="gu:col($gu:row,n)"/>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:value-of select="gu:col($gu:row,n)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:when test="n[$gu:type='ASBIE']=
                               ('RepresentationTerm','AssociatedObjectClass')">
                    <xsl:choose>
                      <xsl:when test="gu:isSubsetBIE($gu:row)">
                        <xsl:variable name="gu:remote"
                                    select="$gu:gcOther/key('gu:abie-by-class',
                                            gu:col($gu:row,current()/n),. )"/>
                        <a href="{if( $gu:remote )
                                  then $base-summary-uri else ''}#Table{
                                if( $gu:remote ) then $gu:extDelimit else '-'}{
                                gu:colcomp($gu:row,n)}.Details">
                          <xsl:if test="$gu:remote">
                            <xsl:attribute name="target" 
                                           select="$base-summary-uri"/>
                          </xsl:if>
                          <xsl:value-of select="gu:col($gu:row,n)"/>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="gu:col($gu:row,n)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:when test="n[$gu:type!='ABIE']='ObjectClass'">
                    <a
                   href="#{concat('Table-',gu:colcomp($gu:row,n),'.Details')}">
                      <xsl:value-of select="gu:col($gu:row,n)"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="gu:col($gu:row,n)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </xsl:for-each>
          </tr>
         </xsl:for-each>
        </xsl:if>
       </xsl:for-each>
      </xsl:for-each-group>
    </table>
    
  </xsl:for-each-group>

  <xsl:apply-templates mode="gu:udt" select="$udt">
    <xsl:with-param name="gu:thisSubsetBBIEs" tunnel="yes"
          select="$gu:thisSubsetBIEs[gu:col(.,'ComponentType')='BBIE']"/>
  </xsl:apply-templates>
        
<h3><a name="Summary">Summary</a></h3>
        
  <xsl:call-template name="gu:HTMLblurb"/>

  <!--produce summary reports-->

  <xsl:for-each-group select="$gu:thisSubsetBIEs"
                     group-by="upper-case(substring(gu:col(.,$gu:names),1,3))">
    <xsl:sort select="current-grouping-key()" lang="en"/>
    <xsl:variable name="gu:thisModelName" select="gu:col(.,'ModelName')"/>
    <xsl:variable name="gu:pos" select="
  count(preceding-sibling::Row[gu:col(.,'ModelName')=$gu:thisModelName]) + 2"/>
    <h4><xsl:value-of select="current-grouping-key()"/></h4>
    <a name="Index_{current-grouping-key()}"/>
    <xsl:for-each-group select="current-group()"
                        group-by="gu:col(.,$gu:names)">
      <xsl:sort select="current-grouping-key()" lang="en"/>
      <xsl:choose>
        <xsl:when test="count(current-group())=1">
          <!--there is only one in all models with this given name-->
          <!--display the summary for the item-->
<table summary="{current-grouping-key()} - single model">
 <!--use a table so that the definition doesn't wrap-->
 <tr>
   <td class="sC" nowrap="nowrap">
     <a name="{concat('Summary-',gu:colcomp(.,'DictionaryEntryName'))}"/>
     <xsl:value-of select="current-grouping-key()"/>
     <span class="uT">
       <xsl:text> (</xsl:text>
       <xsl:call-template name="gu:entry-ref">
         <xsl:with-param name="gu:anchor" select="false()"/>
       </xsl:call-template>
       <xsl:text>)</xsl:text>
     </span>
   </td>
   <xsl:call-template name="gu:entry-def">
     <xsl:with-param name="gu:thisSubsetBIEs" select="$gu:thisSubsetBIEs"/>
   </xsl:call-template>
 </tr>
</table>
        </xsl:when>
        <xsl:otherwise>
<table summary="{current-grouping-key()} - multiple models">
  <!--use a table to ensure same spacing to left of text-->
  <tr>
    <td class="sC" nowrap="nowrap">
      <xsl:value-of select="current-grouping-key()"/>
    </td>
  </tr>
</table>
<table summary="indentation">
  <tr>
    <td><p>&nbsp;&nbsp;&nbsp;&nbsp;</p></td>
    <td valign="top">
      <xsl:variable name="gu:this" select="current-grouping-key()"/>
      <xsl:for-each-group select="current-group()" 
                          group-by="gu:col(.,'ModelName')">
        <!--grouped by the model in which the items are found-->
        <xsl:sort select="current-grouping-key()" lang="en"/>
        <xsl:choose>
          <xsl:when test="count(current-group())=1">
            <!--there is only one in this model with this name-->
<table summary="{current-grouping-key()} - single use in given model">
  <!--use a table so that the definition doesn't wrap under other pieces-->
  <tr>
    <td class="sC" nowrap="nowrap">
      <i>
        <xsl:value-of select="current-grouping-key()"/>
      </i>
      <span class="ut">
        <xsl:text> (</xsl:text>
        <xsl:for-each select="current-group()">
          <xsl:call-template name="gu:entry-ref"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
      </span>
    </td>
    <xsl:call-template name="gu:entry-def">
     <xsl:with-param name="gu:thisSubsetBIEs" select="$gu:thisSubsetBIEs"/>
   </xsl:call-template>
  </tr>
</table>
          </xsl:when>
          <xsl:otherwise>
            <!--multiple items in one model with this name-->
<table summary="{current-grouping-key()} - multiple use in given model ">
  <!--use one-cell table to ensure spacing of heading-->
  <tr>
    <td style="vertical-align:baseline" nowrap="nowrap">
      <i>
        <xsl:value-of select="current-grouping-key()"/>
      </i>
    </td>
  </tr>
</table>
<table summary="indentation">
  <tr>
    <td><p>&nbsp;&nbsp;&nbsp;&nbsp;</p></td>
    <td valign="top">
      <!--present all entries-->
     <xsl:for-each select="current-group()[gu:col(.,'ComponentType')='BBIE'],
                           current-group()[gu:col(.,'ComponentType')='ABIE'],
                           current-group()[gu:col(.,'ComponentType')='ASBIE']">
<table summary="{$gu:this} - each in given model">
  <!--use a table so that the definition doesn't wrap under other pieces-->
  <tr>
    <td class="sC uT" nowrap="nowrap">
      <xsl:text>(</xsl:text>
      <xsl:call-template name="gu:entry-ref"/>
      <xsl:text>)</xsl:text>
    </td>
    <xsl:call-template name="gu:entry-def">
     <xsl:with-param name="gu:thisSubsetBIEs" select="$gu:thisSubsetBIEs"/>
   </xsl:call-template>
  </tr>
</table>
      </xsl:for-each>
    </td>
  </tr>
</table>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </td>
  </tr>
</table>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:for-each-group>
        
        <pre>
          <xsl:for-each select="1 to 5">
            <xsl:text>&#xa;</xsl:text>
          </xsl:for-each>
        </pre>
        <small>END</small>
        <pre>
          <xsl:for-each select="1 to 80">
            <xsl:text>&#xa;</xsl:text>
          </xsl:for-each>
        </pre>
      </body>
    </html>
  </xsl:result-document>
</xsl:template>

<xs:template>
  <para>Intercept UDT for back links: add back links</para>
  <xs:param name="gu:thisSubsetBBIEs">
    <para>The BBIEs that are in play</para>
  </xs:param>
</xs:template>
<xsl:template match="a[starts-with(@name,'UDT-')]" mode="gu:udt">
  <xsl:param name="gu:thisSubsetBBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:copy-of select="."/>
  <br/>
  <xsl:variable name="gu:representationTerm"
                select="replace(@name,'(UDT-)(.+?)\.(.+)','$2')"/>
  <xsl:for-each select="$gu:thisSubsetBBIEs[gu:col(.,'RepresentationTerm')=
                                            $gu:representationTerm]">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <a href="#Table-{gu:colcomp(.,'DictionaryEntryName')}"
       title="{gu:col(.,'DictionaryEntryName')}">&lt;</a>
    <xsl:text> </xsl:text>
  </xsl:for-each>
</xsl:template>

<xs:template>
  <para>Intercept UDT for back links: preserve</para>
</xs:template>
<xsl:template match="node()" mode="gu:udt">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="gu:udt"/>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>Make a reference to a table entry from the summary Item</para>
  <xs:param name="gu:anchor">
    <para>Anchor the item making the reference</para>
  </xs:param>
  <xs:param name="gu:link-ABIE">
  <para>Indication that the link is obliged to be shown, not suppressed.</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:entry-ref">
  <xsl:param name="gu:anchor" select="true()" as="xsd:boolean"/>
  <xsl:param name="gu:link-ABIE" select="false()" as="xsd:boolean"/>
  <xsl:variable name="gu:thisModel" select="gu:col(.,'ModelName')"/>
  <xsl:variable name="gu:denComp"
                select="gu:colcomp(.,'DictionaryEntryName')"/>
    <!--determine the line number reference within the given table-->
    <xsl:variable name="gu:line" select="
      count(preceding-sibling::Row[gu:col(.,'ModelName')=$gu:thisModel]) + 2"/>
    <!--anchor the entry in the summary-->
    <a>
      <xsl:if test="$gu:anchor">
        <xsl:attribute name="name" select="concat('Summary-',$gu:denComp)"/>
      </xsl:if>
      <xsl:attribute name="href" select="concat('#Table-',$gu:denComp)"/>
      <xsl:value-of select="$gu:line"/>
    </a>
    <!--the object class is not the same as the model, so expose it-->
    <xsl:variable name="gu:objectClass" select="gu:colcomp(.,'ObjectClass')"/>
    <xsl:if test="( $gu:link-ABIE or
                    $gu:objectClass!=$gu:thisModel
                    or gu:col(.,'CraneCellObjectClassQualifier') ) and
                  $gu:objectClass!=gu:col(.,$gu:names)">
     <xsl:text> </xsl:text>
      <xsl:variable name="gu:remote"
                    select="$gu:gcOther/key('gu:abie-by-class',
                                            $gu:objectClass,. )"/>
      <a href="{if( $gu:remote ) then $base-summary-uri else ''}#Summary{
                if( $gu:remote ) then $gu:extDelimit else '-'}{
                gu:colcomp(.,'ObjectClass')}.Details">
        <xsl:if test="$gu:remote">
          <xsl:attribute name="target" 
                         select="$base-summary-uri"/>
        </xsl:if>
        <xsl:for-each select="gu:col(.,'ObjectClassQualifier')">
          <!--include a qualifier if it exists; doesn't in base UBL-->
          <xsl:value-of select="concat(.,'_ ')"/>
        </xsl:for-each>
        <xsl:value-of select="$gu:objectClass"/>
      </a>
    </xsl:if>
</xsl:template>

<xs:template>
  <para>Present the entry's type and definition</para>
  <xs:param name="gu:modelABIEs">
    <para>The ABIEs in the models associated with this profile.</para>
  </xs:param>
  <xs:param name="gu:thisSubsetBIEs">
    <para>The set of BIEs in the subset.</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:entry-def">
  <xsl:param name="gu:thisSubsetBIEs" as="element(Row)*"/>
  <xsl:variable name="gu:type" select="gu:col(.,'ComponentType')"/> 
  <xsl:variable name="gu:ascClass"
                select="gu:col(.,'AssociatedObjectClass')"/>
  <xsl:variable name="gu:ascClassComp"
                select="gu:colcomp(.,'AssociatedObjectClass')"/>
  <xsl:variable name="gu:thisName" select="gu:col(.,$gu:names)"/>
  <td style="vertical-align:baseline">
    <xsl:choose>
      <xsl:when test="$gu:type='ASBIE' and $gu:ascClassComp!=$gu:thisName">
        <!--link the type to the type definition-->
        <small>
          <xsl:variable name="gu:remote"
                        select="$gu:gcOther/key('gu:abie-by-class',
                                                $gu:ascClass,. )"/>
          <a href="{if( $gu:remote ) then $base-summary-uri else ''}#Summary{
                    if( $gu:remote ) then $gu:extDelimit else '-'}{
                    $gu:ascClassComp}.Details">
            <xsl:if test="$gu:remote">
              <xsl:attribute name="target" 
                             select="$base-summary-uri"/>
            </xsl:if>
            <xsl:value-of select="$gu:type"/>
            <xsl:text/> (<xsl:value-of select="$gu:ascClassComp"/>)<xsl:text/>
          </a>
        </small>
      </xsl:when>
      <xsl:otherwise>
        <small>
          <xsl:value-of select="$gu:type"/>
        </small>
      </xsl:otherwise>
    </xsl:choose>
  </td>
  <!--present the definition-->
  <td style="vertical-align:baseline">
    <small>
      <xsl:value-of select="gu:col(.,'Definition')"/>
    </small>
    <xsl:if test="$gu:type='ABIE'">
      <xsl:variable name="gu:class" select="gu:col(.,'ObjectClass')"/>
      <xsl:variable name="gu:used-by-asbie"
                    select="key('gu:asbie-by-referred-abie',$gu:class)
                            [some $gu:bie in $gu:thisSubsetBIEs
                                  satisfies $gu:bie is .]
                            [gu:col(.,$gu:names)!=$gu:thisName]"/>
      <xsl:if test="exists($gu:used-by-asbie)">
        <small>
          <br/>
          <xsl:for-each select="$gu:used-by-asbie">
            <xsl:sort select="gu:col(.,$gu:names)" lang="en"/>
            <xsl:variable name="gu:thisRow" select="."/>
            <xsl:variable name="gu:thisName" select="gu:col(.,$gu:names)"/>
            <xsl:if test="position()>1"><xsl:text> </xsl:text></xsl:if>
            <span style="white-space:nowrap">
              <xsl:variable name="gu:remote"
                            select="$gu:gcOther/key('gu:abie-by-class',
                                   gu:colcomp($gu:thisRow,'ObjectClass'),. )"/>
            <a href="{if( $gu:remote ) then $base-summary-uri else ''}#Summary{
                      if( $gu:remote ) then $gu:extDelimit else '-'}{
                      gu:colcomp($gu:thisRow,'DictionaryEntryName')}">
                <xsl:if test="$gu:remote">
                  <xsl:attribute name="target" 
                                 select="$base-summary-uri"/>
                </xsl:if>
                <xsl:value-of select="$gu:thisName"/>
              </a>
              <xsl:text> (</xsl:text>
              <xsl:call-template name="gu:entry-ref">
                <xsl:with-param name="gu:anchor" select="false()"/>
                <xsl:with-param name="gu:link-ABIE" select="true()"/>
              </xsl:call-template>
              <xsl:text>)</xsl:text>
            </span>
          </xsl:for-each>
        </small>
      </xsl:if>
    </xsl:if>
  </td>
</xsl:template>

<xs:template>
  <para>Adding the blurb as a comment</para>
</xs:template>
<xsl:template name="gu:HTMLcopyright">
  <xsl:comment>
    <xsl:call-template name="gu:HTMLblurb"/>
  </xsl:comment>
</xsl:template>

<xs:template>
  <para>Exposing the blurb as information</para>
</xs:template>
<xsl:template name="gu:HTMLblurb">
 <p>
 <small>
   <xsl:value-of select="$copyright-text"/>
 </small>
 </p>
 <p>
   Rendering: <xsl:value-of select="$date-time"/>
 </p>

<table summary="Legends">
  <tr>
   <td rowspan="4" valign="top">Legends:</td><td>Summary Legend:</td>
   <td valign="top">Name (<i>Model </i><small><u>line</u> Object</small>)
   <small>TYPE Description</small></td>
  </tr>
  <tr>
    <td rowspan="2" valign="top">Table Legend:</td>
    <td valign="top"><span style="color:blue;text-decoration:underline">^</span>
   <span> = up-link to the containing ABIE of the BBIE 
or the ASBIE (hover to see ABIE name)</span></td>
  </tr>
  <tr>
    <td valign="top">
      <span style="color:blue;text-decoration:underline">&lt;</span>
   <span> = back-link to the ASBIE using the ABIE, or 
to the BBIE using the data type (hover to see destination)</span> 
    </td>
  </tr>
  <tr>
    <td valign="top"> Line number links: </td>
    <td valign="top">
      <span>alternate between summary view and table view</span>
    </td>
  </tr>
</table>
<br/>
</xsl:template>

<xs:variable>
  <para>Column-related information and heading formats</para>
</xs:variable>
<xsl:variable name="gu:heads" as="document-node()">
 <xsl:document>
  <!--h=head,n=name,t=title-->
  <row>
    <h><n>*pos</n></h>
    <h><n>*name</n><t>Name</t></h>
    <h span="all"><n>Definition</n><t>Definition</t></h>
  </row>
  <row>
    <xsl:for-each select="$gu:subsetColumnNameDisplay">
      <h force='yes'>
        <n><xsl:value-of select="$gu:subsetColumnName"/></n>
        <t>
          <xsl:value-of select="replace(.,'([a-z])([A-Z])','$1&#x200b;$2')"/>
        </t>
      </h>
    </xsl:for-each>
    <xsl:for-each select="$gu:docColumns">
      <h force="yes">
        <n><xsl:value-of select="ShortName"/></n>
        <t>
     <xsl:value-of select="replace(LongName,'([a-z])([A-Z])','$1&#x200b;$2')"/>
        </t>
      </h>
    </xsl:for-each>
    <h><n>Cardinality</n><t>Card.</t></h>
    <h><n>RepresentationTerm</n><t>Rep. Term</t></h>
    <h><n>AlternativeBusinessTerms</n><t>Alt.&nbsp;Business<br/>Terms</t></h>
    <h><n>Examples</n><t>Examples</t></h>
    <h><n>DictionaryEntryName</n><t>Dictionary&nbsp;Entry&nbsp;Name</t></h>
   <xsl:if test="not($gu:abbreviateColumns)">
    <h><n>UNTDEDCode</n><t>UNTDED<br/>Code</t></h>
    <h><n>CurrentVersion</n><t>Ver.</t></h>
    <h><n>ComponentType</n><t>Comp.<br/>Type</t></h>
    <h><n>ObjectClassQualifier</n><t>Obj.&nbsp;Class<br/>Qual.</t></h>
    <h><n>ObjectClass</n><t>Class</t></h>
    <h><n>PropertyTermQualifier</n><t>Prop.&nbsp;Term<br/>Qualifier</t></h>
    <h><n>PropertyTermPossessiveNoun</n><t>Prop.&nbsp;Term<br/>Poss.&nbsp;Noun</t></h>
    <h><n>PropertyTermPrimaryNoun</n><t>Prop.&nbsp;Term<br/>Prim.&nbsp;Noun</t></h>
    <h skip=""><n>PropertyTerm</n><t>Prop. Term</t></h>
    <h><n>DataTypeQualifier</n><t>Data&nbsp;Type<br/>Qualifier</t></h>
    <h><n>DataType</n><t>Data Type</t></h>
    <h><n>AssociatedObjectClassQualfier</n><t>Assoc.&nbsp;Obj.<br/>Class&nbsp;Qual.</t></h>
    <h><n>AssociatedObjectClass</n><t>Assoc.<br/>Class</t></h>
   </xsl:if>
  </row>
 </xsl:document>
</xsl:variable>

</xsl:stylesheet>

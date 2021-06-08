<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: Crane-checkgc4obdndr.xsl,v 1.40 2021/06/04 00:34:10 admin Exp $"
     filename="Crane-checkgc4obdndr.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Compare new model against old using DocBook</xs:title>
  <para>
    This reads in an old and new OASIS Business Document NDR entities file,
    checking which of the model properties in the new file are new compared
    to the old file.
  </para>
  <para>
    The results are emitted using a DocBook table and/or HTML
  </para>
</xs:doc> 
 
<xsl:include href="support/Crane-commonndr.xsl"/>
<xsl:include href="support/ndrSubset.xsl"/>
<xsl:include href="support/checkgc4obdndr-model.xsl"/>
<xsl:include href="support/checkgc4obdndr-report.xsl"/>
<xsl:include href="support/checkgc4obdndr-rules.xsl"/>
<xsl:include href="support/checkgc4obdndr-schema.xsl"/>

<xs:output>
  <para>Indented results are easier to review in editing</para>
</xs:output>
<xsl:output indent="yes"/>

<xs:param ignore-ns="yes">
  <para>The old entities open file; when using Saxon use +old=filename</para>
</xs:param>
<xsl:param name="old" as="document-node()" 
           select="if( $old-uri)
                   then for $u in resolve-uri( $old-uri,base-uri($new) ) return
                               if( doc-available($u) ) then doc($u) 
                               else error( (),concat(
                               'Unable to open resolved old uri: ',
                               $u ) )
                   else if( $new )
                   then $new
                   else error( (), 'Missing URI or open old document')
                   "/>

<xs:param ignore-ns="yes">
  <para>The old entities filename when not opening on invocation</para>
</xs:param>
<xsl:param name="old-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The new entities open file</para>
</xs:param>
<xsl:param name="new" as="document-node()" select="/"/>

<xs:param ignore-ns="yes">
  <para>The base entities open file; when using Saxon use +basefilename</para>
</xs:param>
<xsl:param name="base-gc" as="document-node()?" 
       select="if( $base-gc-uri)
               then for $u in resolve-uri( $base-gc-uri,base-uri($new) ) return
                           if( doc-available($u) ) then doc($u) 
                           else error( (),concat(
                           'Unable to open resolved base-gc-uri: ',
                           $u ) )
               else ()"/>

<xs:param ignore-ns="yes">
  <para>The suffix to use in the title</para>
</xs:param>
<xsl:param name="title-suffix" as="xsd:string" required="yes"/>

<xs:param ignore-ns="yes">
  <para>The suffix to use in the title row of the change column</para>
</xs:param>
<xsl:param name="change-suffix" as="xsd:string" select="''"/>

<xs:param ignore-ns="yes">
  <para>An indication to relax a rule for development</para>
</xs:param>
<xsl:param name="ignore-sort-rule" as="xsd:string" select="'no'"/>

<xs:variable>
  <para>A testable value for ignoring the sort rule</para>
</xs:variable>
<xsl:variable name="gu:ignore-sort-rule" as="xsd:boolean"
              select="starts-with('yes',lower-case($ignore-sort-rule))"/>

<xs:param ignore-ns="yes">
  <para>
    Indicate that the version number is to be checked by indicating the name.
  </para>
</xs:param>
<xsl:param name="version-column-name" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The URI for the DocBook output of the common report</para>
</xs:param>
<xsl:param name="docbook-common-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The URI for the DocBook output of the maindoc report</para>
</xs:param>
<xsl:param name="docbook-maindoc-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The URI for the "All Documents" HTML report for referencing</para>
</xs:param>
<xsl:param name="all-documents-report-href" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The URI for the output of all of the words used in DEN values</para>
</xs:param>
<xsl:param name="den-word-list-uri" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The URI for the output of all of the words used in DEN values</para>
</xs:param>
<xsl:param name="errors-are-fatal" as="xsd:string" select="'yes'"/>

<xs:variable>
  <para>A testable value for ignoring the sort rule</para>
  <para>
    Rather than testing for fatal, testing for not fatal will consider a bogus
    value as "yes" rather than a "no" and let errors go undetected.
  </para>
</xs:variable>
<xsl:variable name="gu:errors-are-fatal" as="xsd:boolean"
              select="not(starts-with('no',lower-case($errors-are-fatal)))"/>

<xs:template ignore-ns="yes">
  <para>Start the reports</para>
</xs:template>
<xsl:template match="/">
  <xsl:if test="not($config)">
    <xsl:message terminate="yes">
      <xsl:text>Either +config= or config-uri= is required</xsl:text>
      <xsl:text> as a parameter pointing to the configuration file.</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="exists($xsd-common-dir-uri)!=exists($xsd-maindoc-dir-uri)">
    <xsl:message terminate="yes">
      <xsl:text>When checking the validation artefacts both of the </xsl:text>
      <xsl:text>XSD directory arguments must be specified.</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:variable name="gu:docbook-common">
   <xsl:call-template name="gu:makeReport">
     <xsl:with-param name="common" select="true()"/>
     <xsl:with-param name="summary" select="true()"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="gu:docbook-maindoc">
   <xsl:call-template name="gu:makeReport">
     <xsl:with-param name="common" select="false()"/>
     <xsl:with-param name="summary" select="true()"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="gu:docbook-common-detail">
   <xsl:call-template name="gu:makeReport">
     <xsl:with-param name="common" select="true()"/>
     <xsl:with-param name="summary" select="false()"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="gu:docbook-maindoc-detail">
   <xsl:call-template name="gu:makeReport">
     <xsl:with-param name="common" select="false()"/>
     <xsl:with-param name="summary" select="false()"/>
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="gu:errors" select="$gu:collectAllErrors[self::ndrbad]"/>
  <xsl:result-document method="html">
    <html>
     <head>
      <title>Analysis of <xsl:value-of select="$title-suffix"/></title>
     </head>
     <body>
       <div style="text-align:right;margin-bottom:0pt">
         <small><xsl:value-of select="current-dateTime()"/></small>
       </div>
       <xsl:if test="$gu:errors">
         <h2>Errors detected</h2>
         <p>The following DENs need attention<xsl:text/>
           <xsl:if test="($gu:docbook-common,$gu:docbook-maindoc)
                         [.//tbody/row]">
              (<a href="#_analysis">complete analysis here</a>)</xsl:if>
           <xsl:text/>:</p>
         <ul>
           <xsl:for-each-group select="$gu:errors"
                               group-by="(.//@gu:den)[1]">
             <xsl:sort select="current-grouping-key()"/>
             <li>
               <xsl:value-of select="@gu:den"/>
               <xsl:text> - </xsl:text>
               <xsl:copy-of select="gu:citeGroup(current-group())"/>
             </li>
           </xsl:for-each-group>
         </ul>
       </xsl:if>
       <h2><a name="_analysis"/>Analysis of <xsl:value-of
                                                  select="$title-suffix"/></h2>
       <p>
         Hover over the category titles for a more detailed description
         in a pop-up tool-tip.
       </p>
       <xsl:call-template name="gu:reportAllModelProblems"/>
       <xsl:call-template name="gu:reportAllRuleProblems"/>
       <xsl:if test="$gu:xsd-check">
         <xsl:call-template name="gu:reportAllSchemaProblems"/>
       </xsl:if>
       <xsl:for-each select="$gu:docbook-common,
                             $gu:docbook-maindoc,
                             $gu:docbook-common-detail,
                             $gu:docbook-maindoc-detail">
         <table>
           <xsl:apply-templates select="." mode="gu:db2html"/>
         </table>
       </xsl:for-each>
     </body>
    </html>
  </xsl:result-document>
  <xsl:if test="$docbook-common-uri">
    <xsl:result-document href="{$docbook-common-uri}"
                         omit-xml-declaration="yes">
      <xsl:copy-of select="$gu:docbook-common"/>
    </xsl:result-document>
  </xsl:if>
  <xsl:if test="$docbook-maindoc-uri">
    <xsl:result-document href="{$docbook-maindoc-uri}"
                         omit-xml-declaration="yes">
      <xsl:copy-of select="$gu:docbook-maindoc"/>
    </xsl:result-document>
  </xsl:if>
  <xsl:if test="$den-word-list-uri">
    <xsl:result-document href="{$den-word-list-uri}" method="text">
      <xsl:for-each select="distinct-values(
                    for $gu:row in /*/SimpleCodeList/Row return
                        for $gu:col in $gu:allDENRelatedColumns return
                            for $gu:token in 
                                 gu:col($gu:row,$gu:col)/tokenize(.,'[._\s]+')
          return concat( $gu:token,' ',gu:col($gu:row,$version-column-name)))">
        <xsl:sort/>
        <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
    </xsl:result-document>
  </xsl:if>
  <xsl:if test="$gu:errors">
    <xsl:message terminate="{if( $gu:errors-are-fatal ) then 'yes' else 'no'}"
                 select="count($gu:errors),'NDR check errors detected'"/>
  </xsl:if>
</xsl:template>

<xs:function>
  <para>Cite a group of numbered references</para>
  <xs:param name="group">
    <para>The citations</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:citeGroup" as="node()*">
  <xsl:param name="group" as="element()*"/>  
   <xsl:for-each select="$group">
     <xsl:if test="position()>1">, </xsl:if>
     <xsl:text>(</xsl:text>
     <a href="#{generate-id(.)}">
       <xsl:if test="true() and @gu:var">
         <xsl:attribute name="title" select="@gu:var"/>
       </xsl:if>
       <xsl:value-of select="position()"/>
     </a><xsl:text>)</xsl:text>
   </xsl:for-each>
</xsl:function>

<xs:template>
  <para>Start the reports</para>
  <xs:param name="common">
    <para>Indication of working with the Common Library, or not</para>
  </xs:param>
  <xs:param name="summary">
    <para>Indication of a summary result or full result</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:makeReport">
  <xsl:param name="common" as="xsd:boolean" required="yes"/>
  <xsl:param name="summary" as="xsd:boolean" required="yes"/>
  <xsl:comment>
    <xsl:choose>
      <xsl:when test="$summary">Summary</xsl:when>
      <xsl:otherwise>Detailed</xsl:otherwise>
    </xsl:choose>
    <xsl:text> changes to </xsl:text>
    <xsl:value-of select="if( $common ) then 'Library' else 'Document'"/>
    <xsl:text> Elements </xsl:text>
    <xsl:value-of select="$title-suffix"/>
  </xsl:comment>
  <tgroup cols="{if( $summary ) then '3' else '20'}">
    <xsl:comment select="if( $common ) then 'Library' else 'Document',
                         $title-suffix"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:choose>
      <xsl:when test="$summary">
        <colspec colwidth="35*"/>
        <colspec colwidth="35*"/>
        <colspec colwidth="30*"/>
      </xsl:when>
      <xsl:otherwise>
        <!--for now, try auto width-->
      </xsl:otherwise>
    </xsl:choose>
    <thead>
      <xsl:choose>
        <xsl:when test="$summary">
          <row>
           <entry>Aggregate BIE</entry>
           <entry>Basic or Association BIE</entry>
           <entry>Changes for <xsl:value-of select="$change-suffix"/></entry>
          </row>
        </xsl:when>
        <xsl:otherwise>
          <tr>
            <th style="border:1px solid black;vertical-align:top">&#xa0;</th>
            <th style="border:1px solid black;vertical-align:top">Component Name</th>
            <th style="border:1px solid black;vertical-align:top">Cardinality</th>
            <th style="border:1px solid black;vertical-align:top">Alternative Business Terms</th>
            <th style="border:1px solid black;vertical-align:top">Examples</th>
            <th style="border:1px solid black;vertical-align:top">Dictionary Entry Name</th>
            <!--<th style="border:1px solid black;vertical-align:top">Object Class Qualifier</th>-->
            <th style="border:1px solid black;vertical-align:top">Object Class</th>
            <th style="border:1px solid black;vertical-align:top">Property Term Qualifier</th>
            <th style="border:1px solid black;vertical-align:top">Property Term Possessive Noun</th>
            <th style="border:1px solid black;vertical-align:top">Property Term Primary Noun</th>
            <th style="border:1px solid black;vertical-align:top">Property Term</th>
            <th style="border:1px solid black;vertical-align:top">Representation Term</th>
            <th style="border:1px solid black;vertical-align:top">Data Type Qualifier</th>
            <th style="border:1px solid black;vertical-align:top">Data Type</th>
            <!--<th style="border:1px solid black;vertical-align:top">Associated Object Class Qualifier</th>-->
            <th style="border:1px solid black;vertical-align:top">Associated Object Class</th>
            <th style="border:1px solid black;vertical-align:top">Comp. Type</th>
            <th style="border:1px solid black;vertical-align:top">UN/TDED Code</th>
            <th style="border:1px solid black;vertical-align:top">Current Version</th>
            <th style="border:1px solid black;vertical-align:top">Editor's Notes</th>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </thead>
   <tbody>
     <xsl:variable name="changes" as="element()*">
       <xsl:call-template name="gu:findChanges">
         <xsl:with-param name="abies" select="if( $common ) 
                    then $gu:subsetLibraryABIEs else $gu:subsetDocumentABIEs"/>
         <xsl:with-param name="summary" select="$summary"/>
       </xsl:call-template>
     </xsl:variable>
     <xsl:copy-of select="$changes"/>
     <xsl:if test="empty($changes)">
       <row>
         <entry>
           No changes detected.
         </entry>
         <entry/>
         <entry/>
       </row>
     </xsl:if>
   </tbody>
  </tgroup>
</xsl:template>

<xs:template>
  <para>Determine the changes and create rows</para>
  <xs:param name="abies">
    <para>Which ABIEs to examine.</para>
  </xs:param>
  <xs:param name="summary">
    <para>Indication of a summary result or full result</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:findChanges">
  <xsl:param name="abies" as="element(Row)*"/>
  <xsl:param name="summary" as="xsd:boolean" required="yes"/>
  <xsl:variable name="gu:deletedABIEs" as="element(Row)*">
    <!--determine deleted ABIEs by looking at deleted ASBIEs only-->
    <xsl:for-each select="$abies">
      <xsl:variable name="gu:childrenOld"
                    select="key('gu:bie-by-abie-class',
                                gu:col(.,'ObjectClass'),
                                $old)"/>
      <xsl:for-each
                   select="$gu:childrenOld[gu:col(.,'ComponentType')='ASBIE']">
        <xsl:variable name="gu:oldABIEclassName"
                    select="gu:colcomp(.,'AssociatedObjectClass')"/>
        <xsl:variable name="gu:oldABIEclass"
                    select="key('gu:abie-by-name',$gu:oldABIEclassName,$old)"/>
        <xsl:variable name="gu:newABIEclass"
                    select="key('gu:abie-by-name',$gu:oldABIEclassName,$new)"/>
        <xsl:if test="empty($gu:newABIEclass)">
          <xsl:sequence select="$gu:oldABIEclass"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  <!--order the ABIEs alphabetically-->
  <xsl:for-each select="$abies,($gu:deletedABIEs/.)">
    <xsl:sort select="gu:col(.,$gu:names)"/>
    <!--the name of the ABIE is the compressed object class name-->
    <xsl:variable name="gu:abieName"
                  select="gu:col(.,$gu:names)"/>
    <xsl:variable name="gu:abieDEN"
                  select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:classNameType" 
                  select="concat( gu:col(.,'ObjectClass'),' ',
                                  $gu:abieName,' ',
                                  gu:col(.,'ComponentType'))"/>
    <xsl:choose>
      <xsl:when test="not($gu:abieDEN)">
        <xsl:call-template name="gu:row">
          <xsl:with-param name="gu:col1" select="$gu:abieName"/>
          <xsl:with-param name="gu:col3">ERROR NO DEN</xsl:with-param>
          <xsl:with-param name="summary" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(key('gu:abie-by-name',$gu:abieName,$new))">
        <xsl:call-template name="gu:row">
          <xsl:with-param name="gu:col1" select="$gu:abieName"/>
          <xsl:with-param name="gu:col3">Deleted</xsl:with-param>
          <xsl:with-param name="summary" select="$summary"/>
          <xsl:with-param name="detailDEN" select="$gu:abieDEN"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(key('gu:bie-by-class-and-name-and-type',
                              $gu:classNameType,$old))">
        <xsl:call-template name="gu:row">
          <xsl:with-param name="gu:col1" select="$gu:abieName"/>
          <xsl:with-param name="gu:map1" select="$gu:abieDEN"/>
          <xsl:with-param name="gu:col3">Added</xsl:with-param>
          <xsl:with-param name="summary" select="$summary"/>
          <xsl:with-param name="detailDEN" select="$gu:abieDEN"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="gu:childrenOld"
                      select="key('gu:bie-by-abie-class',
                                  gu:col(.,'ObjectClass'),
                                  $old)"/>
        <xsl:variable name="gu:childrenNew"
                      select="key('gu:bie-by-abie-class',
                                  gu:col(.,'ObjectClass'),
                                  $new)"/>
        <xsl:variable name="gu:thisABIEchanges" as="element()*">
          <xsl:for-each select="$gu:childrenOld">
            <xsl:variable name="gu:oldChild" select="."/>
            <xsl:variable name="gu:newChild"
                 select="$gu:childrenNew[gu:col(.,$gu:names)=
                         current()/gu:col(.,$gu:names)]"/>
            <xsl:if test="not($gu:newChild)">
              <xsl:call-template name="gu:row">
                <xsl:with-param name="gu:col2"
                                select="$gu:oldChild/gu:col(.,$gu:names)"/>
                <xsl:with-param name="gu:map2"
                      select="$gu:oldChild/gu:col(.,'DictionaryEntryName')"/>
                <xsl:with-param name="gu:col3">Deleted</xsl:with-param>
                <xsl:with-param name="summary" select="$summary"/>
                <xsl:with-param name="detailDEN"
                        select="$gu:oldChild/gu:col(.,'DictionaryEntryName')"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
          <xsl:for-each select="$gu:childrenNew">
            <xsl:variable name="gu:newChild" select="."/>
            <xsl:variable name="gu:oldChild"
                 select="$gu:childrenOld[gu:col(.,$gu:names)=
                         current()/gu:col(.,$gu:names)]"/>
            <xsl:choose>
              <xsl:when test="not($gu:oldChild)">
                <xsl:call-template name="gu:row">
                  <xsl:with-param name="gu:col2"
                                  select="$gu:newChild/gu:col(.,$gu:names)"/>
                  <xsl:with-param name="gu:map2"
                        select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                  <xsl:with-param name="gu:col3">Added</xsl:with-param>
                  <xsl:with-param name="summary" select="$summary"/>
                  <xsl:with-param name="detailDEN"
                        select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$gu:newChild/gu:col(.,'Cardinality')!=
                              $gu:oldChild/gu:col(.,'Cardinality')">
                  <xsl:call-template name="gu:row">
                    <xsl:with-param name="gu:col2"
                  select="$gu:newChild/gu:col(.,$gu:names)"/>
                    <xsl:with-param name="gu:map2"
                  select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                    <xsl:with-param name="gu:col3">
                      <xsl:text>Changed cardinality from </xsl:text>
                      <xsl:value-of 
                                select="$gu:oldChild/gu:col(.,'Cardinality')"/>
                      <xsl:text> to </xsl:text>
                      <xsl:value-of 
                                select="$gu:newChild/gu:col(.,'Cardinality')"/>
                    </xsl:with-param>
                    <xsl:with-param name="summary" select="$summary"/>
                    <xsl:with-param name="detailDEN"
                        select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                  </xsl:call-template>
                </xsl:if>
              <xsl:if test="$gu:newChild/gu:col(.,'DictionaryEntryName')!=
                            $gu:oldChild/gu:col(.,'DictionaryEntryName')">
                  <xsl:call-template name="gu:row">
                    <xsl:with-param name="gu:col2"
                 select="$gu:newChild/gu:col(.,$gu:names)"/>
                    <xsl:with-param name="gu:map2"
                  select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                    <xsl:with-param name="gu:col3">
                <xsl:text>Changed dictionary entry name from &#8220;</xsl:text>
                      <xsl:value-of 
                        select="$gu:oldChild/gu:col(.,'DictionaryEntryName')"/>
                      <xsl:text>&#8221; to &#8220;</xsl:text>
                      <xsl:value-of 
                        select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                      <xsl:text>&#8221;</xsl:text>
                      <xsl:if test="$gu:newChild/gu:col(.,'ComponentType')!=
                                    $gu:oldChild/gu:col(.,'ComponentType')">
                        <xsl:text> and changed component type from </xsl:text>
                <xsl:value-of select="$gu:oldChild/gu:col(.,'ComponentType')"/>
                        <xsl:text> to </xsl:text>
                <xsl:value-of select="$gu:newChild/gu:col(.,'ComponentType')"/>
                      </xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="summary" select="$summary"/>
                    <xsl:with-param name="detailDEN"
                        select="$gu:newChild/gu:col(.,'DictionaryEntryName')"/>
                  </xsl:call-template>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$gu:thisABIEchanges">
          <xsl:if test="$summary">
            <xsl:call-template name="gu:row">
              <xsl:with-param name="gu:col1" select="$gu:abieName"/>
              <xsl:with-param name="gu:map1" select="$gu:abieDEN"/>
              <xsl:with-param name="summary" select="$summary"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:copy-of select="$gu:thisABIEchanges"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xs:template>
  <para>Indicate a change in the table</para>
</xs:template>

<xs:template>
  <para>Add a row to the table</para>
  <xs:param name="gu:col1"><para>Column value</para></xs:param>
  <xs:param name="gu:map1"><para>Mapping to DEN for column 1</para></xs:param>
  <xs:param name="gu:col2"><para>Column value</para></xs:param>
  <xs:param name="gu:map2"><para>Mapping to DEN for column 2</para></xs:param>
  <xs:param name="gu:col3"><para>Column value</para></xs:param>
  <xs:param name="summary"><para>Indication of summary report</para></xs:param>
  <xs:param name="detailDEN"><para>Target of detail report</para></xs:param>
</xs:template>
<xsl:template name="gu:row">
  <xsl:param name="gu:col1" select="'&#xa0;'" as="xsd:string?"/>
  <xsl:param name="gu:map1" as="xsd:string?"/>
  <xsl:param name="gu:col2" select="'&#xa0;'" as="xsd:string?"/>
  <xsl:param name="gu:map2" as="xsd:string?"/>
  <xsl:param name="gu:col3" select="'&#xa0;'" as="xsd:string?"/>
  <xsl:param name="summary" as="xsd:boolean" required="yes"/>
  <xsl:param name="detailDEN" as="xsd:string?"/>
  <xsl:choose>
   <xsl:when test="$summary">
    <row>
    <xsl:if test="$gu:col1 != '&#xa0;'">
      <xsl:processing-instruction name="dbhtml"
                                >bgcolor="#DDDDDD"</xsl:processing-instruction>
      <xsl:processing-instruction name="dbfo"
                                >bgcolor="#DDDDDD"</xsl:processing-instruction>
    </xsl:if>
    <entry>
      <xsl:choose>
        <xsl:when test="$gu:map1 and $all-documents-report-href">
          <ulink conformance="skip" url=
             "{$all-documents-report-href}#Table-{translate($gu:map1,' ','')}">
            <xsl:value-of select="normalize-space($gu:col1)"/>
          </ulink>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($gu:col1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </entry>
    <entry>
      <xsl:choose>
        <xsl:when test="$gu:map2 and $all-documents-report-href">
          <ulink conformance="skip" url=
             "{$all-documents-report-href}#Table-{translate($gu:map2,' ','')}">
            <xsl:value-of select="normalize-space($gu:col2)"/>
          </ulink>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($gu:col2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </entry>
    <entry>
      <xsl:value-of select="normalize-space($gu:col3)"/>
    </entry>
    </row>
   </xsl:when>
   <xsl:otherwise>
     <!--a detailed report-->
    <xsl:for-each select="key('gu:bie-by-den',$detailDEN,
                              if( $gu:col3='Deleted' ) then $old else $new)">
      <xsl:call-template name="gu:reportDetailColumns">
        <xsl:with-param name="gu:row" select="."/>
        <xsl:with-param name="gu:deleted" select="$gu:col3='Deleted'"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:variable name="gu:targetRow"
                  select="key('gu:bie-by-den',$detailDEN,$new)"/>
    <xsl:if test="count($gu:targetRow)>1">
      <xsl:message select="'IMPORTANT: Consistency error with',
                       count($gu:targetRow),'rows with same DEN:',$detailDEN"/>
    </xsl:if>
    <xsl:if test="not($gu:col3='Deleted') and 
                  gu:col($gu:targetRow,'ComponentType')='ABIE'">
      <!--display the entirely new ABIE-->
      <xsl:for-each select="key('gu:bie-by-abie-class',
                                gu:col($gu:targetRow,'ObjectClass'),$new)">
        <xsl:call-template name="gu:reportDetailColumns">
          <xsl:with-param name="gu:row" select="."/>
          <xsl:with-param name="gu:deleted" select="false()"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:template>
  <para>Display a detail row</para>
  <xs:param name="gu:row"><para>The row being reported</para></xs:param>
  <xs:param name="gu:deleted"><para>The row is being deleted</para></xs:param>
</xs:template>
<xsl:template name="gu:reportDetailColumns">
  <xsl:param name="gu:row" as="element(Row)"/>
  <xsl:param name="gu:deleted" as="xsd:boolean"/>
  <xsl:variable name="gu:colNames"
    select="('Cardinality','AlternativeBusinessTerms','Examples',
    'DictionaryEntryName', (:'ObjectClassQualifier',:)'ObjectClass',
    'PropertyTermQualifier', 'PropertyTermPossessiveNoun',
    'PropertyTermPrimaryNoun','PropertyTerm', 'RepresentationTerm',
    'DataTypeQualifier','DataType', (:'AssociatedObjectClassQualifier',:)
    'AssociatedObjectClass', 'ComponentType','UNTDEDCode','CurrentVersion',
    'EditorsNotes')"/>
  <tr 
    style="background-color:{if( $gu:deleted ) then '#DDDDDD'
              else if( gu:col($gu:row,'ComponentType')='ABIE' ) then '#FFC0CB'
              else if( gu:col($gu:row,'ComponentType')='ASBIE' ) then '#CCFFCC'
              else '#FFFFFF'}">
    <td rowspan="2" style="border:1px solid black;vertical-align:top">
      <xsl:value-of select="count($gu:row/preceding-sibling::Row)+1"/>
    </td>
    <td rowspan="2" style="border:1px solid black;vertical-align:top">
      <xsl:value-of select="gu:col($gu:row,'ComponentName')"/>
    </td>
    <td valign="top" colspan="{count($gu:colNames)}"
        style="border:1px solid black;vertical-align:top">
      <xsl:value-of select="gu:col($gu:row,'Definition')"/>
    </td>
  </tr>
  <tr style="background-color:{if( $gu:deleted ) then '#DDDDDD'
              else if( gu:col($gu:row,'ComponentType')='ABIE' ) then '#FFC0CB'
              else if( gu:col($gu:row,'ComponentType')='ASBIE' ) then '#CCFFCC'
              else '#FFFFFF'}">
    <xsl:for-each select="$gu:colNames">
      <td style="border:1px solid black;vertical-align:top">
        <xsl:value-of select="gu:col($gu:row,.)"/>
      </td>
    </xsl:for-each>
  </tr>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>Convert the DocBook to HTML</xs:title>
</xs:doc>

<xs:variable>
  <para>Translation table</para>
</xs:variable>
<xsl:variable name="gu:xlate" as="element()+">
  <xlate from="table"/>
  <xlate from="title" to="h2"/>
  <xlate from="tgroup" to="table">
    <attrs style="border:1px solid black;border-collapse:collapse"/>
  </xlate>
  <xlate from="thead"/>
  <xlate from="tbody"/>
  <xlate from="colspec"/>
  <xlate from="row" to="tr"/>
    <attrs style="border:1px solid black"/>
  <xlate from="entry" grandparent="thead" to="th">
  </xlate>
  <xlate from="entry" grandparent="tbody" to="td">
    <attrs style="border:1px solid black"/>
  </xlate>
  <xlate from="td" preserve="yes"/>
  <xlate from="th" preserve="yes"/>
  <xlate from="tr" preserve="yes"/>
  <xlate from="ulink" to="span"/>
</xsl:variable>

<xs:template>
  <para>Translate table constructs</para>
</xs:template>

<xs:template>
  <para>Convert elements</para>
</xs:template>
<xsl:template match="*" mode="gu:db2html">
  <xsl:variable name="gu:this" 
                select="$gu:xlate[name(current())=@from]
                          [not(@grandparent) or
                           name(current()/parent::*/parent::*)=@grandparent]"/>
  <xsl:choose>
    <xsl:when test="not($gu:this)">
      <xsl:message select="'Not handled:',name(.)"/>
    </xsl:when>
    <xsl:when test="$gu:this/@preserve">
      <xsl:element name="{name(.)}">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="gu:db2html"/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="not($gu:this/@to)">
      <!--simply process contents-->
      <xsl:apply-templates mode="gu:db2html"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="{$gu:this/@to}">
        <xsl:copy-of select="$gu:this/attrs/@*"/>
        <xsl:for-each select="processing-instruction()[contains(.,'bgcolor')]">
          <xsl:attribute name="style" 
  select="concat('background-color:',replace(.,'.*&quot;(.+)&quot;.*','$1'))"/>
        </xsl:for-each>
        <xsl:apply-templates mode="gu:db2html"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:variable>
  <para>A new-line sequence for use in attributes</para>
</xs:variable>
<xsl:variable name="gu:nl" as="xsd:string">
  <xsl:text>
</xsl:text>
</xsl:variable>

<xs:variable>
  <para>Establish all problems.</para>
</xs:variable>
<xsl:variable name="gu:collectAllErrors" as="element()*" select="
  
(:NDR reports:)
$gu:MOD01-DABIE-list,
$gu:MOD02-DABIE-refs,
if( $gu:ignore-sort-rule ) then () else $gu:MOD03-CABIE-order,
$gu:COM01-structured-values,
$gu:COM02-prohibited-values,
$gu:COM03-abbreviated-name-values,
$gu:COM04-abbreviated-DEN-values,
$gu:COM06-invalid-component-type,
$gu:COM07-ABIE-construction,
$gu:COM08-BBIE-construction,
$gu:COM09-ASBIE-construction,
$gu:COM10-dictionary-entry-name-uniqueness,
$gu:COM11-invalid-name-values,
$gu:COM12-invalid-name-values,
$gu:COM13-ABIE-empty,
$gu:COM14-ABIE-order,

(:Non-fatal backward compatibility observations:)
if( $old is $new ) then () else (
$gu:missing,
$gu:qdt,
$gu:qdtnew,
$gu:badcard,
$gu:order,
(: $gu:orderName - archaic, replaced with $gu:order :)
$gu:badVersion
),

(:XSD access:)
if( not($gu:xsd-check) ) then () else (
$gu:FRG01-maindoc-fragments,
$gu:FRG02-fragment-declarations,
$gu:FRG03-fragment-type-declarations,
$gu:FRG04-library-ABIE-fragment
),

(:Fatal subset compatibility issues:)
if( not($gu:activeSubsetting) ) then () else (
$gu:badcardsub
)
  "/>

</xsl:stylesheet>

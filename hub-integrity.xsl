<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:my="urn:X-Crane"
  exclude-result-prefixes="xsd my"
  version="2.0">

<!--
    $Id: hub-integrity.xsl,v 1.15 2019/08/06 19:44:23 admin Exp $
    Generate hub content based on directory contents 
-->

<xsl:output indent="yes"/>
  
<xsl:param name="hub-uri" required="yes"/>
<xsl:param name="gc-uri" required="yes"/>
<xsl:param name="ref-uri"/>
<xsl:param name="pub-version" required="yes"/>

<xsl:variable name="hub" select="document(translate($hub-uri,'\','/'))"/>
<xsl:variable name="gc" select="document(translate($gc-uri,'\','/'))"/>

<xsl:variable name="dir" select="/"/>

<xsl:key name="dir" match="directory" use="my:path(@absolutePath)"/>

<xsl:key name="rows" match="Row" use="my:col(.,'DictionaryEntryName')"/>

<xsl:key name="ids" match="*[@id]" use="@id"/>

<xsl:key name="linkends" match="@linkend" use="."/>

<xsl:function name="my:row" as="element(Row)*">
  <xsl:param name="DEN" as="item()?"/>
  <xsl:sequence select="$DEN/key('rows',.,$gc)"/>
</xsl:function>

<xsl:function name="my:col" as="element(SimpleValue)*">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:param name="columnName" as="xsd:string+"/>
  <xsl:sequence select="$row/Value[@ColumnRef=$columnName]/SimpleValue"/>
</xsl:function>

<xsl:function name="my:xpath" as="xsd:string">
  <xsl:param name="node" as="node()"/>
  <xsl:value-of>
    <xsl:for-each select="$node/ancestor-or-self::*">
      <xsl:text/>/<xsl:value-of select="name(.)"/>
      <xsl:if test="position()>1">
        <xsl:text/>[<xsl:number/>]<xsl:text/>
      </xsl:if>
    </xsl:for-each>
  </xsl:value-of>
</xsl:function>

<xsl:function name="my:path" as="xsd:string">
  <xsl:param name="abs" as="attribute()"/>
  <xsl:sequence
    select="substring(substring-after($abs,root($abs)/directory/@absolutePath),
                      2)"/>
</xsl:function>

<xsl:key name="hub" match="*[@role]" use="@role"/>

<xsl:template match="/directory" priority="1">
  <!--document list summary-->
  <xsl:variable name="documentSchemas"
                select="key('hub','documentSchemas',$hub)/section except
                        key('hub','documentSchemasIntroduction',$hub)"/>
  
  <!--code list summary-->
  <xsl:variable name="codelists" as="element(simplelist)">
    <simplelist role="codelists">
      <xsl:for-each select="key('dir','cl')//file">
        <member>
          <literal>
            <ulink url="{my:path(@absolutePath)}">
              <xsl:value-of select="my:path(@absolutePath)"/>
            </ulink>
          </literal>
        </member>
      </xsl:for-each>
    </simplelist>
  </xsl:variable>
  
  <!--example summary-->
  <xsl:variable name="examplesFileSummary" as="element(member)+">
    <xsl:for-each select="key('dir','xml')//file/my:path(@absolutePath)">
      <xsl:sort select="." lang="en"/>
      <member>
        <literal>
          <ulink url="{.}"><xsl:value-of select="."/></ulink>
        </literal>
      </member>
    </xsl:for-each>
  </xsl:variable>
  
  <!--all files-->
  <xsl:variable name="alldirs"
                select="//directory except (:remove known exceptions:)
         (key('dir','archive-only-not-in-final-distribution')/(.,.//directory),
          key('dir','art/artpdf')/(.,.//directory),
          key('dir','db')/(.,.//directory),
          key('dir','val/lib'),
          key('dir','xsdrt/common')
         )"/>
  <xsl:variable name="allfiles" 
                select="$alldirs/file/my:path(@absolutePath)"/>
  <xsl:variable name="exceptionmatchstring" 
                select="(:remove known exceptions from the list:)
                        concat('(
                                ( Legend\d.png ) |
                                ( art/oasis-spec.css ) |
                                ( val/notices- ) |
                                ( art/OASISLogo.jpg ) |
                                ( ^UBL-',$pub-version,'\.(xml|html|pdf)$ )
                               )')"/>
  <xsl:variable name="allfiles"
                select="$allfiles[not(matches(.,$exceptionmatchstring,'x'))]"/>
  <xsl:variable name="hubreferences"
                select="$hub//*/(@url,@fileref,@arch)
                                 [not(starts-with(.,'http') or
                                      starts-with(.,'mailto') or
                                      starts-with(.,'ftp'))]"/>
  <xsl:variable name="hubreferences"
                select="for $each in $hubreferences return
                        if( contains($each,'#') )
                            then substring-before($each,'#')
                            else $each"/>
  
<!--  <xsl:message select="count(/directory//directory),count($alldirs)"/>
  <xsl:for-each select="$alldirs">
    <xsl:message select="my:path(@absolutePath),'&#xa;'"/>
  </xsl:for-each>
  <xsl:message terminate="yes"/>-->
  
  <results>
    <dirs>
      <xsl:for-each select="/directory/directory
                   except key('dir','archive-only-not-in-final-distribution')">
        <dir><xsl:value-of select="my:path(@absolutePath)"/></dir>
      </xsl:for-each>
    </dirs>
    <blockquote role="summaryExamples">
      <xsl:variable name="exceptions" 
                    select="key('hub','nonSchemaExamples',$hub)//ulink"/>
      <simplelist>
        <xsl:copy-of select="$examplesFileSummary[not(.//ulink=$exceptions)]"/>
      </simplelist>
    </blockquote>
    <xsl:copy-of select="$codelists"/>
  <!--report differences-->
  <xsl:variable name="errors" as="xsd:string">
    <xsl:value-of>
      
      <!--check the consistency of the list of code lists-->
      <xsl:variable name="hub-gc" select="key('hub','codelists',$hub)"/>
      <xsl:for-each select="$codelists//ulink[not(.=$hub-gc//ulink)]">
        <xsl:text>File code list not in hub document: </xsl:text>
        <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="$hub-gc//ulink[not(.=$codelists//ulink)]">
        <xsl:text>Hub code list not in distribution: </xsl:text>
        <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
      
      <!--check the consistency of the list of examples-->
      <xsl:variable name="ubl-exSummary" 
                    select="key('hub','examples',$hub)//ulink"/>
      <xsl:variable name="exampleMissingInDocumentation"
                    select="$examplesFileSummary[not(.=$ubl-exSummary)]"/>
      <xsl:if test="$exampleMissingInDocumentation">
        <xsl:for-each select="$exampleMissingInDocumentation">
          <xsl:value-of select="'File example not in hub summary:',."/>
          <xsl:value-of select="'&#xa;'"/>
        </xsl:for-each>
      </xsl:if>
      <xsl:variable name="exampleMissingInDistribution"
                    select="$ubl-exSummary[not(.=$examplesFileSummary)]"/>
      <xsl:if test="$exampleMissingInDistribution">
        <xsl:for-each select="$exampleMissingInDistribution">
          <xsl:value-of select="'Summary example not in files:',."/>
          <xsl:value-of select="'&#xa;'"/>
        </xsl:for-each>
      </xsl:if>
      
      <!--check the consistency of the schema description examples-->
      <xsl:variable name="ubl-schemaExamples"
                    select="key('hub','schemaExample',$hub)//ulink"/>
      <xsl:variable name="ubl-schemaSummaryExamples"
                    select="key('hub','summaryExamples',$hub)//ulink"/>
      <xsl:variable name="exampleMissingInDocumentation"
              select="$ubl-schemaSummaryExamples[not(.=$ubl-schemaExamples)]"/>
      <xsl:if test="$exampleMissingInDocumentation">
        <xsl:for-each select="$exampleMissingInDocumentation">
          <xsl:value-of select="'Summary example not in schema examples:',."/>
          <xsl:value-of select="'&#xa;'"/>
        </xsl:for-each>
      </xsl:if>
      <xsl:variable name="exampleMissingInDistribution"
              select="$ubl-schemaExamples[not(.=$ubl-schemaSummaryExamples)]"/>
      <xsl:for-each select="$exampleMissingInDistribution">
        <xsl:value-of select="'Schema example not in distribution:',."/>
        <xsl:value-of select="'&#xa;'"/>
      </xsl:for-each>
      <xsl:variable name="unsortedSchemaExamples" as="document-node()">
        <xsl:document>
          <xsl:for-each select="$ubl-schemaSummaryExamples">
            <example>
              <xsl:value-of select="position(),."/>
            </example>
          </xsl:for-each>
        </xsl:document>
      </xsl:variable>
      <xsl:variable name="sortedSchemaExamples" as="document-node()">
        <xsl:document>
          <xsl:for-each select="$ubl-schemaSummaryExamples">
            <xsl:sort select="." lang="en"/>
            <example>
              <xsl:value-of select="position(),."/>
            </example>
          </xsl:for-each>
        </xsl:document>
      </xsl:variable>
      <xsl:if test="not(deep-equal($unsortedSchemaExamples,
                                   $sortedSchemaExamples))">
        <xsl:text>The schema examples summary list is out of sorted order:
 </xsl:text>
        <xsl:value-of select="$unsortedSchemaExamples/
                              example[not(.=$sortedSchemaExamples/example)]/
                              concat(.,'&#xa;')"/>
        <xsl:text>Sorted:
 </xsl:text>
        <xsl:value-of select="$sortedSchemaExamples/
                              example[not(.=$unsortedSchemaExamples/example)]/
                              concat(.,'&#xa;')"/>
      </xsl:if>
    
    <!--check the entire list of references against all files-->
    <xsl:for-each select="distinct-values($hubreferences)[not(.=$allfiles)]">
      <xsl:text>Hub reference not found in files: </xsl:text>
      <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="distinct-values($allfiles)[not(.=$hubreferences)]">
      <xsl:text>File found not referenced in hub: </xsl:text>
      <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
      
    <!-- DEN references -->

    <xsl:for-each select="key('hub','DEN-Row',$hub)">
      <xsl:if test="not(ends-with(@url,translate(@remap,' ','')))">
        <xsl:text>url= does not end with compact DEN: </xsl:text>
        <xsl:value-of select="@remap"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="my:xpath(.)"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:if>
      <xsl:variable name="row" select="my:row(@remap)"/>
      <xsl:choose>
        <xsl:when test="not($row)">
          <xsl:text>DEN not found: </xsl:text>
          <xsl:value-of select="@remap"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="my:xpath(.)"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="model" select="my:col($row,'ModelName')"/>
          <xsl:variable name="rowNum" select="
          2+count($row/preceding-sibling::Row[my:col(.,'ModelName')=$model])"/>
          <xsl:if test=". != $rowNum">
            <xsl:value-of select="concat('Mismatched row number ',.,
                                         ' (should be ',$rowNum,')')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="my:xpath(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="key('hub','DEN-Name',$hub)">
      <xsl:if test="not(ends-with(@url,translate(@remap,' ','')))">
        <xsl:text>url= does not end with compact DEN: </xsl:text>
        <xsl:value-of select="@remap"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="my:xpath(.)"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:if>
      <xsl:variable name="row" select="my:row(@remap)"/>
      <xsl:choose>
        <xsl:when test="not($row)">
          <xsl:text>DEN not found: </xsl:text>
          <xsl:value-of select="@remap"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="my:xpath(.)"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="name"
                  select="my:col(my:row(@remap),('UBLName','ComponentName'))"/>
          <xsl:if test=". != $name">
            <xsl:value-of select="concat('Mismatched element name ',.,
                                         ' (should be ',$name,')')"/>
           <xsl:text> </xsl:text>
           <xsl:value-of select="my:xpath(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
      
    <!--updated schema documents listing-->
    <xsl:variable name="updateDocumentSchemas"
                  select="( key('hub','newDocumentTypes10',$hub),
                            key('hub','newDocumentTypes20',$hub),
                            key('hub','newDocumentTypes21',$hub),
                            key('hub','newDocumentTypes22',$hub),
                            key('hub','newDocumentTypes23',$hub)
                          )//link"/>
    <xsl:variable name="updateDocumentSchemaTitles"
         select="$updateDocumentSchemas/normalize-space(concat(.,' Schema'))"/>
    <xsl:for-each select="$updateDocumentSchemaTitles
                          [not(normalize-space(.)=
                           $documentSchemas/normalize-space(title))]">
      <xsl:text>Update annex schema not found in master list: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="$documentSchemas/title
                        [not(normalize-space(.)=$updateDocumentSchemaTitles)]">
      <xsl:text>Schema not found in update annex list: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="$updateDocumentSchemas
   [not(@linkend=concat('S-',translate(upper-case(normalize-space(.)),' ','-'),
                        '-SCHEMA'))]">
<xsl:text>Update annex list schema not pointing to correct schema section: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
      
    <!--normative references-->
    <xsl:for-each select="key('hub','norm-refs',$hub)//bibliomixed">
      <xsl:if test="not(key('linkends',(@id,'')[1],$hub))">
      <xsl:text>Orphaned normative reference: </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>&#xa;</xsl:text>
      </xsl:if>
    </xsl:for-each>

    <!--normative references-->
    <xsl:for-each select="key('hub','non-norm-refs',$hub)//bibliomixed">
      <xsl:if test="not(key('linkends',(@id,'')[1],$hub))">
      <xsl:text>Orphaned non-normative reference: </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>&#xa;</xsl:text>
      </xsl:if>
    </xsl:for-each>
      
    <!--process summary links-->
    <xsl:variable name="referencedProcesses"
                 select="key('hub','processLinkSummary',$hub)//xref/@linkend"/>
    <xsl:variable name="availableProcesses"
                  select="key('hub','processes',$hub)//
                          (section except 
                       key('hub','processLinkSummary',$hub)/ancestor::section)
                          [not( @role = 'process-introduction' )]/
                          @id"/>
   
    <xsl:for-each select="$referencedProcesses[not(.=$availableProcesses)]">
      <xsl:text>Process summary reference outside of processes: </xsl:text>
      <xsl:value-of select="key('ids',.,$hub)/title"/>
      <xsl:text>&#xa;</xsl:text>      
    </xsl:for-each>
    <xsl:for-each select="$availableProcesses[not(.=$referencedProcesses)]">
      <xsl:text>Process summary not referenced: </xsl:text>
      <xsl:value-of select="key('ids',.,$hub)/title"/>
      <xsl:text>&#xa;</xsl:text>      
    </xsl:for-each>
    <xsl:for-each select="$referencedProcesses">
      <!--check section structure of references matches authored structure-->
      <xsl:variable name="parentReference"
                    select="ancestor::itemizedlist[1]
                    [not(@role='processLinkSummary')]/../para//xref/@linkend"/>
      <xsl:if test="$parentReference !=
                    key('ids',.,$hub)/parent::section/@id">
        <xsl:text>Incorrect ancestor order in reference summary: </xsl:text>
        <xsl:value-of select="key('ids',.,$hub)/title"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:if>
      <!--check section siblings match authored siblings-->
      <xsl:variable name="precedingReference"
                  select="ancestor::listitem[1]/preceding-sibling::listitem[1]/
                          para//xref/@linkend"/>
      <xsl:if test="$precedingReference !=
                    key('ids',.,$hub)/preceding-sibling::section[1]/@id">
        <xsl:text>Incorrect sibling order in reference summary: </xsl:text>
        <xsl:value-of select="key('ids',.,$hub)/title"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:if>
      <!--check leaves of the referencing tree-->
      <xsl:if test="empty(ancestor::listitem[1]/itemizedlist) and
                    exists($availableProcesses[.=current()]/..//
                           link[ends-with(@linkend,'-SCHEMA')])">
        <!--check that emphasized points to sections with latest documents-->  
        <xsl:variable name="thisReference" select="."/>
        <xsl:for-each select="$availableProcesses[.=current()]/..">
          <xsl:variable name="referencedSchemas"
                        select=".//link[ends-with(@linkend,'-SCHEMA')]"/>
          <xsl:variable name="referencedSchemaDENs"
                        select="distinct-values(
                                $referencedSchemas/concat(.,'. Details'))"/>
<!--          <xsl:message select="'DEBUG',$pub-version"/>
          <xsl:message select="'DEBUG',string($thisReference),$referencedSchemas/concat('''',.,'. Details'''),exists($thisReference/ancestor::emphasis),$referencedSchemas/count(key('rows',concat(.,'. Details'),$gc)),$referencedSchemas/key('rows',concat(.,'. Details'),$gc)/concat(Value[@ColumnRef='ComponentName']/SimpleValue,'=',
                        Value[@ColumnRef='CurrentVersion']/SimpleValue)"/>-->
          <xsl:choose>
            <xsl:when test="exists($thisReference/ancestor::emphasis)">
              <!--there must be at least one of the current pub version-->
             <xsl:if test="not( some $den in $referencedSchemaDENs
                                satisfies key('rows',$den,$gc)/
                                Value[@ColumnRef='CurrentVersion']/SimpleValue=
                                $pub-version )">
             <xsl:text>Referencing section inappropriately emphasized: </xsl:text>
               <xsl:value-of select="$thisReference"/>
               <xsl:text> because of </xsl:text>
               <xsl:value-of select="$referencedSchemas
                             [key('rows',concat(.,'. Details'),$gc)/
                              Value[@ColumnRef='CurrentVersion']/SimpleValue !=
                              $pub-version]/
                              concat(string(.),'=',
                                     key('rows',concat(.,'. Details'),$gc)/
                              Value[@ColumnRef='CurrentVersion']/SimpleValue)"
                              separator=", "/>
               <xsl:text>&#xa;</xsl:text>
             </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <!--there cannot be any of the current pub version-->
             <xsl:if test="some $den in $referencedSchemaDENs
                           satisfies key('rows',$den,$gc)/
                           Value[@ColumnRef='CurrentVersion']/SimpleValue =
                           $pub-version">
             <xsl:text>Referencing section needs to be emphasized: </xsl:text>
               <xsl:value-of select="$thisReference"/>
               <xsl:text> because of </xsl:text>
               <xsl:value-of select="$referencedSchemas
                             [key('rows',concat(.,'. Details'),$gc)/
                              Value[@ColumnRef='CurrentVersion']/SimpleValue =
                              $pub-version]/
                              concat(string(.),'=',
                                     key('rows',concat(.,'. Details'),$gc)/
                               Value[@ColumnRef='CurrentVersion']/SimpleValue)"
                               separator=", "/>
               <xsl:text>&#xa;</xsl:text>
             </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>        
      </xsl:if>
    </xsl:for-each>
      
    <!--check artwork-->
    <xsl:variable name="art"
                  select="key('dir','art')//file/@name
                                 [not(.=('oasis-spec.css','OASISLogo.jpg'))]"/>
    <xsl:variable name="artpdf"
                  select="key('dir','art/artpdf')//file/@name"/>
    <xsl:for-each select="$art[not(.=$artpdf)]">
      <xsl:text>HTML art not found in PDF art: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>      
    <xsl:for-each select="$artpdf[not(.=$art)]">
      <xsl:text>PDF art not found in HTML art: </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>      
    <!--end of the one string of error messages-->
    </xsl:value-of>
  </xsl:variable>
  <xsl:if test="string($errors)">
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message/>
    <xsl:message select="$errors"/>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <xsl:message>!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</xsl:message>
    <errors>
      <xsl:value-of select="$errors"/>
    </errors>
  </xsl:if>
  </results>
  <xsl:if test="$ref-uri">
    <xsl:result-document href="{$ref-uri}" indent="yes">
      <xsl:apply-templates select="$hub/node()" mode="refs"/>
    </xsl:result-document>
  </xsl:if>
</xsl:template>

<xsl:template match="section[@role=('norm-refs','non-norm-refs')]//abbrev"
              mode="refs">
  <xsl:call-template name="copyElement"/>
  <bibliomisc>
    <xsl:for-each select="key('linkends',../@id,$hub)">
      <link linkend="{(../@id,generate-id(..))[1]}">
        <xsl:text/>(<xsl:value-of select="position()"/>)<xsl:text/> 
      </link>
    </xsl:for-each>
  </bibliomisc>
</xsl:template>

<xsl:template match="xref[key('linkends',@linkend,$hub)]" mode="refs">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="id" select="(@id,generate-id(.))[1]"/>
    <xsl:apply-templates mode="refs"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="refs" name="copyElement">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="refs"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|comment()|processing-instruction()|text()" mode="refs">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
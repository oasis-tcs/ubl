<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: checkgc4obdndr-model.xsl,v 1.33 2020/06/04 17:50:11 admin Exp $"
        filename="checkgc4obdndr-model.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Check new model against old</xs:title>
  <para>
    This reads in an old and new OASIS Business Document NDR entities file,
    checking that the model properties in the new file do not violate those
    in the old file.
  </para>
</xs:doc>

<xs:function>
  <para>Compress a value</para>
  <xs:param name="value">
    <para>The value to be compressed</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:compress" as="xsd:string?">
  <xsl:param name="value" as="xsd:string?"/>
  <xsl:sequence select="translate(normalize-space($value),' ','')"/>
</xsl:function>

<xs:key>
  <para>Look up words in the abbreviations</para>
</xs:key>
<xsl:key name="gu:abbrev" match="abbreviation" use="."/>

<xs:function>
  <para>Return the abbreviation of a value or the compressed value</para>
  <xs:param name="gu:value">
    <para>The value to be abbreviated</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:abbrev" as="xsd:string?">
  <xsl:param name="gu:value" as="xsd:string?"/>
  <xsl:sequence select=
      "(key('gu:abbrev',$gu:value,$config)/@short,gu:compress($gu:value))[1]"/>
</xsl:function>

<xs:variable>
  <para>Noun/term equivalences</para>
</xs:variable>
<xsl:variable name="gu:nameTermEquivalences" as="element()*"
              select="$config/*/ndr/equivalences/equivalence"/>

<xs:function>
  <para>Return an indication of the two values being equivalent.</para>
  <xs:param name="gu:ptprn">
    <para>The property term primary noun</para>
  </xs:param>
  <xs:param name="gu:rt">
    <para>The representation term.</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:equivalent" as="xsd:boolean">
  <xsl:param name="gu:ptprn" as="xsd:string?"/>
  <xsl:param name="gu:rt" as="xsd:string?"/>
  <xsl:sequence select="( $gu:ptprn = $gu:rt ) or
           exists($gu:nameTermEquivalences
              [$gu:ptprn = primary-noun and $gu:rt = representation-term])"/>
</xsl:function>

<!--========================================================================-->
<xs:doc>
  <xs:title>Non-fatal backward compatibility observations</xs:title>
</xs:doc>

<xs:variable>
  <para>What BIE's are missing?</para>
</xs:variable>
<xsl:variable name="gu:missing" as="element(ndrinfo)*">
  <xsl:for-each select="$old//Row">
    <xsl:variable name="gu:objectClass"
                  select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:oldClassNameType"
                  select="concat( gu:col(.,'ObjectClass'),' ',
                                  gu:col(.,$gu:names),' ',
                                  gu:col(.,'ComponentType'))"/>
    <xsl:variable name="gu:oldDEN"
                 select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:newDEN"
              select="key('gu:bie-by-class-and-name-and-type',
                          $gu:oldClassNameType,$new)
                      [gu:col(.,'ObjectClass')=$gu:objectClass]/
                      gu:col(.,'DictionaryEntryName')"/>

    <xsl:if test="not(key('gu:bie-by-den',$gu:oldDEN,$new)) and
                  exists($gu:newDEN)">
      <ndrinfo gu:den="{$gu:oldDEN}" gu:var="gu:missing"
               gu:newden="{$gu:newDEN}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>What QDT's are missing?</para>
</xs:variable>
<xsl:variable name="gu:qdt" as="element(ndrinfo)*">
  <xsl:for-each select="$old//Row[gu:col(.,'DataTypeQualifier')]">
    <xsl:variable name="gu:oldDEN"
                  select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:canat"
                 select="concat(gu:col(.,'ObjectClass'),' ',
                                gu:col(.,$gu:names),' ',
                                gu:col(.,'ComponentType'))"/>
    <xsl:variable name="gu:oldDTQ"
                  select="gu:col(.,'DataTypeQualifier')"/>
    <xsl:variable name="gu:newCaNaT"
                  select="key('gu:bie-by-class-and-name-and-type',
                              $gu:canat,$new)"/>
    <xsl:if test="exists($gu:newCaNaT) and
                  not($gu:newCaNaT/gu:col(.,'DataTypeQualifier')=$gu:oldDTQ)">
      <ndrinfo gu:den="{$gu:oldDEN}" old="{$gu:oldDTQ}" gu:var="gu:qdt"
           new="{key('gu:bie-by-den',$gu:oldDEN,$new)/
                 gu:col(.,'DataTypeQualifier')}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>What QDT's are new?</para>
</xs:variable>
<xsl:variable name="gu:qdtnew" as="element(ndrinfo)*">
  <xsl:variable name="gu:oldDTQ" 
           select="distinct-values($old//Row/gu:col(.,'DataTypeQualifier'))"/>
  <xsl:for-each select="$new//Row[gu:col(.,'DataTypeQualifier')]">
    <xsl:variable name="gu:newDEN"
                 select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:newDTQ"
                 select="gu:col(.,'DataTypeQualifier')"/>
    <xsl:if test="not($gu:newDTQ = $gu:oldDTQ)">
      <ndrinfo gu:den="{$gu:newDEN}" new="{$gu:newDTQ}" gu:var="gu:qdtnew"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<!--========================================================================-->
<xs:doc>
  <xs:title>Fatal backward compatibility issues</xs:title>
</xs:doc>

<xs:variable>
  <para>What are the allowed cardinalities going from old model to new?</para>
</xs:variable>
<xsl:variable name="gu:allowedOld2New" as="element(allow)*">
            <allow old="0">
              <allowed>0..1</allowed>
              <allowed>0..n</allowed>
            </allow>
            <allow old="0..1">
              <allowed>0..1</allowed>
              <allowed>0..n</allowed>
            </allow>
            <allow old="0..n">
              <allowed>0..n</allowed>
            </allow>
            <allow old="1">
              <allowed>0..1</allowed>
              <allowed>0..n</allowed>
              <allowed>1</allowed>
              <allowed>1..n</allowed>
            </allow>
            <allow old="1..n">
              <allowed>1..n</allowed>
              <allowed>0..n</allowed>
            </allow>
</xsl:variable>

<xs:variable>
  <para>What are the allowed cardinalities?</para>
</xs:variable>
<xsl:variable name="gu:badcard" as="element(ndrbad)*">
  <!--check that any old cardinality isn't being violated by the new card-->
  <xsl:for-each select="$old/*/*/Row[gu:col(.,'Cardinality')]">
    <xsl:variable name="gu:den"
                 select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:canat"
                 select="concat(gu:col(.,'ObjectClass'),' ',
                                gu:col(.,$gu:names),' ',
                                gu:col(.,'ComponentType'))"/>
    <xsl:variable name="gu:oldCardinality"
                  select="gu:col(.,'Cardinality')"/>
    <xsl:variable name="gu:newCaNaT"
                  select="key('gu:bie-by-class-and-name-and-type',
                              $gu:canat,$new)"/>
    <xsl:variable name="gu:newCardinality"
                  select="$gu:newCaNaT/gu:col(.,'Cardinality')"/>
    <xsl:if test="exists( $gu:newCaNaT ) and
                  not($gu:newCardinality=
                      $gu:allowedOld2New[@old=$gu:oldCardinality]/allowed)">
      <ndrbad gu:den="{$gu:den}" old="{$gu:oldCardinality}" gu:var="gu:badcard"
             new="{$gu:newCardinality}"/>
    </xsl:if>
  </xsl:for-each>
  <!--check new ones found in old ABIEs for being allowed to be in new-->
  <xsl:for-each
      select="$old/*/*/Row[gu:col(.,'ComponentType')='ABIE']">
    <xsl:variable name="gu:objectClass"
                  select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:oldItems" 
                  select="key('gu:bie-by-abie-class',$gu:objectClass,$old)"/>
    <xsl:variable name="gu:newItems"
                  select="key('gu:bie-by-abie-class',$gu:objectClass,$new)"/>
    <xsl:variable name="gu:oldItemsDEN"
                  select="$gu:oldItems/gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:oldItemsName"
                  select="$gu:oldItems/gu:col(.,$gu:names)"/>
    <!--find all new not already in old-->
    <xsl:for-each select="$gu:newItems
              [not(gu:col(.,$gu:names) = $gu:oldItemsName)]">
      <xsl:variable name="gu:newCardinality" select="gu:col(.,'Cardinality')"/>
      <xsl:if test=
                "not($gu:newCardinality=$gu:allowedOld2New[@old='0']/allowed)">
       <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}" gu:var="gu:badcard"
               old="0" new="{$gu:newCardinality}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>What model re-ordering has been done? (by testing object class)</para>
</xs:variable>
<xsl:variable name="gu:order" as="element(ndrbad)*">
 <xsl:for-each select="$old//Row[gu:col(.,'ComponentType')='ABIE']">
  <xsl:variable name="gu:DEN" select="gu:col(.,'DictionaryEntryName')"/>
  <xsl:variable name="gu:objectClass" select="gu:col(.,'ObjectClass')"/>
   <xsl:if test="exists(key('gu:bie-by-abie-class',$gu:objectClass,$new))">
    <xsl:variable name="gu:oldMembers"
                  select="key('gu:bie-by-abie-class',$gu:objectClass,$old)/
                         gu:col(.,$gu:names)"/>
    <!--replicate the old order-->
    <xsl:variable name="gu:oldOrder" as="document-node()">
      <xsl:document>
        <xsl:for-each select="$gu:oldMembers">
          <element name="{.}"/>
        </xsl:for-each>
      </xsl:document>
    </xsl:variable>
    <!--replicate the new order-->
    <xsl:variable name="gu:newOrder" as="document-node()">
      <xsl:document>
        <xsl:for-each
                  select="key('gu:bie-by-abie-class',$gu:objectClass,$new)/
                          gu:col(.,$gu:names)
                          [.=$gu:oldMembers]">
          <element name="{.}"/>
        </xsl:for-each>
      </xsl:document>
    </xsl:variable>
    <!--compare the orders-->
    <xsl:if test="not( deep-equal( $gu:oldOrder, $gu:newOrder ) )">
      <ndrbad class="{$gu:objectClass}" gu:var="gu:order"
              gu:den="{$gu:DEN}">
        <old><xsl:copy-of select="$gu:oldOrder/*[position()>1]"/></old>
        <new><xsl:copy-of select="$gu:newOrder/*[position()>1]"/></new>
        <new-unfiltered>
        <xsl:for-each
                     select="key('gu:bie-by-abie-class',$gu:objectClass,$new)
                             [position()>1]">
          <element name="{gu:col(.,$gu:names)}"
                   gu:den="{gu:col(.,'DictionaryEntryName')}"/>
        </xsl:for-each>
        </new-unfiltered>
      </ndrbad>
    </xsl:if>
   </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Constitute comparable ABIE elements from GC input of old model</para>
</xs:variable>
<xsl:variable name="gu:oldnames" as="element(ABIE)*">
  <xsl:for-each-group select="$old//Row"
                     group-starting-with="*[gu:col(.,'ComponentType')='ABIE']">
    <ABIE name="{gu:col(.,$gu:names)}"
          gu:den="{gu:col(.,'DictionaryEntryName')}"
          class="{gu:col(.,'ObjectClass')}">
      <xsl:for-each select="current-group()[position()>1]">
        <xsl:if test="string(gu:col(.,'ComponentType'))">
          <xsl:element name="{gu:col(.,'ComponentType')}">
            <xsl:attribute name="name"
                           select="gu:col(.,$gu:names)"/>
            <xsl:attribute name="cardinality"
                         select="gu:col(.,'Cardinality')"/>
            <xsl:attribute name="den"
                 select="gu:col(.,'DictionaryEntryName')"/>
            <xsl:for-each select="gu:col(.,'AssociatedObjectClass')">
              <xsl:attribute name="associatedObjectClass" select="."/>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </ABIE>
  </xsl:for-each-group>
</xsl:variable>

<xs:key>
  <para>Keep track of ABIEs by their name</para>
</xs:key>
<xsl:key name="gu:internalABIEsByName" match="ABIE" use="@name"/>

<xs:variable>
  <para>Constitute comparable ABIE elements from GC input of new model</para>
</xs:variable>
<xsl:variable name="gu:newnames" as="element(ABIE)*">
  <xsl:for-each-group select="$new//Row"
                    group-starting-with="*[gu:col(.,'ComponentType')='ABIE']">
    <ABIE name="{gu:col(.,$gu:names)}"
          gu:den="{gu:col(.,'DictionaryEntryName')}"
          class="{gu:col(.,'ObjectClass')}">
      <xsl:for-each select="current-group()[position()>1]">
        <xsl:element name="{gu:col(.,'ComponentType')}">
          <xsl:attribute name="name"
                         select="gu:col(.,$gu:names)"/>
          <xsl:attribute name="cardinality"
                       select="gu:col(.,'Cardinality')"/>
          <xsl:attribute name="den"
               select="gu:col(.,'DictionaryEntryName')"/>
          <xsl:for-each select="gu:col(.,'AssociatedObjectClass')">
            <xsl:attribute name="associatedObjectClass" select="."/>
          </xsl:for-each>
        </xsl:element>
      </xsl:for-each>
    </ABIE>
  </xsl:for-each-group>
</xsl:variable>

<xs:variable>
  <para>Prune the new names of those not in old, leaving only old</para>
</xs:variable>
<xsl:variable name="gu:newnamesPrunedToOnlyOld" as="element(ABIE)*">
  <xsl:for-each select="$gu:newnames/*">
    <xsl:variable name="gu:oldname" 
               select="$gu:oldnames/key('gu:internalABIEsByName',@name,$old)"/>
    <!--preserve those ABIEs of old that are in new-->
    <xsl:if test="$gu:oldname">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:for-each select="*">
          <!--preserve those BBIEs and ASBIEs of old that are in new, plus
              any mandatory that are in new (shouldn't be any!)-->
          <xsl:if test="starts-with(@cardinality,'1') or
                        $gu:oldname/*[@name=current()/@name]">
            <xsl:copy-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:copy>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>What model re-ordering has been done? (by testing entity names)</para>
</xs:variable>
<xsl:variable name="gu:orderName" as="element(ndrbad)*">
  <xsl:for-each select="$gu:oldnames/*">
    <xsl:variable name="gu:oldname" select="."/>
    <xsl:variable name="gu:newname"
               select="$gu:newnames/key('gu:internalABIEsByName',@name,$new)"/>
    <xsl:variable name="gu:newnameEdited"
select="$gu:newnamesPrunedToOnlyOld/key('gu:internalABIEsByName',@name,$new)"/>
    <xsl:variable name="gu:problem" as="xsd:string?">
      <xsl:value-of>
      <xsl:for-each select="*">
        <xsl:variable name="gu:newchild"
                      select="$gu:newnameEdited/*[@name=current()/@name]"/>
        <xsl:if test="position() != 
                      count( $gu:newchild/preceding-sibling::* )+1">
          bad position
        </xsl:if>
        <xsl:if test="not( $gu:newchild/@cardinality = 
                    $gu:allowedOld2New[@old=current()/@cardinality]/allowed )">
          bad cardinality
        </xsl:if>
      </xsl:for-each>
      </xsl:value-of>
    </xsl:variable>

    <xsl:if test="$gu:problem">
      <ndrbad gu:var="gu:orderName">
        <xsl:copy-of select="$gu:oldname,$gu:newname,$gu:newnameEdited"/>
      </ndrbad>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<!--========================================================================-->
<xs:doc>
  <xs:title>Fatal subset compatibility issues</xs:title>
</xs:doc>

<xs:variable>
  <para>What are the allowed cardinalities going from old model to new?</para>
</xs:variable>
<xsl:variable name="gu:allowedOld2Subset" as="element(allow)*">
            <allow old="0">
              <allowed>0</allowed>
            </allow>
            <allow old="0..1">
              <allowed>0</allowed>
              <allowed>0..1</allowed>
              <allowed>1</allowed>
            </allow>
            <allow old="0..n">
              <allowed>0</allowed>
              <allowed>0..n</allowed>
              <allowed>0..1</allowed>
              <allowed>1</allowed>
              <allowed>1..n</allowed>
            </allow>
            <allow old="1">
              <allowed>1</allowed>
            </allow>
            <allow old="1..n">
              <allowed>1..n</allowed>
              <allowed>1</allowed>
            </allow>
</xsl:variable>

<xs:variable>
  <para>What are the allowed cardinalities?</para>
</xs:variable>
<xsl:variable name="gu:badcardsub" as="element(ndrbad)*">
  <xsl:variable name="gu:newCardinalityColumn" 
                select="($gu:subsetColumnName,'Cardinality')[1]"/>
  <!--check subset cardinality against the base cardinality-->
  <xsl:if test="$gu:activeSubsetting">
    <xsl:for-each select="$new/*/*/Row[not(gu:col(.,'ComponentType')='ABIE')]">
      <xsl:variable name="gu:den"
                   select="gu:col(.,'DictionaryEntryName')"/>
      <!--looking at the applicable cardinality...-->
      <xsl:variable name="gu:oldCardinality"
                    select="normalize-space(gu:col(.,'Cardinality'))"/>
      <xsl:for-each select="(
              normalize-space(gu:col(.,$gu:subsetColumnName))[string(.)],
              gu:col(.,'Cardinality')[$gu:absentSubsetIsZero]
                                     [starts-with(normalize-space(.),'0')]/'0',
              normalize-space(gu:col(.,'Cardinality')))[1]">
        <!--is the subset acceptable given the current cardinality?-->
        <xsl:if test="not($gu:allowedOld2Subset[@old=$gu:oldCardinality]/
                          allowed[.=current()])">
           <ndrbad gu:den="{$gu:den}" old="{$gu:oldCardinality}" 
                   gu:var="gu:badcardsub" subset="{.}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:if>
</xsl:variable>

<!--========================================================================-->
<xs:doc>
  <xs:title>NDR reports</xs:title>
</xs:doc>

<xs:variable>
  <para>The list of all model names</para>
</xs:variable>
<xsl:variable name="gu:modelList" as="element(SimpleValue)*"
              select="$gu:allDocumentABIEnames"/>

<xs:variable>
  <para>The list of document models</para>
</xs:variable>
<xsl:variable name="gu:MOD01-DABIE-list" as="element(ndrinfo)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs">
    <xsl:variable name="gu:den" select="gu:col(.,'DictionaryEntryName')"/>
    <ndrinfo gu:model="{gu:col(.,'ObjectClass')}"
            gu:den="{$gu:den}" gu:var="gu:MOD01"
            gu:onlyOld="{empty(key('gu:bie-by-den',$gu:den,$new))}"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>References to document ABIEs</para>
</xs:variable>
<xsl:variable name="gu:MOD02-DABIE-refs" as="element(ndrbad)*">
  <xsl:for-each select="$gu:allSubsetBIEs
            [gu:col(.,'AssociatedObjectClass')=$gu:subsetDocumentABIEclasses]">
    <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}" gu:var="gu:MOD02"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>The ordering of library models</para>
</xs:variable>
<xsl:variable name="gu:MOD03-CABIE-order" as="element()*">
    <xsl:if test="$gu:ignore-sort-rule">
      <ndrinfo gu:class="(MOD03 error status ignored by invocation request)"/>
    </xsl:if>
    <xsl:for-each select="key('gu:bie-by-type','ABIE',$new)
                          [gu:col(.,'ModelName')=$gu:thisCommonLibraryModel]
                          [position()>1]">
      <xsl:if 
        test="preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1]/
              gu:col(.,'ObjectClass') > gu:col(.,'ObjectClass')">
        <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}" gu:var="gu:MOD03"
               gu:class="{gu:col(.,'ObjectClass')}"/>
      </xsl:if>
    </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>The presence of a foreign element for extension</para>
</xs:variable>
<xsl:variable name="gu:MOD04-extension-available" as="element()*">
  <xsl:choose>
    <xsl:when test="empty($xsd-maindoc-dir-uri)">
      <ndrinfo message="(no schema information provided for checking)"/>
    </xsl:when>
    <xsl:otherwise>
      <ndrinfo message="(schema checking for this is not yet implemented)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xs:variable>
  <para>All values grouped for various analyses</para>
</xs:variable>
<xsl:variable name="gu:allNewValues" as="element()*"
              select="$gu:gc/*/SimpleCodeList/Row/Value/*"/>

<xs:variable>
  <para>CCTS description values</para>
</xs:variable>
<xsl:variable name="gu:COM01-structured-values" as="element(ndrbad)*">
  <xsl:for-each select="$gu:allNewValues/..">
    <xsl:if test="count(*)!=1 or count(*/*)>0 or normalize-space(.)=''">
      <ndrbad gu:den="{gu:col(..,'DictionaryEntryName')}" gu:var="gu:COM01"
             gu:column="{../@ColumnRef}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>CCTS invalid values</para>
</xs:variable>
<xsl:variable name="gu:COM02-prohibited-values" as="element(ndrbad)*">
  <xsl:for-each select="$gu:allNewValues">
    <xsl:if test="matches(.,'([&lt;&gt;&amp;\r\t]|--|\n[^$])','s')">
      <ndrbad gu:den="{gu:col(../..,'DictionaryEntryName')}" gu:var="gu:COM02"
             gu:column="{../@ColumnRef}" gu:value="{.}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which columns are sensitive name columns?</para>
</xs:variable>
<xsl:variable name="gu:allDENRelatedColumns" as="xsd:string*"
              select="'ObjectClassQualifier',
                      'ObjectClass',
                      'AssociatedObjectClassQualifier',
                      'AssociatedObjectClass',
                      'PropertyTermQualifier',
                      'PropertyTermPossessiveNoun',
                      'PropertyTermPrimaryNoun',
                      'RepresentationTerm',
                      'DataTypeQualifier'"/>

<xs:variable>
  <para>The list of allowed abbreviations in element names.</para>
</xs:variable>
<xsl:variable name="gu:allowedAbbreviationsInNameValues" as="attribute()*"
              select="$config/*/ndr/name-abbreviations/abbreviation/@short"/>

<xs:variable>
  <para>The list of allowed abbreviations in dictionary entry names.</para>
</xs:variable>
<xsl:variable name="gu:allowedAbbreviationsInDENValues" as="attribute()*"
              select="$config/*/ndr/den-abbreviations/abbreviation/@short"/>

<xs:variable>
  <para>CCTS invalid abbreviations in names</para>
</xs:variable>
<xsl:variable name="gu:COM03-abbreviated-name-values" as="element(ndrbad)*">
 <xsl:for-each select="$gu:allNewValues[../@ColumnRef=$gu:names]">
  <xsl:variable name="gu:value" select="."/>
  <!--break up the name with spaces and then tokenize into pieces-->
  <!--split after a sequence of digits, after two capitals that come before a
      capital followed by lowercase (e.g. UBLVersion->UBL Version), and
      between a lower-case followed by uppercase (e.g. VersionID->Version ID)
  -->
  <xsl:for-each select="tokenize(replace(
                                   replace(
                                     replace(.,'(\d)([^\d])','$1 $2'),
                                           '([A-Z][A-Z])([A-Z][a-z])','$1 $2'),
                                           '([a-z])([A-Z])','$1 $2'),
                                         '[^\w\d]+')">
    <!--if the piece has an abbreviation, then it better be allowed-->
    <xsl:if test="matches(.,'([A-Z][A-Z])|([a-zA-Z]\d)|(\d[a-zA-Z])') and 
                  not(. = $gu:allowedAbbreviationsInNameValues)">
      <ndrbad gu:den="{gu:col($gu:value/../..,'DictionaryEntryName')}"
              gu:var="gu:COM03" gu:abbrev="{.}"
              gu:column="{$gu:value/../@ColumnRef}" gu:value="{$gu:value}"/>
    </xsl:if>
  </xsl:for-each>
 </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>CCTS invalid abbreviations in dictionary entry name components</para>
</xs:variable>
<xsl:variable name="gu:COM04-abbreviated-DEN-values" as="element(ndrbad)*">
 <xsl:for-each
             select="$gu:allNewValues[../@ColumnRef=$gu:allDENRelatedColumns]">
  <xsl:variable name="gu:value" select="."/>
  <!--break up the name with spaces and then tokenize into pieces-->
  <!--split after a sequence of digits, after two capitals that come before a
      capital followed by lowercase (e.g. UBLVersion->UBL Version), and
      between a lower-case followed by uppercase (e.g. VersionID->Version ID)
  -->
  <xsl:for-each select="tokenize(replace(
                                   replace(
                                     replace(.,'(\d)([^\d])','$1 $2'),
                                           '([A-Z][A-Z])([A-Z][a-z])','$1 $2'),
                                           '([a-z])([A-Z])','$1 $2'),
                                         '[^\w\d]+')">
    <!--if the piece has an abbreviation, then it better be allowed-->
    <xsl:if test="matches(.,'([A-Z][A-Z])|([a-zA-Z]\d)|(\d[a-zA-Z])') and 
                  not(. = $gu:allowedAbbreviationsInDENValues)">
      <ndrbad gu:den="{gu:col($gu:value/../..,'DictionaryEntryName')}"
              gu:var="gu:COM04" gu:abbrev="{.}"
              gu:column="{$gu:value/../@ColumnRef}" gu:value="{$gu:value}"/>
    </xsl:if>
  </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>CCTS invalid component type</para>
</xs:variable>
<xsl:variable name="gu:COM06-invalid-component-type" as="element(ndrbad)*">
  <xsl:for-each select="$gu:gc/*/*/Row
            [not(gu:col(.,'ComponentType')=('ABIE','BBIE','ASBIE'))]">
    <ndrbad gu:den="{
       for $den in string(gu:col(.,'DictionaryEntryName')) return
       if( normalize-space($den) ) then $den else
       for $name in string(gu:col(.,'ComponentName')) return
       if( normalize-space($name) ) then $name else
       for $model in string(gu:col(.,'ModelName')) return
       if( normalize-space($model) )
       then concat( 'Model ',$model,' row ',
                    count(preceding-sibling::Row
                    [gu:col(.,'ModelName')=$model] ) ) 
       else '(no DEN, no name, no model)' }" 
            gu:var="gu:COM06"
            gu:type="{for $type in string(gu:col(.,'ComponentType')) return
                     if( normalize-space($type) ) then $type else '(empty)'}"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>ABIE checks</para>
</xs:variable>
<xsl:variable name="gu:COM07-ABIE-construction" as="element(ndrbad)*">
  <xsl:for-each select="key('gu:bie-by-type','ABIE',$new)">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:den"  select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:name" select="gu:col(.,$gu:names)"/>
<xsl:variable name="gu:ocq"  select="gu:col(.,'ObjectClassQualifier')"/>
<xsl:variable name="gu:oc"   select="gu:col(.,'ObjectClass')"/>
<!--redefine DEN as name or unknown if there is no DEN-->
<xsl:variable name="gu:den" 
              select="if( $gu:den ) then $gu:den else
                      if( $gu:name ) then $gu:name else '(no DEN or name)'"/>
    <xsl:if test="normalize-space(gu:col(.,'Definition'))=''">
      <ndrbad gu:den="{$gu:den}" gu:column="Definition" gu:value="(empty)"
             gu:var="gu:COM07"/>
    </xsl:if>
    <xsl:if test="normalize-space($gu:oc)=''">
      <ndrbad gu:den="{$gu:den}" gu:column="ObjectClass" gu:value="(empty)"
             gu:var="gu:COM07"/>
    </xsl:if>
    <xsl:variable name="gu:expectedName"
                  select="concat(gu:abbrev($gu:ocq),gu:abbrev($gu:oc))"/>
    <xsl:if test="not( $gu:name = $gu:expectedName)">
      <ndrbad gu:den="{$gu:den}" gu:var="gu:COM07"
           gu:column="{$gu:name/../@ColumnRef}"
           gu:value="{($gu:name,'(empty)')[1]}"
           gu:expected="{$gu:expectedName}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedDEN" select="
 concat( if( $gu:ocq ) then concat($gu:ocq,'_ ') else '',$gu:oc,'. Details')"/>
    <xsl:if test="not( $gu:den = $gu:expectedDEN )">
      <ndrbad gu:den="{$gu:den}" gu:column="DictionaryEntryName"
              gu:var="gu:COM07"
              gu:value="{$gu:den}" gu:expected="{$gu:expectedDEN}"/>
    </xsl:if>
    <xsl:variable name="gu:row" select="."/>
    <xsl:for-each select="for $gu:each in 
     ('Cardinality','PropertyTermQualifier',
      'PropertyTermPossessiveNoun','PropertyTermPrimaryNoun',
      'PropertyTerm','RepresentationTerm','DataTypeQualifier',
      'DataType','AssociatedObjectClassQualifier','AssociatedObjectClass')
                          return gu:col($gu:row,$gu:each)/$gu:each">
      <ndrbad gu:den="{$gu:den}" gu:column="{.}" gu:var="gu:COM07"
              gu:unexpected="" gu:value="{gu:col($gu:row,.)}"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>BBIE checks</para>
</xs:variable>
<xsl:variable name="gu:COM08-BBIE-construction" as="element(ndrbad)*">
  <xsl:for-each select="key('gu:bie-by-type','BBIE',$new)">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:name"  select="gu:col(.,$gu:names)"/>
<xsl:variable name="gu:card"  select="gu:col(.,'Cardinality')"/>
<xsl:variable name="gu:den"   select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:ocq"   select="gu:col(.,'ObjectClassQualifier')"/>
<xsl:variable name="gu:oc"    select="gu:col(.,'ObjectClass')"/>
<xsl:variable name="gu:ptq"   select="gu:col(.,'PropertyTermQualifier')"/>
<xsl:variable name="gu:ptpsn" select="gu:col(.,'PropertyTermPossessiveNoun')"/>
<xsl:variable name="gu:ptprn" select="gu:col(.,'PropertyTermPrimaryNoun')"/>
<xsl:variable name="gu:pt"    select="gu:col(.,'PropertyTerm')"/>
<xsl:variable name="gu:dt"    select="gu:col(.,'DataType')"/>
<xsl:variable name="gu:rt"    select="gu:col(.,'RepresentationTerm')"/>
<xsl:variable name="gu:dtq"   select="gu:col(.,'DataTypeQualifier')"/>
<!--redefine DEN as name or unknown if there is no DEN-->
<xsl:variable name="gu:den" 
              select="if( $gu:den ) then $gu:den else
                      if( $gu:name ) then $gu:name else '(no DEN or name)'"/>
    <xsl:if test="not( $gu:card=('0..1','1','0..n','1..n') )">
      <ndrbad gu:den="{$gu:den}" gu:column="Cardinality"
              gu:value='"{$gu:card}"' gu:var="gu:COM08"/>
    </xsl:if>
    <xsl:if test="normalize-space(gu:col(.,'Definition'))=''">
      <ndrbad gu:den="{$gu:den}" gu:column="Definition" gu:value="(empty)"
             gu:var="gu:COM08"/>
    </xsl:if>
    <xsl:if test="normalize-space($gu:oc)=''">
      <ndrbad gu:den="{$gu:den}" gu:column="ObjectClass" gu:value="(empty)"
             gu:var="gu:COM08"/>
    </xsl:if>
    <xsl:if test="normalize-space($gu:ptprn)=''">
      <ndrbad gu:den="{$gu:den}" gu:column="PropertyTermPrimaryNoun"
             gu:value="(empty)" gu:var="gu:COM08"/>
    </xsl:if>
    <xsl:variable name="gu:expectedPT" select="
            concat( $gu:ptpsn, if( $gu:ptpsn ) then ' ' else '', $gu:ptprn )"/>
    <xsl:if test="not( $gu:pt = $gu:expectedPT )">
      <ndrbad gu:den="{$gu:den}" gu:column="PropertyTerm" gu:var="gu:COM08"
             gu:value="{$gu:pt}" gu:expected="{$gu:expectedPT}"/>
    </xsl:if>
    <xsl:if test="not( $gu:rt = $config/*/ndr/types/type )">
      <ndrbad gu:den="{$gu:den}" gu:column="RepresentationTerm"
              gu:var="gu:COM08" gu:value="{$gu:rt}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedName"
       select="concat(gu:abbrev($gu:ptq),
                      gu:abbrev($gu:ptpsn),
                      if( $gu:ptprn!='Text' or 
                          ( not($gu:ptq) and not($gu:ptpsn) ) )
                        then gu:abbrev($gu:ptprn) else '',
                      if( $gu:rt!='Text' and
                          not(gu:equivalent($gu:ptprn,$gu:rt)))
                        then gu:abbrev($gu:rt) else ''
                      )"/>
    <xsl:if test="not( $gu:name = $gu:expectedName)">
      <ndrbad gu:den="{$gu:den}" gu:var="gu:COM08"
              gu:column="{$gu:name/../@ColumnRef}"
              gu:value="{($gu:name,'(empty)')[1]}"
              gu:expected="{$gu:expectedName}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedDEN" select="concat
      ( $gu:ocq, if( $gu:ocq ) then '_ ' else '',$gu:oc,'. ',
        $gu:ptq, if( $gu:ptq ) then '_ ' else '',$gu:pt,
        if( $gu:ptq or ( $gu:pt != $gu:rt ) ) then concat( '. ',$gu:rt) else ''
      )"/>      
    <xsl:if test="not( $gu:den = $gu:expectedDEN )">
      <ndrbad gu:den="{$gu:den}" gu:column="DictionaryEntryName" 
              gu:var="gu:COM08"
              gu:value="{$gu:den}" gu:expected="{$gu:expectedDEN}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedDT" select="concat
              ( $gu:dtq, if( $gu:dtq ) then '_ ' else '', $gu:rt, '. Type' )"/>
    <xsl:if test="not( $gu:dt = $gu:expectedDT )">
      <ndrbad gu:den="{$gu:den}" gu:column="DataType" gu:var="gu:COM08"
             gu:value="{$gu:dt}" gu:expected="{$gu:expectedDT}"/>
    </xsl:if>
    <xsl:variable name="gu:row" select="."/>
    <xsl:for-each select="for $gu:each in ('AssociatedObjectClassQualifier',
                                           'AssociatedObjectClass')
                          return gu:col($gu:row,$gu:each)/$gu:each">
      <ndrbad gu:den="{$gu:den}" gu:column="{.}" gu:var="gu:COM08"
              gu:unexpected="" gu:value="{gu:col($gu:row,.)}"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>ASBIE checks</para>
</xs:variable>
<xsl:variable name="gu:COM09-ASBIE-construction" as="element(ndrbad)*">
  <xsl:for-each select="key('gu:bie-by-type','ASBIE',$new)[gu:isSubsetBIE(.)]">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:name"  select="gu:col(.,$gu:names)"/>
<xsl:variable name="gu:card"  select="gu:col(.,'Cardinality')"/>
<xsl:variable name="gu:den"   select="gu:col(.,'DictionaryEntryName')"/>
<xsl:variable name="gu:ocq"   select="gu:col(.,'ObjectClassQualifier')"/>
<xsl:variable name="gu:oc"    select="gu:col(.,'ObjectClass')"/>
<xsl:variable name="gu:aocq" 
                          select="gu:col(.,'AssociatedObjectClassQualifier')"/>
<xsl:variable name="gu:aoc"   select="gu:col(.,'AssociatedObjectClass')"/>
<xsl:variable name="gu:ptq"   select="gu:col(.,'PropertyTermQualifier')"/>
<xsl:variable name="gu:ptpsn" select="gu:col(.,'PropertyTermPossessiveNoun')"/>
<xsl:variable name="gu:ptprn" select="gu:col(.,'PropertyTermPrimaryNoun')"/>
<xsl:variable name="gu:pt"    select="gu:col(.,'PropertyTerm')"/>
<xsl:variable name="gu:dt"    select="gu:col(.,'DataType')"/>
<xsl:variable name="gu:rt"    select="gu:col(.,'RepresentationTerm')"/>
<xsl:variable name="gu:dtq"   select="gu:col(.,'DataTypeQualifier')"/>
<!--redefine DEN as name or unknown if there is no DEN-->
<xsl:variable name="gu:den" 
              select="if( $gu:den ) then $gu:den else
                      if( $gu:name ) then $gu:name else '(no DEN or name)'"/>
    <xsl:if test="not( $gu:card=('0..1','1','0..n','1..n') )">
      <ndrbad gu:den="{$gu:den}" gu:column="Cardinality"
              gu:value='"{$gu:card}"' gu:var="gu:COM09"/>
    </xsl:if>
    <xsl:if test="normalize-space(gu:col(.,'Definition'))=''">
      <ndrbad gu:den="{$gu:den}" gu:column="Definition" gu:value="(empty)"
             gu:var="gu:COM09"/>
    </xsl:if>
    <xsl:if test="normalize-space($gu:oc)=''">
      <ndrbad gu:den="{$gu:den}" gu:column="ObjectClass" gu:value="(empty)"
             gu:var="gu:COM09"/>
    </xsl:if>
    <xsl:if test="normalize-space($gu:aoc)=''">
      <ndrbad gu:den="{$gu:den}" gu:column="AssociatedObjectClass"
              gu:var="gu:COM09" gu:value="(empty)"/>
    </xsl:if>
    <xsl:if test="not( ( $new/key('gu:bie-by-abie-class',$gu:aoc,.),
                         $base-gc/key('gu:bie-by-abie-class',$gu:aoc,.) )
              [string(gu:col(.,'ObjectClassQualifier')) = string($gu:aocq)]
              [ if( not( $gu:activeSubsetting ) ) then true() else
                ( some $gu:bie in key('gu:bie-by-abie-class',$gu:aoc)
                  satisfies not( gu:minMaxBothZero($gu:bie) ) ) ] )">
      <ndrbad gu:den="{$gu:den}" gu:column="AssociatedObjectClass"
              gu:var="gu:COM09" gu:message=" (missing ABIE)"
    gu:value="{concat( $gu:aocq, if( $gu:aocq ) then '_ ' else '', $gu:aoc)}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedPT" select="
                concat( $gu:aocq, if( $gu:aocq ) then '_ ' else '', $gu:aoc)"/>
    <xsl:if test="not( $gu:pt = $gu:expectedPT )">
      <ndrbad gu:den="{$gu:den}" gu:column="PropertyTerm" gu:var="gu:COM09"
             gu:value="{$gu:pt}" gu:expected="{$gu:expectedPT}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedName"
       select="concat(gu:abbrev($gu:ptq),gu:abbrev($gu:pt))"/>
    <xsl:if test="not( $gu:name = $gu:expectedName)">
      <ndrbad gu:den="{$gu:den}" gu:var="gu:COM09"
           gu:column="{$gu:name/../@ColumnRef}"
           gu:value="{($gu:name,'(empty)')[1]}"
           gu:expected="{$gu:expectedName}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedDEN" select="
                  concat( $gu:ocq, if( $gu:ocq ) then '_ ' else '',$gu:oc,'. ',
                          $gu:ptq, if( $gu:ptq ) then '_ ' else '',$gu:pt,
                          if( $gu:ptq ) then concat( '. ',$gu:rt) else '' 
                        )"/>      
    <xsl:if test="not( $gu:den = $gu:expectedDEN )">
      <ndrbad gu:den="{$gu:den}" gu:column="DictionaryEntryName"
              gu:var="gu:COM09" gu:value="{$gu:den}"
              gu:expected="{$gu:expectedDEN}"/>
    </xsl:if>
    <xsl:variable name="gu:expectedRT" select="$gu:pt"/>
    <xsl:if test="not( $gu:rt = $gu:expectedRT )">
      <ndrbad gu:den="{$gu:den}" gu:column="DataType" gu:var="gu:COM09"
             gu:value="{$gu:rt}" gu:expected="{$gu:expectedRT}"/>
    </xsl:if>
    <xsl:variable name="gu:row" select="."/>
    <xsl:for-each select="for $gu:each in ('DataTypeQualifier', 'DataType',
                       'PropertyTermPossessiveNoun','PropertyTermPrimaryNoun' )
                          return gu:col($gu:row,$gu:each)/$gu:each">
      <ndrbad gu:den="{$gu:den}" gu:column="{.}" gu:var="gu:COM06"
              gu:unexpected="" gu:value="{gu:col($gu:row,.)}"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Duplicate dictionary entry names</para>
</xs:variable>
<xsl:variable name="gu:COM10-dictionary-entry-name-uniqueness"
              as="element(ndrbad)*">
  <xsl:for-each-group select="$gu:allBIEs"
                      group-by="gu:col(.,'DictionaryEntryName')">
    <xsl:if test="count(current-group())>1">
      <ndrbad gu:den="{current-grouping-key()}" gu:var="gu:COM10"
           gu:models="{distinct-values(current-group()/gu:col(.,'ModelName'))}"
           gu:value="{.}"/>
    </xsl:if>
  </xsl:for-each-group>
  <xsl:for-each select="$gu:gc/*/*/Row[not(gu:col(.,'DictionaryEntryName'))]">
    <ndrbad gu:den="{
       for $name in string(gu:col(.,'ComponentName')) return
       if( normalize-space($name) ) then $name else
       for $model in string(gu:col(.,'ModelName')) return
       if( normalize-space($model) )
       then concat( 'Model ',$model,' row ',
                    count(preceding-sibling::Row
                    [gu:col(.,'ModelName')=$model] ) ) 
       else '(no name, no model)'} - empty or absent DEN"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Name value violations - characters</para>
  <para>This could be improved by distinguishing a BBIE check from
        an ASBIE check, as a qualified ABIE for an ASBIE introduces
        the "_" which is invalid.  Since no qualified ABIEs yet, no
        rush to change this.</para>
</xs:variable>
<xsl:variable name="gu:COM11-invalid-name-values" as="element(ndrbad)*">
  <xsl:for-each
            select="$gu:allNewValues[../@ColumnRef=$gu:allDENRelatedColumns]">
    <xsl:if test="contains(.,'.') or contains(.,'_') or 
                  normalize-space(.) != .">
      <ndrbad gu:den="{gu:col(../..,'DictionaryEntryName')}" gu:var="gu:COM11"
              gu:column="{../@ColumnRef}" gu:value="{.}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Name value violations - case</para>
</xs:variable>
<xsl:variable name="gu:COM12-invalid-name-values" as="element(ndrbad)*">
  <xsl:for-each
            select="$gu:allNewValues[../@ColumnRef=$gu:allDENRelatedColumns]">
    <xsl:variable name="gu:value" select="."/>
    <!--tokenize all words-->
    <xsl:for-each select="tokenize(.,'[^\w\d]+')">
      <xsl:if test="( upper-case(substring(.,1,1))!=substring(.,1,1) or
                      lower-case(substring(.,2))!=substring(.,2) )
                    and not(. = $gu:allowedAbbreviationsInNameValues)">
        <ndrbad gu:den="{gu:col($gu:value/../..,'DictionaryEntryName')}"
               gu:var="gu:COM12"
               gu:column="{$gu:value/../@ColumnRef}" gu:value="{$gu:value}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Bad ABIE children</para>
</xs:variable>
<xsl:variable name="gu:COM13-ABIE-empty" as="element(ndrbad)*">
  <xsl:for-each select="($gu:subsetDocumentABIEs,$gu:subsetLibraryABIEs)
                        [gu:isSubsetABIE(.)]">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:class" select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:bies"
                  select="key('gu:bie-by-abie-class',$gu:class,$new)
                          [gu:isSubsetBIE(.)]"/>
    <xsl:variable name="gu:refs"
       select="key('gu:asbie-by-referred-abie',$gu:class)[gu:isSubsetBIE(.)]"/>
    <xsl:if test="count($gu:refs)>0 and count($gu:bies)=0">
      <ndrbad gu:class="{$gu:class}" gu:var="gu:COM13" gu:references=
      "{string-join($gu:refs/gu:col(.,'DictionaryEntryName')/string(),', ')}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Bad ABIE children order</para>
</xs:variable>
<xsl:variable name="gu:COM14-ABIE-order" as="element(ndrbad)*">
  <xsl:for-each select="$gu:subsetDocumentABIEs,$gu:subsetLibraryABIEs">
    <xsl:sort select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:class"
                  select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:bies-by-class"
               select="key('gu:bie-by-abie-class',$gu:class,$new)
                       [gu:isSubsetBIE(.)]"/>
    <xsl:variable name="gu:bies"
            select="key('gu:bie-by-abie-position',$gu:class,$new)
                    [gu:isSubsetBIE(.)]"/>
    <xsl:variable name="gu:firstASBIE" 
                  select="$gu:bies[gu:col(.,'ComponentType')='ASBIE'][1]"/>
    <xsl:variable name="gu:lastBBIE" 
                  select="$gu:bies[gu:col(.,'ComponentType')='BBIE'][last()]"/>
    <xsl:if test="$gu:lastBBIE >> $gu:firstASBIE">
      <ndrbad gu:abie="{$gu:class}" gu:var="gu:COM14"/>
    </xsl:if>
    <xsl:if test="count($gu:bies) != count($gu:bies-by-class)">
      <ndrbad gu:abie="{$gu:class}" gu:var="gu:COM14"
      gu:foreign="{string-join(( $gu:bies[not(some $gu:bie in $gu:bies-by-class
                                              satisfies $gu:bie is .)],
                                 $gu:bies-by-class[not(some $gu:bie in $gu:bies
                                                    satisfies $gu:bie is .)] )/
                                 gu:col(.,'DictionaryEntryName'),', ')}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<!--========================================================================-->
<xs:doc>
  <xs:title>Specific reports</xs:title>
</xs:doc>

<xs:variable>
  <para>Which ABIEs are qualified (not allowed in OBD NDR)?</para>
</xs:variable>
<xsl:variable name="gu:qualifiedABIE" as="element(ndrbad)*">
  <xsl:for-each select="$new//Row[gu:col(.,'ObjectClassQualifier')]">
    <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
            gu:class="{gu:col(.,'ObjectClass')}"
            gu:var="gu:qualifiedABIE"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>
    Which ASBIEs point to ABIEs that are qualified (not supported here)?
  </para>
</xs:variable>
<xsl:variable name="gu:qualifiedASBIE" as="element(ndrbad)*">
  <xsl:for-each select="$new//Row
                        [gu:col(.,'AssociatedObjectClassQualifier')]
                        [gu:isSubsetBIE(.)]">
    <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
           gu:var="gu:qualifiedASBIE"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which Library ABIEs are orphaned?</para>
</xs:variable>
<xsl:variable name="gu:orphanLibraryABIE" as="element()*">
  <xsl:choose>
    <xsl:when test="$gu:activeSubsetting">
      <ndrinfo message="(orphans are not checked when creating a subset)"/>
    </xsl:when>
    <xsl:otherwise>
    <xsl:for-each select="$gu:allLibraryABIEs[some $gu:bie in
                            key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'))
                          satisfies not(gu:minMaxBothZero($gu:bie))]">
      <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
      <xsl:if test="not(key('gu:asbie-by-referred-abie',
                            gu:col(.,'ObjectClass'))[gu:isSubsetBIE(.)])">
        <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
                gu:class="{gu:col(.,'ObjectClass')}"
                gu:var="gu:orphanABIE"/>
      </xsl:if>
    </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xs:variable>
  <para>Which single-child ABIEs should the child be mandatory?</para>
</xs:variable>
<xsl:variable name="gu:oneChildSubsetLibraryABIE" as="element(ndrbad)*">
  <xsl:for-each select="($gu:subsetDocumentABIEs,$gu:subsetLibraryABIEs)
                        [gu:isSubsetABIE(.)]">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:class" select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:bies"
                  select="key('gu:bie-by-abie-class',$gu:class,$new)
                          [gu:isSubsetBIE(.)]"/>
    <xsl:variable name="gu:refs"
       select="key('gu:asbie-by-referred-abie',$gu:class)[gu:isSubsetBIE(.)]"/>
    <xsl:if test="count($gu:refs)>0 and count($gu:bies)=1">
      <xsl:variable name="gu:newCardinalityColumn" 
                    select="($gu:subsetColumnName,'Cardinality')[1]"/>
      <xsl:if test="starts-with($gu:bies/gu:col(.,$gu:newCardinalityColumn),
                                '0')">
        <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
                gu:class="{gu:col(.,'ObjectClass')}"
                gu:var="gu:oneChildSubsetLibraryABIE"/>
      </xsl:if>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which new elements have unexpected version </para>
</xs:variable>
<xsl:variable name="gu:mismatchedVersion" as="element(ndrbad)*">
  <xsl:variable name="gu:configVersion"
                select="$gu:configMain/*/schema/@version"/>
  <xsl:for-each select="$new//Row[gu:col(.,'ComponentType')='ABIE']">
    <xsl:sort select="gu:col(.,'ModelName')!=$gu:thisCommonLibraryModel"/>
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:class" select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:newBIEs"
            select=".,key('gu:bie-by-abie-class',$gu:class,$new)"/>
    <xsl:variable name="gu:oldBIEs"
            select="key('gu:abie-by-class',$gu:class,$old),
                    key('gu:bie-by-abie-class',$gu:class,$old)"/>
    <!--find everything that is new in the ABIE-->
    <xsl:for-each select="$gu:newBIEs[not(gu:col(.,$gu:names)=
                                      $gu:oldBIEs/gu:col(.,$gu:names))]
                    [not(gu:col(.,$version-column-name) = $gu:configVersion)]">
      <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
              gu:version="{gu:col(.,$version-column-name)}"
              gu:var="gu:mismatchedVersion"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which old elements have unexpected version </para>
</xs:variable>
<xsl:variable name="gu:mislabelledVersion" as="element(ndrbad)*">
  <xsl:variable name="gu:configVersion"
                select="$gu:configMain/*/schema/@version"/>
  <xsl:for-each select="$new//Row[gu:col(.,'ComponentType')='ABIE']">
    <xsl:sort select="gu:col(.,'ModelName')!=$gu:thisCommonLibraryModel"/>
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:class" select="gu:col(.,'ObjectClass')"/>
    <xsl:variable name="gu:newBIEs"
            select=".,key('gu:bie-by-abie-class',$gu:class,$new)"/>
    <xsl:variable name="gu:oldBIEs"
            select="key('gu:abie-by-class',$gu:class,$old),
                    key('gu:bie-by-abie-class',$gu:class,$old)"/>
    <!--find everything that is old in the ABIE-->
    <xsl:for-each select="$gu:newBIEs[gu:col(.,$gu:names)=
                                      $gu:oldBIEs/gu:col(.,$gu:names)]
                    [gu:col(.,$version-column-name) = $gu:configVersion]">
      <ndrbad gu:den="{gu:col(.,'DictionaryEntryName')}"
              gu:var="gu:mislabelledVersion"
              gu:good="{$gu:oldBIEs[gu:col(.,'DictionaryEntryName')=
                                    gu:col(current(),'DictionaryEntryName')]/
                        gu:col(.,$version-column-name)}"
              gu:bad="{gu:col(.,$version-column-name)}"/>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which new BBIEs have unexpected cardinality</para>
</xs:variable>
<xsl:variable name="gu:bbieMultitude" as="element(ndrbad)*">
  <xsl:variable name="gu:configVersion"
                select="$gu:configMain/*/schema/@version"/>
  <xsl:for-each select="$new//Row[gu:col(.,'ComponentType')='BBIE']
                                 [not(gu:col(.,'DataType')='Text. Type')]
                                 [ends-with(gu:col(.,'Cardinality'),'n')]">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <ndrbad gu:den='{concat("""",gu:col(.,"DictionaryEntryName"),"""")}'
            gu:var="gu:bbieMultitude"
            gu:version="{gu:col(.,'CurrentVersion')}"
            gu:cardinality="{gu:col(.,'Cardinality')}"/>
  </xsl:for-each>
</xsl:variable>

<xs:variable>
  <para>Which property terms are typically prose?</para>
</xs:variable>
<xsl:variable name="gu:expectedMaindocPropertyTerms"
              as="element(property-term)*"
         select="if( $config ) 
                 then $config/*/ndr/expected-maindoc-BIEs/property-term
                 else ()"/>

<xs:variable>
  <para>Which document types are missing mandatory items?</para>
</xs:variable>
<xsl:variable name="gu:missingMandatoryMaindocBIEs" as="element(ndrbad)*">
 <xsl:if test="$gu:expectedMaindocPropertyTerms">
   
  <xsl:for-each select="$gu:subsetDocumentABIEclasses
     [not(some $gu:docName in gu:col(../..,$gu:names)
  satisfies exists( $gu:configMain//file[@abie=$gu:docName][@type='XABIE']))]">
    <xsl:variable name="gu:docBIEs"
                 select="key('gu:bie-by-abie-class',.)"/>
    <xsl:variable name="gu:modelClass" select="."/>
    
    <!--first check to see that the BIE is even present in the ABIE-->
    <xsl:for-each select="$gu:expectedMaindocPropertyTerms
                          [not($gu:docBIEs/gu:col(.,'PropertyTerm')=.)]">
      <ndrbad gu:doctype="{$gu:modelClass}"
             gu:den="{$gu:modelClass}. Details"
             gu:reason="absent"
             gu:var="gu:missingMandatoryMaindocBIEs"
             gu:propertyTerm="{.}"
             gu:expected="{.}"/>
    </xsl:for-each>
    <xsl:for-each select="$gu:docBIEs
                 [gu:col(.,'PropertyTerm')=$gu:expectedMaindocPropertyTerms]">
      <xsl:variable name="gu:this" select="."/>
      <!--check the component type-->
      <xsl:if test="gu:col(.,'ComponentType')!=
      $gu:expectedMaindocPropertyTerms[.=gu:col(current(),'PropertyTerm')]/
                              @type">
       <ndrbad gu:doctype="{$gu:modelClass}"
              gu:var="gu:missingMandatoryMaindocBIEs"
              gu:den="{gu:col(.,'DictionaryEntryName')}"
              gu:propertyTerm="{gu:col(.,'PropertyTerm')}"
              gu:type="{gu:col(.,'ComponentType')}"
              gu:expected="{$gu:expectedMaindocPropertyTerms
                       [.=gu:col(current(),'PropertyTerm')]/@type}"/>
      </xsl:if>
      <!--check cardinality of the present item-->
      <xsl:if test="gu:col(.,'Cardinality')!=
      $gu:expectedMaindocPropertyTerms[.=gu:col(current(),'PropertyTerm')]/
                              @cardinality">
       <ndrbad gu:doctype="{$gu:modelClass}"
              gu:var="gu:missingMandatoryMaindocBIEs"
              gu:den="{gu:col(.,'DictionaryEntryName')}"
              gu:propertyTerm="{gu:col(.,'PropertyTerm')}"
              gu:cardinality="{gu:col(.,'Cardinality')}"
              gu:expected="{$gu:expectedMaindocPropertyTerms
                       [.=gu:col(current(),'PropertyTerm')]/@cardinality}"/>
      </xsl:if>
      <!--check position of the present item-->
      <xsl:variable name="gu:position" 
                    select="count($gu:docBIEs[. &lt;&lt; $gu:this]) + 1"/>
      <xsl:if test="$gu:position !=
      $gu:expectedMaindocPropertyTerms[.=gu:col(current(),'PropertyTerm')]/
                              @order">
       <ndrbad gu:doctype="{$gu:modelClass}"
              gu:var="gu:missingMandatoryMaindocBIEs"
              gu:den="{gu:col(.,'DictionaryEntryName')}"
              gu:propertyTerm="{gu:col(.,'PropertyTerm')}"
              gu:position="{$gu:position}"
              gu:expected="{$gu:expectedMaindocPropertyTerms
                       [.=gu:col(current(),'PropertyTerm')]/@order}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
 </xsl:if>
</xsl:variable>

<xs:variable>
  <para>Which non-text representation terms are mismatched?</para>
</xs:variable>
<xsl:variable name="gu:nonTextRepresentationTerms" as="element(ndrinfo)*">
  <xsl:for-each select="$gu:allSubsetBBIEs">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:ptpn"
                  select="gu:col(.,'PropertyTermPrimaryNoun')"/>
    <xsl:variable name="gu:rept" select="gu:col(.,'RepresentationTerm')"/>
    <xsl:if test="$gu:rept != 'Text' and $gu:ptpn != $gu:rept and
                  not(some $gu:equivalence in $gu:nameTermEquivalences
                      satisfies ($gu:rept=$gu:equivalence/representation-term
                             and $gu:ptpn=$gu:equivalence/primary-noun))">
      <ndrinfo gu:den="{gu:col(.,'DictionaryEntryName')}"
               gu:ptpn="{$gu:ptpn}" gu:rept="{$gu:rept}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>
  
<xs:variable>
  <para>Which text representation terms are used as nouns?</para>
</xs:variable>
<xsl:variable name="gu:textRepresentationTerms" as="element(ndrinfo)*">
  <xsl:for-each select="$gu:allSubsetBBIEs">
    <xsl:sort select="gu:col(.,'DictionaryEntryName')"/>
    <xsl:variable name="gu:ptpn"
                  select="gu:col(.,'PropertyTermPrimaryNoun')"/>
    <xsl:variable name="gu:rept" select="gu:col(.,'RepresentationTerm')"/>
    <xsl:if test="$gu:rept = 'Text' and $gu:ptpn = $gu:rept">
      <ndrinfo gu:den="{gu:col(.,'DictionaryEntryName')}"
               gu:ptpn="{$gu:ptpn}"/>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>
  
<xs:variable>
  <para>Which BBIEs are duplicated?</para>
</xs:variable>
<xsl:variable name="gu:duplicateBBIEs" as="element(ndrinfo)*">
  <xsl:for-each-group select="$gu:allSubsetBBIEs"
                      group-by="gu:col(.,$gu:names)">
    <xsl:sort select="gu:col(.,$gu:names)"/>
    <xsl:if test="count(current-group())>1">
      <ndrinfo gu:name="{gu:col(.,$gu:names)}"
               gu:count="{count(current-group())}"
        gu:dens="{string-join(
            current-group()/gu:col(.,'DictionaryEntryName')/string(.),', ')}"/>
    </xsl:if>
  </xsl:for-each-group>
</xsl:variable>

<xs:variable>
  <para>Which items have qualified data types</para>
</xs:variable>
<xsl:variable name="gu:infoQDT" as="element(ndrinfo)*">
  <xsl:for-each-group select="$new//Row[gu:col(.,'DataTypeQualifier')]"
                      group-by="gu:col(.,'DataTypeQualifier')">
    <xsl:for-each select="current-group()">
      <ndrinfo gu:den="{gu:col(.,'DictionaryEntryName')}" 
               gu:qdt="{current-grouping-key()}" gu:var="gu:infoQDT"/>
    </xsl:for-each>
  </xsl:for-each-group>  
</xsl:variable>

<xs:variable>
  <para>Which new items are improperly versioned?</para>
</xs:variable>
<xsl:variable name="gu:badVersion" as="element(ndrbad)*">
  
</xsl:variable>

</xsl:stylesheet>

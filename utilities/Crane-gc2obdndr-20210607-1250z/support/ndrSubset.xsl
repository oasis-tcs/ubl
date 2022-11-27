<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs gu xsd"
                version="2.0">

<xs:doc info="$Id: ndrSubset.xsl,v 1.38 2018/10/24 23:15:55 admin Exp $"
        filename="ndrSubset.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Subset logic for schema generation</xs:title>
  <para> 
    This fragment deals with the concepts of subsetting a model
  </para>
</xs:doc>

<xs:param ignore-ns="yes">
  <para>The user can request that subsetting be done for all models</para>
</xs:param>
<xsl:param name="subset-result" as="xsd:string" select="'no'"/>

<xs:param ignore-ns="yes">
  <para>The user can request which subsetting be done for some models</para>
</xs:param>
<xsl:param name="subset-model-regex" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>The user can request that subsetting be done for some constructs</para>
</xs:param>
<xsl:param name="subset-column-name" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request that certain columns be included in documentation
  </para>
</xs:param>
<xsl:param name="doc-column-names-regex" as="xsd:string?"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request an abbreviated set of columns
  </para>
</xs:param>
<xsl:param name="abbreviate-columns" as="xsd:string" select="'no'"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request that an absent subset specification on an item with
    minimum cardinality of 0 shall be interpreted as both minimum and maximum
    values of cardinaltiy to be 0
  </para>
</xs:param>
<xsl:param name="subset-absent-is-zero" as="xsd:string" select="'no'"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request that annotations regarding the subsetting be
    suppressed.
  </para>
</xs:param>
<xsl:param name="subset-exclusions" as="xsd:string" select="'yes'"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request that elements for all types be included when
    creating a subset.  In the BDNDR there is always an element for each type.
  </para>
</xs:param>
<xsl:param name="subset-include-type-elements" as="xsd:string" select="'yes'"/>

<xs:param ignore-ns="yes">
  <para>
    The user can request that types that are never referenced are not included
  </para>
</xs:param>
<xsl:param name="subset-include-ignored-types" as="xsd:string" select="'yes'"/>

<xs:variable>
  <para>
    The user can request that an absent subset specification on an item with
    minimum cardinality of 0 shall be interpreted as both minimum and maximum
    values of cardinaltiy to be 0
  </para>
</xs:variable>
<xsl:variable name="gu:absentSubsetIsZero" as="xsd:boolean"
           select="not(starts-with('no',lower-case($subset-absent-is-zero)))"/>

<xs:variable>
  <para>
    The user can request that an absent subset specification on an item with
    minimum cardinality of 0 shall be interpreted as both minimum and maximum
    values of cardinaltiy to be 0
  </para>
</xs:variable>
<xsl:variable name="gu:subsetExclusions" as="xsd:boolean"
           select="starts-with('yes',lower-case($subset-exclusions))"/>

<xs:variable>
  <para>
    The user can request that there not be an element declared arbitrarily for
    every type.
  </para>
</xs:variable>
<xsl:variable name="gu:subsetIncludeTypeElements" as="xsd:boolean"
        select="starts-with('yes',lower-case($subset-include-type-elements))"/>

<xs:variable>
  <para>
    The user can request that types that are never referenced are not included
  </para>
</xs:variable>
<xsl:variable name="gu:subsetIncludeIgnoredTypes" as="xsd:boolean"
        select="starts-with('yes',lower-case($subset-include-ignored-types))"/>

<xs:variable ignore-ns="yes">
  <para>The user can request that subsetting be done for some constructs</para>
</xs:variable>
<xsl:variable name="gu:subsetColumnName" as="xsd:string?"
              select="translate(normalize-space($subset-column-name),' ','')"/>

<xs:key>
  <para>Determining column long names</para>
</xs:key>
<xsl:key name="gu:gcColumnName" match="Column" use="ShortName"/>

<xs:variable ignore-ns="yes">
  <para>The user can request that subsetting be done for some constructs</para>
</xs:variable>
<xsl:variable name="gu:subsetColumnNameDisplay" as="xsd:string?"
              select="key('gu:gcColumnName',$gu:subsetColumnName)/LongName"/>

<xs:variable>
  <para>Determine if subsetting is being done or not.</para>
</xs:variable>
<xsl:variable name="gu:activeSubsetting" as="xsd:boolean"
              select="string($subset-column-name) or
                      string($subset-model-regex) or
                      not(starts-with('no',lower-case($subset-result)))"/>

<xs:variable ignore-ns="yes">
  <para>The user can request an abbreviated set of columns</para>
</xs:variable>
<xsl:variable name="gu:abbreviateColumns" as="xsd:boolean"
              select="starts-with('yes',$abbreviate-columns)"/>

<xs:variable ignore-ns="yes">
  <para>The user can request columns to be included as documentation</para>
</xs:variable>
<xsl:variable name="gu:docColumns" as="element(Column)*">
  <xsl:if test="exists($doc-column-names-regex)">
    <xsl:sequence select="$gu:gc/*/ColumnSet/Column
                                [matches(ShortName,$doc-column-names-regex)]"/>
  </xsl:if>
</xsl:variable>

<xs:function>
  <para>Determine if given ABIE is in the subset</para>
  <xs:param name="gu:askABIE">
    <para>Which one is being checked</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:isSubsetABIE" as="xsd:boolean">
  <xsl:param name="gu:askABIE" as="element(Row)"/>
  <xsl:sequence select="if( not( $gu:activeSubsetting ) ) then true() else
            ( some $gu:abie in ($gu:subsetLibraryABIEs,$gu:subsetDocumentABIEs)
                   satisfies $gu:abie is $gu:askABIE )"/>
</xsl:function>

<xs:function>
  <para>Determine if given non-ABIE BIE is in the subset</para>
  <xs:param name="gu:askBIE">
    <para>Which one is being checked</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:isSubsetBIE" as="xsd:boolean">
  <xsl:param name="gu:askBIE" as="element(Row)"/>
<!--
  <xsl:message select="$gu:askBIE/( not( $gu:activeSubsetting ),
    gu:col(.,'DictionaryEntryName')/string(.),
    'ABIE:',string(gu:isSubsetABIE( $gu:askBIE/ 
              preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1] ) ),
    'BIE:',string(not(gu:minMaxBothZero($gu:askBIE))),
    '=',string(
              if( not( $gu:activeSubsetting ) ) then true() else
                        if( not( gu:isSubsetABIE( $gu:askBIE/
              preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1] ) ) )
                      then false() else not(gu:minMaxBothZero($gu:askBIE))))"/>
-->
  <xsl:sequence select="
     if( not( $gu:activeSubsetting ) ) then true() else
     if( gu:col($gu:askBIE,'ComponentType')='ABIE' )
         then gu:isSubsetABIE( $gu:askBIE ) else
     if( not( gu:isSubsetABIE( $gu:askBIE/
              preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1] ) ) )
         then false() else not( gu:minMaxBothZero($gu:askBIE) )"/>
</xsl:function>

<xs:variable>
  <para>Determine all BIEs regardless of the choice of document models.</para>
</xs:variable>
<xsl:variable name="gu:allBIEs" as="element(Row)*"
              select="$gu:gc/*/SimpleCodeList/Row"/>
  
<xs:variable>
  <para>Determine all BIEs from the choice of document models.</para>
</xs:variable>
<xsl:variable name="gu:allSubsetBIEs" as="element(Row)*"
              select="($gu:subsetDocumentABIEs,$gu:subsetLibraryABIEs)/
                      key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'))
                      [not( gu:minMaxBothZero(.) )]"/>
  
<xs:variable>
  <para>Determine all ASBIEs from all of the BIEs.</para>
</xs:variable>
<xsl:variable name="gu:allSubsetASBIEs" as="element(Row)*"
              select="$gu:allSubsetBIEs[gu:col(.,'ComponentType')='ASBIE']"/>
  
<xs:variable>
  <para>Determine all BBIEs from all of the BIEs.</para>
</xs:variable>
<xsl:variable name="gu:allSubsetBBIEs" as="element(Row)*"
              select="$gu:allSubsetBIEs[gu:col(.,'ComponentType')='BBIE']"/>
  
<xs:variable>
  <para>Determine all ASBIEs from all of the BIEs.</para>
</xs:variable>
<xsl:variable name="gu:absentSubsetASBIEs" as="element(Row)*"
              select="$gu:allSubsetASBIEs
                  [ for $gu:class in gu:col(.,'AssociatedObjectClass') return
                    ( not( key('gu:abie-by-class',$gu:class) )
                   or ( every $gu:bie in key('gu:bie-by-abie-class',$gu:class)
                        satisfies gu:minMaxBothZero( $gu:bie ) ) ) ]"/>

<xs:variable>
  <para>Determine which common library ABIEs are in the subset.</para>
</xs:variable>
<xsl:variable name="gu:allLibraryABIEs" as="element(Row)*">
  <xsl:sequence select="$gu:allBIEs[gu:col(.,'ComponentType')='ABIE']
                        [gu:col(.,'ModelName')=$gu:thisCommonLibraryModel]"/>
</xsl:variable>

<xs:variable>
  <para>Determine which common library ABIEs are in the subset.</para>
</xs:variable>
<xsl:variable name="gu:subsetLibraryABIEs" as="element(Row)*">
  <xsl:sequence select="if( $gu:activeSubsetting ) 
                        then gu:determineSubsetABIEs( $gu:subsetDocumentABIEs )
                        else $gu:allBIEs[gu:col(.,'ComponentType')='ABIE']
                          [gu:col(.,'ModelName')=$gu:thisCommonLibraryModel]"/>
</xsl:variable>

<xs:function>
  <para>Determine if a given ABIE is being used by a Document ABIE</para>
  <xs:param name="gu:determineSubsetDocumentABIEs">
    <para>The documents from which the ABIEs-in-use are found.</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:determineSubsetABIEs" as="element(Row)*">
  <xsl:param name="gu:determineSubsetDocumentABIEs" as="element(Row)*"/>

  <xsl:variable name="gu:starterASBIEassociatedObjectClassNames"
       select="$gu:determineSubsetDocumentABIEs/
               key('gu:asbie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
               [not(gu:minMaxBothZero(.))]/gu:col(.,'AssociatedObjectClass')"/>
  <xsl:variable name="gu:starterABIEs"
         select="for $each in $gu:starterASBIEassociatedObjectClassNames
            return $gu:gc/key('gu:abie-by-class',$each,.)"/>
  <xsl:sequence select="gu:searchABIEsinSubset(
      ($gu:determineSubsetDocumentABIEs,$gu:starterABIEs),
      ( for $gu:root in $gu:gc return
         $gu:starterABIEs/key('gu:asbie-by-abie-class',
                               gu:col(.,'ObjectClass')) 
                             [not( gu:minMaxBothZero(.) )]/
                          key('gu:abie-by-class',
                             gu:col(.,'AssociatedObjectClass'),$gu:root)))"/>
</xsl:function>

<xs:function>
  <para>Determine if a given ABIE is being used by a Document ABIE</para>
  <xs:param name="gu:foundRowsSoFar">
    <para>Which ABIEs are already found?</para>
  </xs:param>
  <xs:param name="gu:position">
    <para>Where are we in the set of current ASBIEs</para>
  </xs:param>
  <xs:param name="gu:checkTheseABIEs">
    <para>The ABIE rows to check</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:searchABIEsinSubset" as="element(Row)*">
  <xsl:param name="gu:foundRowsSoFar" as="element(Row)*"/>
  <xsl:param name="gu:checkTheseABIEs" as="element(Row)*"/>
  <xsl:variable name="gu:next" select="$gu:checkTheseABIEs[1]"/>
<!--  <xsl:message
            select="'FOUND',$gu:foundRowsSoFar/gu:col(.,$gu:names)/string(.)"/>
  <xsl:message
            select="'CHECK',$gu:foundRowsSoFar/gu:col(.,$gu:names)/string(.)"/>
  <xsl:message/>-->
  <xsl:choose>
    <xsl:when test="not($gu:next)">
      <xsl:sequence select="$gu:foundRowsSoFar"/>
    </xsl:when>
    <xsl:when test="some $gu:row in $gu:foundRowsSoFar
                    satisfies $gu:row is $gu:next">
      <!--already looked at this row and included it-->
      <xsl:sequence select="gu:searchABIEsinSubset($gu:foundRowsSoFar,
                                        $gu:checkTheseABIEs except $gu:next)"/>
    </xsl:when>
    <xsl:otherwise>
      <!--not already looked at this row so included it and references-->
      <xsl:sequence select="gu:searchABIEsinSubset(
                            (:add this to the set found so far:)
                            ( $gu:foundRowsSoFar, $gu:next ),
                            (:add its references to the ones being looked for:)
                            ( $gu:checkTheseABIEs,
                              ($gu:gc,$gu:gcOther)/
                              key('gu:asbie-by-abie-class',
                                  gu:col($gu:next,'ObjectClass'))
                                 [not( gu:minMaxBothZero(.) )]/
                              key('gu:abie-by-class',
                                  gu:col(.,'AssociatedObjectClass'))
                            ) except ( $gu:foundRowsSoFar, $gu:next )
                           )"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xs:template>
  <para>Check subsetting properties and report any problems</para>
  <para>The output is a series of error lines ending with a new-line.</para>
</xs:template>
<xsl:template name="gu:checkSubsetting">
  <xsl:choose>
    <xsl:when test="not($gu:activeSubsetting)">
      <!--then there is nothing to check-->
    </xsl:when>
    <xsl:when test="string($subset-column-name) and
                    not( some $gu:colName in 
                     ($gu:gc,$gu:gcOther)/*/ColumnSet/Column/ShortName
                     satisfies $gu:colName = $subset-column-name )">
      <xsl:text>No subset information found for named column: </xsl:text>
      <xsl:value-of select="$subset-column-name"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:when>
    <xsl:when test="string($subset-model-regex) and
                 ( every $gu:model in distinct-values(
              ($gu:gc,$gu:gcOther)/*/SimpleCodeList/Row/gu:col(.,'ModelName') )
                   satisfies not( matches($gu:model,$subset-model-regex) ) )">
      <xsl:text>No subset information found for model regex: </xsl:text>
      <xsl:value-of select="$subset-model-regex"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
  <xsl:for-each select="$gu:subsetLibraryABIEs">
    <xsl:variable name="gu:theseBIEs"
                 select="key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'))"/>
    <xsl:choose>
      <xsl:when test="count($gu:theseBIEs)=0">
        <xsl:text>The ABIE appears corrupted in that it has no </xsl:text>
        <xsl:text>BIEs: </xsl:text> 
        <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:when test="not( gu:isAReferencedABIE(.) )">
        <!-- don't bother checking as it is never used -->
      </xsl:when>
      <xsl:when test="not( some $gu:bie in $gu:theseBIEs
                           satisfies not( gu:minMaxBothZero($gu:bie) ) )">
        <xsl:text>An ABIE cannot have all of its members excluded </xsl:text>
        <xsl:text>in a subset: </xsl:text> 
        <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <!--one cannot lower the minimum or raise the maximum cardinality-->
    <xsl:for-each select="$gu:theseBIEs">
      <xsl:variable name="gu:oldCard"
                    select="normalize-space(gu:col(.,'Cardinality'))"/>
      <xsl:variable name="gu:newCard"
                    select="normalize-space(gu:col(.,$gu:subsetColumnName))"/>
      <xsl:choose>
        <xsl:when test="not($gu:newCard = ('','0','0..1','1','0..n','1..n'))">
          <xsl:text>Invalid value "</xsl:text>
          <xsl:value-of select="$gu:newCard"/>
          <xsl:text>" for subset cardinality: </xsl:text>
          <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
        <xsl:when test="not($gu:oldCard = ('','0..1','1','0..n','1..n'))">
          <xsl:text>Invalid value "</xsl:text>
          <xsl:value-of select="$gu:newCard"/>
          <xsl:text>" for original cardinality: </xsl:text>
          <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
        <xsl:when test="$gu:newCard=''">
          <!--not being subset-->
        </xsl:when>
        <xsl:when test="substring($gu:oldCard,1,1)='1' and
                   not( substring($gu:newCard,1,1)='1') ">
          <xsl:text>The minimum cardinality cannot be lowered </xsl:text>
          <xsl:text>from "</xsl:text>
          <xsl:value-of select="$gu:oldCard"/>
          <xsl:text>" to "</xsl:text>
          <xsl:value-of select="$gu:newCard"/>
          <xsl:text>": </xsl:text>
          <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
        <xsl:when test="
                  substring($gu:oldCard,string-length($gu:oldCard),1)='1' and
                  substring($gu:newCard,string-length($gu:newCard),1)='n' ">
          <xsl:text>The maximum cardinality cannot be raised </xsl:text>
          <xsl:text>from "</xsl:text>
          <xsl:value-of select="$gu:oldCard"/>
          <xsl:text>" to "</xsl:text>
          <xsl:value-of select="$gu:newCard"/>
          <xsl:text>": </xsl:text>
          <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:function>
  <para>Return an indication that a given ABIE is in use as an ASBIE.</para>
  <xs:param name="gu:ABIE"><para>The ABIE to check</para></xs:param>
</xs:function>
<xsl:function name="gu:isAReferencedABIE" as="xsd:boolean">
  <xsl:param name="gu:ABIE" as="element(Row)"/>
<xsl:sequence select="exists(
       ($gu:gc/key('gu:asbie-by-referred-abie',gu:col($gu:ABIE,'ObjectClass')),
   $gu:gcOther/key('gu:asbie-by-referred-abie',gu:col($gu:ABIE,'ObjectClass')))
       [gu:isSubsetBIE(.)]
                            )"/>
</xsl:function>

<xs:function>
  <para>Return an indication that a given ABIE is a document ABIE.</para>
  <xs:param name="gu:ABIE"><para>The ABIE to check</para></xs:param>
</xs:function>
<xsl:function name="gu:isADocumentABIE" as="xsd:boolean">
  <xsl:param name="gu:ABIE" as="element(Row)"/>
  <xsl:sequence
       select="gu:col($gu:ABIE,'ModelName')=$gu:subsetDocumentABIEmodelNames"/>
</xsl:function>

<xs:function>
  <para>
    Determine the minimum or maximum occurrences from cardinality, with 
    priority to the subset cardinality 
  </para>
  <xs:param name="row">
    <para>The genericode row of the BIE</para>
  </xs:param>
  <xs:param name="minimumFlag">
    <para>Indication asking for the minimum cardinality</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:minMax" as="xsd:string">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:param name="minimumFlag" as="xsd:boolean"/>
  <xsl:for-each
         select="(normalize-space(gu:col($row,$gu:subsetColumnName))
                                  [$gu:activeSubsetting][string(.)],
                gu:col($row,'Cardinality')[$gu:absentSubsetIsZero]
                                          [starts-with(normalize-space(.),'0')]
                                          [$gu:activeSubsetting]/'0',
                  normalize-space(gu:col($row,'Cardinality')))[1]">
    <xsl:choose>
      <xsl:when test="$minimumFlag">
        <xsl:value-of select="substring(.,1,1)"/>
      </xsl:when>
      <xsl:when test="ends-with(.,'n')">unbounded</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring(.,string-length(.),1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:function>

<xs:function>
  <para>
    Determine the minimum occurrences from cardinality, with 
    priority to the subset cardinality 
  </para>
  <xs:param name="row">
    <para>The genericode row of the BIE</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:minCard" as="xsd:string">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:sequence select="gu:minMax($row,true())"/>
</xsl:function>

<xs:function>
  <para>
    Determine the maximum occurrences from cardinality, with 
    priority to the subset cardinality 
  </para>
  <xs:param name="row">
    <para>The genericode row of the BIE</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:maxCard" as="xsd:string">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:sequence select="gu:minMax($row,false())"/>
</xsl:function>

<xs:function>
  <para>
    Determine if both the minimum or maximum occurrences from cardinality are
    zero, with priority to the subset cardinality 
  </para>
  <xs:param name="row">
    <para>The genericode row of the BIE</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:minMaxBothZero" as="xsd:boolean">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:sequence select="gu:minCard($row)='0' and gu:maxCard($row)='0'"/>
</xsl:function>

<xs:key>
  <para>
    Index the genericode file for all ABIEs, using the common library model
    name as the lookup for common ABIEs, and using the ABIE name as the lookup
    for document ABIEs.
  </para>
</xs:key>
<xsl:key name="gu:abie-by-name-or-model" 
         match="Row[gu:col(.,'ComponentType')='ABIE']"
         use="if( gu:col(.,'ModelName')=$gu:thisCommonLibraryModel )
              then $gu:thisCommonLibraryModel 
              else gu:col(.,$gu:names)"/>

<xs:key>
  <para>
    Index the genericode file for all BIEs by DEN.
  </para>
</xs:key>
<xsl:key name="gu:bie-by-den" match="Row" 
         use="gu:col(.,'DictionaryEntryName')"/>

<xs:key>
  <para>
    Index the genericode file for all BBIEs.
  </para>
</xs:key>
<xsl:key name="gu:bbie-by-name" 
         match="Row[gu:col(.,'ComponentType')='BBIE']"
         use="gu:col(.,$gu:names)"/>

<xs:key>
  <para>
    Index the genericode file for all ABIEs.
  </para>
</xs:key>
<xsl:key name="gu:abie-by-name" 
         match="Row[gu:col(.,'ComponentType')='ABIE']"
         use="gu:col(.,$gu:names)"/>

<xs:key>
  <para>
    Index the genericode file for all ABIEs.
  </para>
</xs:key>
<xsl:key name="gu:abie-by-class" 
         match="Row[gu:col(.,'ComponentType')='ABIE']"
         use="gu:col(.,'ObjectClass')"/>

<xs:key>
  <para>
    Index the genericode file for all business information entities by type
  </para>
</xs:key>
<xsl:key name="gu:bie-by-type" match="Row"
         use="gu:col(.,'ComponentType')"/>

<xs:key>
  <para>Keeping track of entities by their data type.</para>
</xs:key>
<xsl:key name="gu:bie-by-data-type" match="Row[gu:col(.,'DataType')]"
         use="gu:col(.,'DataType')"/>

<xs:key>
  <para>
    Index the genericode file for all BIEs for a given ABIE by its position
  </para>
</xs:key>
<xsl:key name="gu:bie-by-abie-position" 
         match="Row[gu:col(.,'ComponentType')!='ABIE']"
         use="preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1]/
              gu:col(.,'ObjectClass')"/>

<xs:key>
  <para>
    Index the genericode file for all BIEs for a given ABIE by its class
  </para>
</xs:key>
<xsl:key name="gu:bie-by-abie-class" 
         match="Row[gu:col(.,'ComponentType')!='ABIE']"
         use="gu:col(.,'ObjectClass')"/>

<xs:key>
  <para>
    Keeping track of entities by their class and name and type
  </para>
</xs:key>
<xsl:key name="gu:bie-by-class-and-name-and-type" match="Row" 
         use="concat( gu:col(.,'ObjectClass'),' ',
                      gu:col(.,$gu:names),' ',
                      gu:col(.,'ComponentType'))"/>

<xs:key>
  <para>
    Index the genericode file for all ASBIEs for a given ABIE
  </para>
</xs:key>
<xsl:key name="gu:asbie-by-abie" 
         match="Row[gu:col(.,'ComponentType')='ASBIE']"
         use="preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1]/
              gu:col(.,$gu:names)"/>

<xs:key>
  <para>
    Index the genericode file for all ASBIEs for a given ABIE
  </para>
</xs:key>
<xsl:key name="gu:asbie-by-abie-class" 
         match="Row[gu:col(.,'ComponentType')='ASBIE']"
         use="preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1]/
              gu:col(.,'ObjectClass')"/>

<xs:key>
  <para>
    Index the genericode file for all ABIEs referenced by a given ASBIE
  </para>
</xs:key>
<xsl:key name="gu:asbie-by-referred-abie" 
         match="Row[gu:col(.,'ComponentType')='ASBIE']"
         use="gu:col(.,'AssociatedObjectClass')"/>

<xs:key>
  <para>
    Index the genericode file for all BBIEs by Data Type.
  </para>
</xs:key>
<xsl:key name="gu:bbie-by-data-type" 
         match="Row[gu:col(.,'ComponentType')='BBIE']"
         use="gu:col(.,'DataType')"/>

<xs:variable>
  <para>
    Summary list of documents names is found by the name of every ABIE
    that is not in the common library.
  </para>
</xs:variable>
<xsl:variable name="gu:allModelNames" as="element(SimpleValue)*">
  <xsl:for-each-group select="/*/SimpleCodeList/Row/gu:col(.,'ModelName')"
                      group-by=".">
    <xsl:sequence select="."/>
  </xsl:for-each-group>
</xsl:variable>
              
<xs:variable>
  <para>
    Summary list of ABIEs in the library
  </para>
</xs:variable>
<xsl:variable name="gu:allLibraryABIEnames" as="element(SimpleValue)*"
              select="$gu:allLibraryABIEs/gu:col(.,$gu:names)"/>

<xs:variable>
  <para>
    Summary list of ABIEs in the subset of the librarylibrary
  </para>
</xs:variable>
<xsl:variable name="gu:subsetLibraryABIEnames" as="element(SimpleValue)*"
              select="$gu:subsetLibraryABIEs/gu:col(.,$gu:names)"/>

</xsl:stylesheet>

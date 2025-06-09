<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: checkgc4obdndr-rules.xsl,v 1.17 2016/07/16 19:12:20 admin Exp $"
     filename="checkgc4obdndr-rules.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Report rule violations</xs:title>
  <para>
    This reports the problems found in the rules
  </para>
</xs:doc>

<xs:function>
  <para>Compose a link to the OASIS Business Document NDR</para>
  <xs:param name="gu:rule">
    <para>The rule name</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:linkOBDNDR" as="node()*">
  <xsl:param name="gu:rule" as="xsd:string"/>
  <a target="_blank" href=
"http://docs.oasis-open.org/ubl/Business-Document-NDR/v1.0/Business-Document-NDR-v1.0.html#{
     $gu:rule}">
    <xsl:value-of select="$gu:rule"/>
  </a>
</xsl:function>

<xs:function>
  <para>Compose a link to the OASIS UBL NDR</para>
  <xs:param name="gu:rule">
    <para>The rule name</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:linkUBLNDR" as="node()*">
  <xsl:param name="gu:rule" as="xsd:string"/>
  <a target="_blank"
     href="http://docs.oasis-open.org/ubl/UBL-NDR/v3.0/UBL-NDR-v3.0.html#{
     $gu:rule}">
    <xsl:value-of select="$gu:rule"/>
  </a>
</xsl:function>

<xs:function>
  <para>Report a given topic related to the NDR</para>
  <xs:param name="gu:title">
    <para>The title of the issue</para>
  </xs:param>
  <xs:param name="gu:issues">
    <para>The set of issues</para>
  </xs:param>
  <xs:param name="gu:description">
    <para>A pop-up tool-tip describing the issue</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:titleOBDNDR" as="node()*">
  <xsl:param name="gu:title" as="item()+"/>
  <xsl:param name="gu:issues" as="element()*"/>
  <xsl:param name="gu:description" as="xsd:string"/>
  <xsl:text>
</xsl:text>
  <span>
    <xsl:if test="exists($gu:issues[self::ndrbad])">
      <xsl:attribute name="style">color:red</xsl:attribute>
    </xsl:if>
    <xsl:for-each select="$gu:description">
      <xsl:attribute name="title" select="normalize-space(.)"/>
    </xsl:for-each>
    <xsl:copy-of select="gu:linkOBDNDR(substring-before($gu:title,' '))"/>
  <xsl:value-of select="concat(substring($gu:title,6),': ',
                       count(if( $gu:issues[self::ndrbad] )
                             then $gu:issues[self::ndrbad] else $gu:issues))"/>
  </span>
  <xsl:text>
</xsl:text>
</xsl:function>

<xs:function>
  <para>Report a given topic related to the NDR</para>
  <xs:param name="gu:title">
    <para>The title of the issue</para>
  </xs:param>
  <xs:param name="gu:issues">
    <para>The set of issues</para>
  </xs:param>
  <xs:param name="gu:description">
    <para>A pop-up tool-tip describing the issue</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:titleUBLNDR" as="node()*">
  <xsl:param name="gu:title" as="item()+"/>
  <xsl:param name="gu:issues" as="element()*"/>
  <xsl:param name="gu:description" as="xsd:string"/>
  <xsl:text>
</xsl:text>
  <span>
    <xsl:if test="exists($gu:issues[self::ndrbad])">
      <xsl:attribute name="style">color:red</xsl:attribute>
    </xsl:if>
    <xsl:for-each select="$gu:description">
      <xsl:attribute name="title" select="normalize-space(.)"/>
    </xsl:for-each>
    <xsl:copy-of select="gu:linkUBLNDR(substring-before($gu:title,' '))"/>
  <xsl:value-of select="concat(substring($gu:title,6),': ',count($gu:issues))"/>
  </span>
  <xsl:text>
</xsl:text>
</xsl:function>

<xs:template>
  <para>Report all the problems with the rules.</para>
</xs:template>
<xsl:template name="gu:reportAllRuleProblems">

<h3>Naming and Design Rules (NDR)</h3>
  <p>
    As defined in <a target="_blank"
      href="http://docs.oasis-open.org/ubl/UBL-NDR/v3.0/UBL-NDR-v3.0.html"
      >the UBL NDR v3.0 specification</a> and <a target="_blank" href=
"http://docs.oasis-open.org/ubl/Business-Document-NDR/v1.0/Business-Document-NDR-v1.0.html"
      >the OASIS Business Document v1.0 specification</a>.
  </p>
  <h4>Model-related NDRs</h4>
<pre>
  <xsl:text>
</xsl:text>
  <xsl:value-of select="concat($gu:thisCommonLibraryModel,': ',
                               count($gu:subsetLibraryABIEs),' ABIEs',
                               if( count($gu:subsetLibraryABIEs)=
                                   count($gu:allLibraryABIEs) ) then ''
                               else concat( ' subset from a total of ',
                                            count($gu:allLibraryABIEs) ) )"/>
  <xsl:text>
</xsl:text>

  <xsl:copy-of select="gu:titleOBDNDR
   ('MOD01 - Document ABIE',$gu:subsetDocumentABIEmodelNames,
    'The apex of the information bundle shall be structured as a single
     top-level ABIE, referred to in this specification as a Document ABIE.'
   )"/>
  <xsl:for-each select="$gu:MOD01-DABIE-list">
    <xsl:sort select="@gu:den"/>
    <xsl:choose>
      <xsl:when test="xsd:boolean(@gu:onlyOld)">
        <xsl:copy-of select="gu:issue(.,concat('(',@gu:model,')'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="gu:issue(.,@gu:model)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  
  <xsl:copy-of select="gu:titleOBDNDR(
    'MOD02 - References to Document ABIEs',
    $gu:MOD02-DABIE-refs,
    'There should be zero references to document ABIEs.'
    )"/>
  <xsl:for-each select="$gu:MOD02-DABIE-refs">
    <xsl:copy-of select="gu:issue(.,@gu:den)"/>
  </xsl:for-each>
  
  <xsl:copy-of select="gu:titleOBDNDR('MOD03 - Library ABIEs out of order',
    $gu:MOD03-CABIE-order,
    'The ABIEs in the common library shall be in alphabetical order.  The
     ABIE reported is the one that occurrs before the prior ABIE.
     Subsequent ones might very well be in order, which would indicate that
     it is the prior ABIE that is actually the one out of order.'
    )"/>
  <xsl:for-each select="$gu:MOD03-CABIE-order">
    <xsl:copy-of select="gu:issue(.,@gu:class)"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('MOD04 - Extension availability',
    (),
    'Each document shall allow for optional augmentation with a collection
     of information not conceptually described by existing BIEs.'
    )"/>
  <xsl:for-each select="$gu:MOD04-extension-available">
    <xsl:value-of select="@message"/>
  </xsl:for-each>
  <xsl:text>
</xsl:text>

  <xsl:copy-of select="gu:titleOBDNDR('COM01 - structured values',
    $gu:COM01-structured-values,
    'The CCTS values in the model cannot be structured and must be made up
     of only string values.  No empty values are allowed (the CCTS item
     should be absent from the mdoel if it has no value). The DEN and the
     column in error are indicated for each problem.'
    )"/>
  <xsl:for-each select="$gu:COM01-structured-values">
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,': ',@gu:column))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM02 - prohibited characters',
    $gu:COM02-prohibited-values,
    'The CCTS values in the model cannot have sensitive XML characters
     or sequences that might disturb down-stream processing of the
     information.  Newline characters are allowed at the end of a value
     but not otherwise as there is no concept of a paragraph in a value.'
    )"/>
  <xsl:for-each select="$gu:COM02-prohibited-values">
    <xsl:copy-of 
    select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=''',@gu:value,''''))"/>
  </xsl:for-each>

  <xsl:copy-of select="$gu:nl,gu:linkOBDNDR('COM03')"/>
  <xsl:text> - list of permitted abbreviations in name values: </xsl:text>
  <xsl:choose>
    <xsl:when test="not($gu:allowedAbbreviationsInNameValues)">
      <xsl:text>(empty)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$gu:allowedAbbreviationsInNameValues">
        <xsl:value-of select="$gu:nl,.,'=',.."/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:copy-of 
      select="gu:titleOBDNDR('COM03 - prohibited abbreviations in name values',
    $gu:COM03-abbreviated-name-values,
    'This analysis considers any word split after a sequence of digits, after
     two capitals that come before a capital followed by lowercase (e.g.
     UBLVersion->UBL Version), and between a lower-case followed by uppercase
     (e.g. VersionID->Version ID'
    )"/>
  <xsl:for-each select="$gu:COM03-abbreviated-name-values">
    <xsl:copy-of 
               select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=',@gu:value,
                                         '  (',@gu:abbrev,')'))"/>
  </xsl:for-each>

  <xsl:copy-of select="$gu:nl,gu:linkOBDNDR('COM04')"/>
  <xsl:text> - list of permitted abbreviations in DEN values: </xsl:text>
  <xsl:choose>
    <xsl:when test="not($gu:allowedAbbreviationsInDENValues)">
      <xsl:text>(empty)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$gu:allowedAbbreviationsInDENValues">
        <xsl:value-of select="$gu:nl,.,'=',.."/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:copy-of 
       select="gu:titleOBDNDR('COM04 - prohibited abbreviations in DEN values',
    $gu:COM04-abbreviated-DEN-values,
    'This analysis considers any word split after a sequence of digits, after
     two capitals that come before a capital followed by lowercase (e.g.
     UBLVersion->UBL Version), and between a lower-case followed by uppercase
     (e.g. VersionID->Version ID'
    )"/>
  <xsl:for-each select="$gu:COM04-abbreviated-DEN-values">
    <xsl:copy-of 
           select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=''',@gu:value,
                                     ''' (',@gu:abbrev,')'))"/>
  </xsl:for-each>

  <xsl:copy-of select="$gu:nl,gu:linkOBDNDR('COM05')"/>
  <xsl:text> - list of equivalences of primary nouns to representation terms
        in names when testing for duplication: </xsl:text>
  <xsl:choose>
    <xsl:when test="not($gu:nameTermEquivalences)">
      <xsl:text>(empty)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$gu:nameTermEquivalences">
        <xsl:value-of select="$gu:nl,primary-noun,'=',representation-term"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>
</xsl:text>

  <xsl:copy-of select="gu:titleOBDNDR('COM06 - invalid component type',
    $gu:COM06-invalid-component-type,
    'The component type can only be ABIE, BBIE or ASBIE.'
    )"/>
  <xsl:for-each select="$gu:COM06-invalid-component-type">
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,': ',@gu:type))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM07 - invalid ABIE values',
                            $gu:COM07-ABIE-construction,
                            'ABIE values are constrained by the specification.'
                            )"/>
  <xsl:for-each select="$gu:COM07-ABIE-construction">
    <xsl:copy-of 
   select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=',@gu:value,@gu:message,
   if(@gu:expected) then concat(' (expected: ',@gu:expected,')')  else
   if(@gu:unexpected) then ' (column should not exist)' else ''))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM08 - invalid BBIE values',
                            $gu:COM08-BBIE-construction,
                            'BBIE values are constrained by the specification.'
                            )"/>
  <xsl:for-each select="$gu:COM08-BBIE-construction">
    <xsl:copy-of 
   select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=',@gu:value,@gu:message,
   if(@gu:expected) then concat(' (expected: ',@gu:expected,')')  else
   if(@gu:unexpected) then ' (column should not exist)' else ''))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM09 - invalid ASBIE values',
                            $gu:COM09-ASBIE-construction,
                           'ASBIE values are constrained by the specification.'
                            )"/>
  <xsl:for-each select="$gu:COM09-ASBIE-construction">
    <xsl:copy-of 
   select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=',@gu:value,@gu:message,
   if(@gu:expected) then concat(' (expected: ',@gu:expected,')')  else
   if(@gu:unexpected) then ' (column should not exist)' else ''))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM10 - DEN uniqueness',
                            $gu:COM10-dictionary-entry-name-uniqueness,
                            'No two BIEs can have the same DEN'
                            )"/>
  <xsl:for-each select="$gu:COM10-dictionary-entry-name-uniqueness">
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,': ',@gu:models))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR(
    'COM11 - prohibited character in name values',
    $gu:COM11-invalid-name-values,
    'Words in name values cannot have characters that interfere with the
     syntax for dictionary entry names.'
    )"/>
  <xsl:for-each select="$gu:COM11-invalid-name-values">
    <xsl:copy-of 
    select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=''',@gu:value,''''))"/>
  </xsl:for-each>

  <xsl:copy-of select="
    gu:titleOBDNDR('COM12 - leading upper case in DEN name values',
    $gu:COM12-invalid-name-values,
    'Words in name values must have leading upper-case and the remainder
     lower-case unless the word is an approved abbreviation.'
    )"/>
  <xsl:for-each select="$gu:COM12-invalid-name-values">
    <xsl:copy-of 
           select="gu:issue(.,concat(@gu:den,': ',@gu:column,'=',@gu:value))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM13 - ABIE empty',
                            $gu:COM13-ABIE-empty,
                            'An ABIE cannot be empty.'
                            )"/>
  <xsl:for-each select="$gu:COM13-ABIE-empty">
    <xsl:copy-of select="gu:issue(.,concat( @gu:class,' (',
                                            @gu:references,')'))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:titleOBDNDR('COM14 - ABIE order',
                            $gu:COM14-ABIE-order,
                             'All BBIEs for an ABIE must be before all ASBIEs.'
                            )"/>
  <xsl:for-each select="$gu:COM14-ABIE-order">
    <xsl:copy-of select="gu:issue(.,concat(@gu:abie,': ',
                     if( @gu:foreign ) then @gu:foreign else '(position)') )"/>
  </xsl:for-each>

</pre>

</xsl:template>

</xsl:stylesheet>

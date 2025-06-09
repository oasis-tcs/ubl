<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: checkgc4obdndr-report.xsl,v 1.21 2019/08/06 23:57:58 admin Exp $"
       filename="checkgc4obdndr-report.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Report new model against old</xs:title>
  <para>
    This reports the problems found in the analysis
  </para>
</xs:doc>

<xs:function>
  <para>Report a given topic not related to the NDR</para>
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
<xsl:function name="gu:title" as="node()*">
  <xsl:param name="gu:title" as="item()+"/>
  <xsl:param name="gu:issues" as="element()*"/>
  <xsl:param name="gu:description" as="xsd:string"/>
  <xsl:text>
</xsl:text>
  <span>
    <xsl:for-each select="$gu:description">
      <xsl:attribute name="title" select="normalize-space(.)"/>
    </xsl:for-each>
    <span>
      <xsl:if test="count($gu:issues[self::ndrbad])>0">
        <xsl:attribute name="style">color:red;</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="concat($gu:title,': ',
    for $gu:c in count($gu:issues[self::ndrbad]) 
    return if( $gu:c > 0 ) then $gu:c else count($gu:issues[self::ndrinfo]))"/>
    </span>
  </span>
  <xsl:text>
</xsl:text>
  <xsl:for-each select="$gu:issues[self::ndrinfo][@message]">
    <xsl:value-of select="@message"/>
    <xsl:text>
</xsl:text>
  </xsl:for-each>
</xsl:function>

<xs:function>
  <para>Report a given issue</para>
  <xs:param name="gu:issue">
    <para>The issue element details.</para>
  </xs:param>
  <xs:param name="gu:description">
    <para>The issue description</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:issue" as="node()*">
  <xsl:param name="gu:issue" as="element()"/>
  <xsl:param name="gu:description" as="item()+"/>
  <a id="{generate-id($gu:issue)}">
    <xsl:value-of select="$gu:description"/>
    <xsl:text>
</xsl:text>
  </a>
</xsl:function>

<xs:template>
  <para>Report all the problems.</para>
</xs:template>
<xsl:template name="gu:reportAllModelProblems">

<xsl:if test="not($old is $new)">
<h3>Non-fatal backward compatibility observations</h3>
  
<pre>

  <xsl:copy-of select="gu:title('Renamed old DENs in new model',$gu:missing,
    'Renaming an old DEN with a new value does not impact conformance, as
     the schema constraints do not change.  However, the DEN is meant to
     be persistent and should only change if it is necessary to correct it.
     For example, it might have been used as a key for documentation.
     Accordingly, one should consider preserving old DEN values in such
     uses, along with the new DEN values, so that old links continue to work.'
    )"/>
  <xsl:for-each select="$gu:missing">
    <xsl:sort select="@gu:den"/>
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,': ',@gu:newden))"/>
  </xsl:for-each>

  <xsl:copy-of select="
         gu:title('Missing old Data Type Qualifications in new model',$gu:qdt,
  'It is not fatal to deem an element to change or no longer to have a data
  type qualification in a newer model, but it is reported here in case it
  was an oversight.'
  )"/>
  <xsl:for-each select="$gu:qdt">
    <xsl:sort select="@name"/>
    <xsl:copy-of select="gu:issue(.,(concat(@gu:den,':'),
                          concat('old=&#x22;',@old,'&#x22; new=&#x22;',
                                               @new,'&#x22;')))"/>
  </xsl:for-each>

  <xsl:copy-of select="
            gu:title('Added Data Type Qualifications in new model',$gu:qdtnew,
  'It is not fatal to have new data type qualifications. Such are listed
   here to help with integrity checking by reviewing important changes to
   the model.')
  "/>
  <xsl:for-each select="$gu:qdtnew">
    <xsl:sort select="@name"/>
    <xsl:copy-of select="gu:issue(.,(concat(@gu:den,':'),
                          concat('&#x22;',@new,'&#x22;')))"/>
  </xsl:for-each>

</pre>

<h3>Fatal backward compatibility issues</h3>
  
<pre>

  <xsl:copy-of select="gu:title('Cardinalities found in error',$gu:badcard,
  'When changing the cardinality of an old item in a new model, the minimum
   can be dropped (but not raised) and the maximum can be raised (but not
   dropped).')"/>
  <xsl:for-each select="$gu:badcard">
    <xsl:sort select="@gu:den"/>
    <xsl:copy-of select="gu:issue(.,(concat('&#x22;',@gu:den,'&#x22;'),
                          'old=',@old,'new=',@new))"/>
  </xsl:for-each>
    
  <xsl:copy-of select="gu:title('Sequences found in error (by DEN)',$gu:order,
  'All items in the old model must be in the same order in the new model.')"/>
  <xsl:for-each select="$gu:order">
    <xsl:sort select="@class"/>
    <xsl:copy-of select="gu:issue(.,concat('&#x22;',@class,'&#x22;'))"/>
    <xsl:text>  Old order:
</xsl:text>
    <xsl:for-each select="old/*">
      <xsl:text>  </xsl:text>
      <xsl:choose>
        <xsl:when test="count(preceding-sibling::*)!=
                        count(../../new/*[@name=current()/@name]/
                              preceding-sibling::*)">*</xsl:when>
        <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="position(),@name"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>
  New order (not including newly-introduced optional constructs):
</xsl:text>
    <xsl:for-each select="new/*">
      <xsl:text>  </xsl:text>
      <xsl:choose>
        <xsl:when test="count(preceding-sibling::*)!=
                        count(../../old/*[@name=current()/@name]/
                              preceding-sibling::*)">*</xsl:when>
        <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="position(),@name"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>
  New order (all constructs):
</xsl:text>
    <xsl:for-each select="new-unfiltered/*">
      <xsl:text>  </xsl:text>
      <xsl:choose>
        <xsl:when test="count(preceding-sibling::*)!=
                        count(../../old/*[@name=current()/@name]/
                              preceding-sibling::*)">*</xsl:when>
        <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="position(),@name"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:for-each>


</pre>
</xsl:if>

<xsl:if test="$gu:activeSubsetting">
<h3>Fatal subset issues</h3>

<pre>
  <xsl:copy-of select="gu:title('Cardinalities found in error',$gu:badcardsub,
  'When specifying the subset cardinality, the minimum can be raised (but not
   dropped) and the maximum can be dropped (but not raised).')"/>
  <xsl:for-each select="$gu:badcardsub">
    <xsl:sort select="@gu:den"/>
    <xsl:copy-of select="gu:issue(.,(concat('&#x22;',@gu:den,'&#x22;'),
                                  'old=',@old,'subset=',@subset))"/>
  </xsl:for-each>
</pre>

</xsl:if>

<h3>Non-fatal issues but not allowed by these checks</h3>
  
<pre>

  <xsl:copy-of select="gu:title('Qualified ABIEs',$gu:qualifiedABIE,
    'In these checks there are no qualifications on ABIEs'
    )"/>
  <xsl:for-each select="$gu:qualifiedABIE">
    <xsl:sort select="@name"/>
    <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:den,'&#x22;'))"/>
  </xsl:for-each>
    
  <xsl:copy-of select="
            gu:title('ASBIEs referring to qualified ABIEs',$gu:qualifiedASBIE,
    'In these checks there are no qualifications on ABIEs'
    )"/>
  <xsl:for-each select="$gu:qualifiedASBIE">
    <xsl:sort select="@name"/>
    <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:den,'&#x22;'))"/>
  </xsl:for-each>
    
  <xsl:copy-of select="
    gu:title('Orphaned ABIEs not being referenced by an ASBIE',
    $gu:orphanLibraryABIE,
    'Unused library ABIEs are not an error, but having them is suspicious.')"/>
    <xsl:for-each select="$gu:orphanLibraryABIE[self::ndrbad]">
      <xsl:sort select="@name"/>
      <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:class,'&#x22;'))"/>
    </xsl:for-each>

  <xsl:copy-of select="
    gu:title('Single-child ABIEs should not have an optional child',
    $gu:oneChildSubsetLibraryABIE,
    'Since an element cannot be empty, a one-child element should not have an
     optional child')"/>
    <xsl:for-each select="$gu:oneChildSubsetLibraryABIE[self::ndrbad]">
      <xsl:sort select="@name"/>
      <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:class,'&#x22;'))"/>
    </xsl:for-each>

  <xsl:copy-of select="gu:title(
      'Missing expected BIEs in Document ABIE',$gu:missingMandatoryMaindocBIEs,
      'The configuration file indicates the need for certain property
       terms in all Document ABIEs')"/>
  <xsl:for-each select="$gu:missingMandatoryMaindocBIEs">
    <xsl:sort select="@doctype"/>
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,': ',@gu:propertyTerm,
                         if( @gu:cardinality )
                         then concat(' (expected cardinality ''',@gu:expected,
                              ''', found cardinality ''',@gu:cardinality,''')')
                         else if( @gu:type )
                         then concat(' (expected type ''',@gu:expected,
                              ''', found type ''',@gu:type,''')')
                         else if( @gu:position )
                         then concat(' (expected position ''',@gu:expected,
                              ''', found position ''',@gu:position,''')')
                         else ' (missing)'))"/>
  </xsl:for-each>
  <xsl:if test="$version-column-name">
    <xsl:copy-of select="gu:title(
        concat('Mismatched version number for new BIEs (',
               $gu:configMain/*/schema/@version,')'),
        $gu:mismatchedVersion,
        'New BIEs should be marked with the version of the new configuration
         file')"/>
    <xsl:for-each select="$gu:mismatchedVersion">
      <xsl:copy-of select="gu:issue(.,
                            concat(@gu:den,': &#x22;',@gu:version,'&#x22;'))"/>
    </xsl:for-each>

    <xsl:copy-of select="gu:title('Mislabelled version number for old BIEs',
       $gu:mislabelledVersion,
      'Old BIEs should not be marked with the version of the new configuration
       file')"/>
    <xsl:for-each select="$gu:mislabelledVersion">
      <xsl:copy-of select="gu:issue(.,concat(@gu:den,' ',@gu:bad,
                                             ' (',@gu:good,')'))"/>
    </xsl:for-each>
  </xsl:if>

  <xsl:copy-of select="gu:title('Unexpected cardinality for non-Text BBIEs',
     $gu:bbieMultitude,
    'Non-Text BBIEs should not have repeatable cardinality and should be
 considered to be remodeled as a repeatable ASBIE with a non-repeated BBIE')"/>
  <xsl:for-each select="$gu:bbieMultitude">
    <xsl:copy-of select="gu:issue(.,concat(@gu:den,' ',@gu:cardinality,' ',
                                           @gu:version))"/>
  </xsl:for-each>
</pre>
  
<h3>Additional reporting</h3>
  
<pre>
  <xsl:copy-of select="
            gu:title('Data type qualifications',$gu:infoQDT,
    'A handy summary for reference'
    )"/>
  <xsl:text>Data type qualifiers: </xsl:text>
  <xsl:value-of select="count(distinct-values($gu:infoQDT/@gu:qdt))"/>
  <xsl:text>&#xa;</xsl:text>
  <xsl:for-each-group select="$gu:infoQDT" group-by="@gu:qdt">
    <xsl:sort select="@gu:qdt"/>
    <xsl:value-of select="concat( '  ',current-grouping-key(),
                          for $gu:c in count(current-group()) return
                          if( $gu:c=1 ) then '' else concat(' (',$gu:c,')'))"/>
    <xsl:text>: &#xa;</xsl:text>
    <xsl:for-each select="current-group()">
      <xsl:sort select="@gu:den"/>
      <xsl:text>    </xsl:text>
      <xsl:value-of select="@gu:den"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
  </xsl:for-each-group>

</pre>
<!--remove these for now because there are too many violations  
<h3>Non-fatal issues but not allowed by these checks</h3>
  
<pre>

  <xsl:copy-of select="gu:title(
    'Non-text representation terms',$gu:nonTextRepresentationTerms,
    'Having a different value for the property term primary noun than the representation term is not an error per se, but it is something to review as it is not the norm.'
    )"/>
  <xsl:for-each select="$gu:nonTextRepresentationTerms">
    <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:den,'&#x22; ',
                                           @gu:ptpn,'!=',@gu:rept))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:title(
    'Text representation terms',$gu:textRepresentationTerms,
    'Having a property term primary noun of ''Text'' for the representation term of ''Text'' is not an error per se, but it is something to review as it is not the norm.'
    )"/>
  <xsl:for-each select="$gu:textRepresentationTerms">
    <xsl:copy-of select="gu:issue(.,concat('&#x22;',@gu:den,'&#x22;'))"/>
  </xsl:for-each>

  <xsl:copy-of select="gu:title(
    'Duplicate BBIEs',$gu:duplicateBBIEs,
    'Having more than one BBIE with the same name is not an error, but there will be only one schema declaration for all of them.  In the schema there will be only one definition used.  It may be better to have different names to represent different semantics.'
    )"/>
  <xsl:for-each select="$gu:duplicateBBIEs">
    <xsl:copy-of select="gu:issue(.,concat(@gu:name,': (',@gu:count,') ',
                                            @gu:dens))"/>
  </xsl:for-each>
</pre>
-->  
</xsl:template>

</xsl:stylesheet>

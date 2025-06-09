<?xml version="1.0" encoding="US-ASCII"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs xsd gu"
                version="2.0">

<xs:doc info="$Id: Crane-mergegc.xsl,v 1.4 2017/08/01 18:02:47 admin Exp $"
     filename="Crane-mergegc.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Merge one genericode file into another</xs:title>
  <para>
    This adds to a genericode file those ABIEs and in the merge file that are
    not in the input file, as well as any changes to existing ABIEs.
  </para>
</xs:doc>

<xsl:include href="support/Crane-utilndr.xsl"/>

<xs:output>
  <para>Indented results are easier to review in editing</para>
</xs:output>
<xsl:output indent="yes"/>

<xs:param ignore-ns="yes">
  <para>The old entities open file; when using Saxon use +old=filename</para>
</xs:param>
<xsl:param name="merge" as="document-node()?" 
           select="if( $merge-uri)
           then doc(resolve-uri($merge-uri,base-uri($base)))
           else error( (), 'Missing required argument merge= or merge-uri=')"/>

<xs:param ignore-ns="yes">
  <para>The merge entities filename when not opening on invocation</para>
</xs:param>
<xsl:param name="merge-uri" as="xsd:string?"/>
  
<xs:param ignore-ns="yes">
  <para>The old entities open file; when using Saxon use +old=filename</para>
</xs:param>
<xsl:param name="old" as="document-node()?" 
           select="if( $old-uri)
           then doc(resolve-uri($old-uri,base-uri($base)))
           else error( (), 'Missing required argument old= or old-uri=')"/>

<xs:param ignore-ns="yes">
  <para>The old entities filename when not opening on invocation</para>
</xs:param>
<xsl:param name="old-uri" as="xsd:string?"/>
  
<xs:key>
  <para>Indexing into the genericode file</para>
</xs:key>
<xsl:key name="gu:BIE-by-DEN" match="Row"
         use="gu:col(.,'DictionaryEntryName')"/>

<xs:key>
  <para>Indexing into the genericode file</para>
</xs:key>
<xsl:key name="gu:BIE-by-class" match="Row" use="gu:col(.,'ObjectClass')"/>

<xs:key>
  <para>Indexing into the genericode file</para>
</xs:key>
<xsl:key name="gu:BIE-by-class" match="Row"
         use="gu:col(.,'DictionaryEntryName')"/>

<xs:variable>
  <para>First column is assumed to be the model name</para>
</xs:variable>
<xsl:variable name="gu:modelName" as="xsd:string" 
              select="$base/*/ColumnSet/Column[1]/@Id"/>

<xs:key>
  <para>Indexing into the merge file</para>
</xs:key>
<xsl:key name="gu:ABIE-by-Model" match="Row" use="gu:col(.,$gu:modelName)"/>

<xs:param ignore-ns="yes">
  <para>The base entities open file</para>
</xs:param>
<xsl:param name="base" as="document-node()" select="/"/>

<xs:variable>
  <para>Determine the outgoing ABIEs</para>
</xs:variable>
<xsl:variable name="gu:merged-ABIE-classes" as="xsd:string*">
  <xsl:perform-sort select="distinct-values( ($base,$merge)/*/SimpleCodeList/
      Row[gu:col(.,$gu:modelName)=$gu:thisCommonLibraryModel]
         [gu:col(.,'ComponentType')='ABIE']/gu:col(.,'ObjectClass'))">
    <xsl:sort select="."/>
  </xsl:perform-sort>
  <xsl:perform-sort select="distinct-values( ($base,$merge)/*/SimpleCodeList/
      Row[gu:col(.,$gu:modelName)!=$gu:thisCommonLibraryModel]
         [gu:col(.,'ComponentType')='ABIE']/gu:col(.,'ObjectClass'))">
    <xsl:sort select="."/>
  </xsl:perform-sort>
</xsl:variable>

<xs:template ignore-ns="yes">
  <para>Start the reports</para>
</xs:template>
<xsl:template match="/">
  <!--check the inputs as being genericode-->
  <xsl:if test="not($base/gc:CodeList)"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>Input file is not a genericode file: </xsl:text>
      <xsl:value-of select="document-uri($base)"/>
    </xsl:message>
  </xsl:if>
  <xsl:if test="not($old/gc:CodeList)"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>Old file is not a genericode file: </xsl:text>
      <xsl:value-of select="document-uri($base)"/>
    </xsl:message>
  </xsl:if>
  <xsl:if test="not($merge/gc:CodeList)"
             xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/">
    <xsl:message terminate="yes">
      <xsl:text>Merge file is not a genericode file: </xsl:text>
      <xsl:value-of select="document-uri($merge)"/>
    </xsl:message>
  </xsl:if>
  <!--check that the column sets are the same-->
  <xsl:variable name="gu:checkColsBase" as="xsd:string">
    <xsl:value-of>
    <xsl:perform-sort select="$base/*/ColumnSet/Column[@Id!='Row']/@Id">
      <xsl:sort/>
    </xsl:perform-sort>
    </xsl:value-of>
  </xsl:variable>
  <xsl:variable name="gu:checkColsOld" as="xsd:string">
    <xsl:value-of>
    <xsl:perform-sort select="$old/*/ColumnSet/Column[@Id!='Row']/@Id">
      <xsl:sort/>
    </xsl:perform-sort>
    </xsl:value-of>
  </xsl:variable>
  <xsl:variable name="gu:checkColsMerge" as="xsd:string">
    <xsl:value-of>
    <xsl:perform-sort select="$merge/*/ColumnSet/Column[@Id!='Row']/@Id">
      <xsl:sort/>
    </xsl:perform-sort>
    </xsl:value-of>
  </xsl:variable>
  <xsl:if test="not( $gu:checkColsBase = $gu:checkColsMerge and
                     $gu:checkColsBase = $gu:checkColsOld )">
    <xsl:message terminate="yes">
      <xsl:text>Column sets do not match for the three data sets, </xsl:text>
      <xsl:text>based on the column set for the input genericode.</xsl:text>
    </xsl:message>
  </xsl:if>
  <!--check that the model names have been normalized-->
  <xsl:if test="not($old/*/SimpleCodeList/Row/Value[@ColumnRef='ModelName']/
                    SimpleValue = $gu:thisCommonLibraryModel) or
                not($merge/*/SimpleCodeList/Row/Value[@ColumnRef='ModelName']/
                    SimpleValue = $gu:thisCommonLibraryModel)">
    <xsl:message terminate="yes">
      <xsl:text>Ensure that both the old and merge files have the </xsl:text>
      <xsl:text>same set of model names as the input genericode. </xsl:text>
      <xsl:text>This is probably a manual edit, but necessary for </xsl:text>
      <xsl:text>comparing models. This might change in a future </xsl:text>
      <xsl:text>version.</xsl:text>
    </xsl:message>
  </xsl:if>
  
  <xsl:variable name="gu:messages" as="xsd:string*">
    <xsl:for-each select="$gu:merged-ABIE-classes">
      <xsl:choose>
        <xsl:when test="not(key('gu:BIE-by-class',.,$base))">
          <!--no need to check non-existent members-->
          <xsl:value-of select="concat('ABIE: ',.)"/>
        </xsl:when>
        <xsl:when test="not(key('gu:BIE-by-class',.,$merge))">
          <!--no request to change the information in the base file-->
        </xsl:when>
        <xsl:otherwise>
          <!--the rows in the merge file are the ones to follow-->
          <xsl:for-each select="key('gu:BIE-by-class',.,$merge)/
                                gu:col(.,'DictionaryEntryName')">
         <xsl:variable name="gu:base" select="key('gu:BIE-by-DEN',.,$base)"/>
         <xsl:variable name="gu:old" select="key('gu:BIE-by-DEN',.,$old)"/>
         <xsl:variable name="gu:merge" select="key('gu:BIE-by-DEN',.,$merge)"/>
            <xsl:choose>
              <xsl:when test="gu:BIEequal($gu:base,$gu:merge)">
                <!--no change requested, one in the base file is acceptable-->
              </xsl:when>
              <xsl:when test="gu:BIEequal($gu:base,$gu:old)">
                <!--the one in the base file is same as old, so use merge-->
                <xsl:value-of select="concat('BIE:&#xa0; ',.)"/>
              </xsl:when>
              <xsl:when test="gu:BIEequal($gu:merge,$gu:old)">
                <!--the one in the merge file is same as old, so use base-->
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('Conflict BIE: ',.)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="count($gu:messages[starts-with(.,'Conflict')])">
      <xsl:message>
        <xsl:value-of select="count($gu:messages[starts-with(.,'Conflict')])"/>
        <xsl:text> conflict(s):</xsl:text>
      </xsl:message>
      <xsl:for-each select="$gu:messages[starts-with(.,'Conflict')]">
        <xsl:message select="."/>
      </xsl:for-each>
      <xsl:message terminate="yes">Processing terminated</xsl:message>
    </xsl:when>
    <xsl:when test="count($gu:messages)=0">
      <xsl:message>Nothing merged</xsl:message>
    </xsl:when>
  </xsl:choose>
  <xsl:message>Summary of <xsl:value-of
                     select="count($gu:messages)"/> merged items:</xsl:message>
  <xsl:for-each select="$gu:messages">
    <xsl:message select="."/>
  </xsl:for-each>

  <xsl:for-each select="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!--preserve metadata-->
      <xsl:copy-of select="Identification"/>
      <!--preserve columnset-->
      <xsl:for-each select="SimpleCodeList">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:copy-of select="Column[not(@Id='Row')]"/>
        </xsl:copy>
      </xsl:for-each>
      <xsl:copy-of select="ColumnSet"/>
      <!--now do the rows-->
      <xsl:for-each select="SimpleCodeList">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
    <xsl:for-each select="$gu:merged-ABIE-classes">
      <xsl:choose>
        <xsl:when test="not(key('gu:BIE-by-class',.,$base))">
          <!--no need to check non-existent members, everything is base-->
          <xsl:copy-of select="key('gu:BIE-by-class',.,$merge)"/>
        </xsl:when>
        <xsl:when test="not(key('gu:BIE-by-class',.,$merge))">
          <!--no request to change the information in the base file-->
          <xsl:copy-of select="key('gu:BIE-by-class',.,$base)"/>
        </xsl:when>
        <xsl:otherwise>
          <!--do individual rows (BIEs), governed by the merge file-->
          <!--if any base rows have been deleted, this will be caught by NDR-->
          <xsl:for-each select="key('gu:BIE-by-class',.,$merge)/
                                gu:col(.,'DictionaryEntryName')">
           <xsl:variable name="gu:base" select="key('gu:BIE-by-DEN',.,$base)"/>
           <xsl:variable name="gu:old" select="key('gu:BIE-by-DEN',.,$old)"/>
           <xsl:variable name="gu:merge"
                         select="key('gu:BIE-by-DEN',.,$merge)"/>
            <xsl:choose>
              <xsl:when test="not($gu:base)">
                <!--the merge file has something base, so use it-->
                <xsl:copy-of select="$gu:merge"/>
              </xsl:when>
              <xsl:when test="gu:BIEequal($gu:base,$gu:merge)">
                <!--no change requested, one in the base file is acceptable-->
                <xsl:copy-of select="$gu:base"/>
              </xsl:when>
              <xsl:when test="gu:BIEequal($gu:base,$gu:old)">
                <!--the one in the base file is same as old, so use merge-->
                <xsl:copy-of select="$gu:merge"/>
              </xsl:when>
              <xsl:when test="gu:BIEequal($gu:merge,$gu:old)">
                <!--the one in the merge file is same as old, so use base-->
                <xsl:copy-of select="$gu:base"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">Internal error.</xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:for-each>

</xsl:template>

<xs:function>
  <para>Compare two BIEs for equality, not including row number</para>
  <xs:param name="gu:left"><para>One side of the comparison</para></xs:param>
  <xs:param name="gu:right"><para>Other side of the comparison</para></xs:param>
</xs:function>
<xsl:function name="gu:BIEequal" as="xsd:boolean">
  <xsl:param name="gu:left" as="element(Row)?"/>
  <xsl:param name="gu:right" as="element(Row)?"/>
  <xsl:sequence select="every $gu:value in 
      $gu:left/Value except $gu:left/Value[@ColumnRef=('Row')]
      satisfies $gu:value/SimpleValue =
                $gu:right/Value[@ColumnRef=$gu:value/@ColumnRef]/SimpleValue"/>
</xsl:function>

</xsl:stylesheet>

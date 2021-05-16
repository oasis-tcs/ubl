<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs gu xsd"
                version="2.0">

<xs:doc info="$Id: Crane-utilndr.xsl,v 1.11 2017/01/13 19:27:38 admin Exp $"
        filename="Crane-utilndr.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Utility components to Crane's GC work</xs:title>
  <para> 
    This stylesheet includes the utility functions for Crane's stylesheets
    acting on genericode files of CCTS entities.
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

<xs:param name="common-library-singleton-model-name" ignore-ns="yes">
  <para>
    Use this parameter to identify the common library model name only when the
    common library consists of only a single ABIE.  If the common library
    contains more than one ABIE then it will be automatically detected. Note
    that there cannot be more than one common library, that is, a model with
    more than one ABIE.
  </para>
</xs:param>
<xsl:param name="common-library-singleton-model-name"
           as="xsd:string?" select="()"/>

<xs:variable>
  <para>
    This is the access to the genericode input file as a node tree.
  </para>
</xs:variable>
<xsl:variable name="gu:gc" as="document-node()" select="/"/>

<xs:param ignore-ns="yes">
  <para>
    When generating an extension or additional document schema fragments, this
    must be specified to supply the common genericode file definition, since
    the input genericode file definition is for the generating schema fragment.
  </para>
</xs:param>
<xsl:param name="base-gc-uri" as="xsd:anyURI?" select="()"/>

<xs:variable>
  <para>
    This is the access to the genericode common file.
  </para>
</xs:variable>
<xsl:variable name="gu:gcOther" as="document-node()?"
              xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
              select="if( $base-gc-uri ) 
                      then for $u in resolve-uri( $base-gc-uri,
                                                  document-uri(/) ) return
                           if( doc-available($u) ) 
                           then doc($u)[gc:CodeList]
                           else error( (),concat(
                           'Unable to open resolved base genericode file: ',
                           $u ) )
                      else ()"/>

<xs:variable>
  <para>
    Handy reference to a sequence of possible spreadsheet column names.
    Although the UBL project uses "UBLName", another project may choose
    to use "ComponentName" or "Name" as the corresponding column name.
  </para>
</xs:variable>
<xsl:variable name="gu:names" as="xsd:string+" 
              select="('UBLName','ComponentName','Name')"/>

<xs:variable>
 <para>Determine the library model from all models in a genericode file.</para>
</xs:variable>
<xsl:variable name="gu:thisCommonLibraryModel" as="xsd:string?">
  <xsl:variable name="gu:models" as="element(model)+">
   <xsl:for-each-group
                    select="$gu:gc/*/*/Row/gu:col(.,'ModelName')" group-by=".">
     <model name="{.}"
      count-bies="{count($gu:gc/*/*/Row[gu:col(.,'ModelName')=current()])}"
      count-abies="{count($gu:gc/*/*/Row[gu:col(.,'ModelName')=current()]
                                        [gu:col(.,'ComponentType')='ABIE'])}"/>
            
   </xsl:for-each-group>
  </xsl:variable>
  <xsl:if test="count($gu:models[@count-abies>1])>1">
    <xsl:message terminate="yes">
      <xsl:text>Only one model can have more than one ABIE as the </xsl:text>
      <xsl:text>library model.</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="count($gu:models[@count-abies>1])=0 and
                not($common-library-singleton-model-name)">
    <xsl:message terminate="yes">
      <xsl:text>When all models have only one ABIE then the model </xsl:text>
      <xsl:text>to be considered the library model has to be </xsl:text>
      <xsl:text>identified using the </xsl:text>
      <xsl:text>"common-library-singleton-model-name" invocation </xsl:text>
      <xsl:text>argument.</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:sequence select="if( $common-library-singleton-model-name )
                        then $common-library-singleton-model-name
                        else gu:lookupCommonLibraryModel($gu:gc)"/>
</xsl:variable>

<xs:function>
  <para>
    Determine the one model that has more than one ABIE and assume that is
    the common library, since document models are allowed only to have a
    single ABIE.  If the given genericode file has 
  </para>
  <xs:param name="gc">
    <para>Which genericode file is being looked in?</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:lookupCommonLibraryModel" as="xsd:string?">
  <xsl:param name="gc" as="document-node()?"/>
  <xsl:variable name="gu:modelsWithMoreThanOneABIE" as="xsd:string*">
    <xsl:for-each-group group-by="gu:col(.,'ModelName')"
           select="$gc/*/SimpleCodeList/Row[gu:col(.,'ComponentType')='ABIE']">
        <xsl:if test="count(current-group())>1">
          <xsl:value-of select="current-grouping-key()"/>
        </xsl:if>
    </xsl:for-each-group>
  </xsl:variable>
  <xsl:if test="count($gu:modelsWithMoreThanOneABIE) > 1">
    <xsl:message terminate="yes">
      <xsl:text>More than one common library model identified in </xsl:text>
      <xsl:value-of select="document-uri($gc)"/>
      <xsl:text> in that there are </xsl:text>
      <xsl:value-of select="count($gu:modelsWithMoreThanOneABIE)"/>
      <xsl:text> models with more than one ABIE: </xsl:text>
      <xsl:value-of select="$gu:modelsWithMoreThanOneABIE" separator=", "/>
    </xsl:message>
  </xsl:if>
  <!--when there are no such models (with more than one ABIE), assume that
      the common library is in the other GC file-->
  <xsl:sequence select="if( empty($gu:modelsWithMoreThanOneABIE) )
                        then if( $gc is $gu:gcOther )
                            then ()
                            else gu:lookupCommonLibraryModel($gu:gcOther)
                        else $gu:modelsWithMoreThanOneABIE"/>
</xsl:function>
  
<!--========================================================================-->
<xs:doc>
  <xs:title>Utility templates and functions</xs:title>
</xs:doc>
  
<xs:function>
  <para>Return a row's column value based on a column reference</para>
  <xs:param name="row">
    <para>The row of the genericode file.</para>
  </xs:param>
  <xs:param name="col">
    <para>
      The column reference of the value in the row.  Note that multiple
      column references are allowed, but only one of the column references
      is allowed to match.  If the row matches more than one column name
      given, this will abend in a runtime error.
    </para>
  </xs:param>
</xs:function>
<xsl:function name="gu:col" as="element(SimpleValue)?">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:param name="col" as="xsd:string*"/>
  <xsl:variable name="gu:return" as="element(SimpleValue)*"
                select="$row/Value[@ColumnRef=$col]/SimpleValue"/>
  <xsl:if test="count($gu:return) > 1">
    <xsl:message terminate="yes">
      <xsl:text>Data error: multiple genericode values in a single </xsl:text>
      <xsl:text>row for column reference</xsl:text>
      <xsl:if test="count($col)>1">s</xsl:if>: <xsl:text/>
      <xsl:value-of select="$col" separator=", "/> at <xsl:text/>
      <xsl:for-each select="$row/ancestor-or-self::*">
        <xsl:text/>/<xsl:value-of select="name(.)"/>
        <xsl:if test="self::Row">[<xsl:number/>]</xsl:if>
      </xsl:for-each>
    </xsl:message>
  </xsl:if>
  <xsl:sequence select="$gu:return"/>
</xsl:function>

<xs:function>
  <para>Return a compressed value from a string</para>
  <xs:param name="item">
    <para>The value to be compressed.</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:comp" as="xsd:string?">
  <xsl:param name="item" as="item()?"/>
  <xsl:sequence select="translate(normalize-space($item),' ','')"/>
</xsl:function>

<xs:function>
  <para>Return a compressed value from a column</para>
  <xs:param name="row">
    <para>The row of the genericode file.</para>
  </xs:param>
  <xs:param name="col">
    <para>
      The column reference of the value in the row.  Note that multiple
      column references are allowed, but only one of the column references
      is allowed to match.  If the row matches more than one column name
      given, this will abend in a runtime error.
    </para>
  </xs:param>
</xs:function>
<xsl:function name="gu:colcomp" as="xsd:string?">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:param name="col" as="xsd:string+"/>
  <xsl:sequence select="gu:comp(gu:col($row,$col))"/>
</xsl:function>

</xsl:stylesheet>

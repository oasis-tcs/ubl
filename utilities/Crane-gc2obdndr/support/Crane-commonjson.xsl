<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                exclude-result-prefixes="xs gu xsd"
                version="2.0">

<xs:doc info="$Id: Crane-commonjson.xsl,v 1.3 2016/12/30 15:34:20 admin Exp $"
        filename="Crane-commonjson.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Common code for handling JSON</xs:title>
  <para>
    Support for serializing JSON structures: objects, Boolean values, 
    number, strings, lists of string or number items.
  </para>
  <programlisting></programlisting>
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

<xs:template>
  <para>Handle a nested item in JSON syntax</para>
</xs:template>
<xsl:template match="o" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:for-each select="@n">
    <xsl:text>"</xsl:text>
    <xsl:value-of select='replace(replace(.,"""","\\"""),"\n","\\n")'/>
    <xsl:text>": </xsl:text>
  </xsl:for-each>
  <xsl:text>{&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="gu:jsonSerialize"/>
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:text>  }</xsl:text>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Handle a list item in JSON syntax</para>
</xs:template>
<xsl:template match="l" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:for-each select="@n">
    <xsl:value-of select='gu:jsonString(.)'/>: <xsl:text/>
  </xsl:for-each>
  <xsl:text>[&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="gu:jsonSerialize"/>
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:text>  ]</xsl:text>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Handle a string item in JSON syntax</para>
</xs:template>
<xsl:template match="s" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:value-of select="concat(@n/concat(gu:jsonString(.),': '),
                               gu:jsonString(@v))"/>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Handle a number item in JSON syntax</para>
</xs:template>
<xsl:template match="n" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:value-of select="concat(gu:jsonString(@n),': ',@v)"/>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Handle a false Boolean value in JSON syntax</para>
</xs:template>
<xsl:template match="f" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:value-of select="concat(gu:jsonString(@n),': false')"/>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Handle a true Boolean value in JSON syntax</para>
</xs:template>
<xsl:template match="t" mode="gu:jsonSerialize">
  <xsl:for-each select="ancestor::*"><xsl:text>  </xsl:text></xsl:for-each>
  <xsl:value-of select="concat(gu:jsonString(@n),': true')"/>
  <xsl:if test="following-sibling::*">,</xsl:if>
  <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xs:template>
  <para>Unhandled item in JSON syntax</para>
</xs:template>
<xsl:template match="*" mode="gu:jsonSerialize">
  <xsl:message terminate="yes">
    <xsl:text>Unhandled: </xsl:text>
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:for-each select="
                   count(preceding-sibling::*[name(.)=name(current())])[.!=0]">
        <xsl:text/>[<xsl:value-of select="."/>]<xsl:text/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:message>
</xsl:template>

<xs:function>
  <para>
    Escape a JSON string value
  </para>
  <xs:param name="gu:value"><para>The value of the string.</para></xs:param>
</xs:function>
<xsl:function name="gu:jsonString" as="xsd:string">
  <xsl:param name="gu:value" as="xsd:string"/>
  <xsl:value-of select='concat("""",
       replace(
         replace(
           replace(
             replace(
               replace($gu:value,"\\","\\\\"),
                     """","\\"""),
                   "\n","\\n"),
                 "\r","\\r"),
               "\t","\\t"),
                               """")'/>
</xsl:function>

</xsl:stylesheet>

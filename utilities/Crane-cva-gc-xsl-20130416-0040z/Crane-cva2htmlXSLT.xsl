<?xml version="1.0" encoding="US-ASCII"?>
<!--
     Render an OASIS context/value association file with an extended set of
     information not found in the Crane-cva2html.xsl stylesheet.  This
     utilizes the Crane-cva2html.xsl stylesheet in order to extend the result,
     and assumes that stylesheet is in the same directory as this stylesheet.

     This stylesheet is run twice in order to produce the result:
     
     (1) - CVA input processed with this stylesheet produces a temporary file
     (2) - the temporary file is, itself, an XSLT stylesheet that is run
           using itself as the both the stylesheet and the stylesheet input

     An example invocation for this processing model is as follows:

       java -jar saxon.jar -o filetemp.xsl file.cva Crane-cva2htmlXSLT.xsl
       java -jar saxon.jar -o file.html filetemp.xsl filetemp.xsl

     This processing model for the stylesheet prevent this stylesheet from
     being used in a browser with stylesheet association in the CVA file.

 $Id: Crane-cva2htmlXSLT.xsl,v 1.2 2013/04/16 00:40:22 admin Exp $

 Copyright (C) - Crane Softwrights Ltd.
               - http://www.CraneSoftwrights.com/links/res-dev.htm
 
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
     was obtained 2003-07-26 at http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5
--> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xslo="urn:X-dummy"
                xmlns:z="http://www.CraneSoftwrights.com/ns/cva2htmlXSLT.htm"
                xmlns:cva=
         "http://docs.oasis-open.org/codelist/ns/ContextValueAssociation/1.0/"
                xmlns:h="http://www.w3.org/TR/REC-html40"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

<xsl:import href="Crane-cva2html.xsl"/>

<xsl:namespace-alias stylesheet-prefix="xslo" result-prefix="xsl"/>

<xsl:output method="xml"/>

<!--========================================================================-->
<!--wrap processing of document element so that document element can be
processed on its own in another context-->
  
<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="cva:ContextValueAssociation">
      <xsl:call-template name="z:stylesheet"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--========================================================================-->
<!--populate a copy of every value list's identification-->

<xsl:template mode="z:Identification" match="cva:ContextValueAssociation">
  <xsl:apply-templates mode="z:Identification"
                       select="document('',/)/*/ValueLists/ValueList"/>
  <xsl:apply-templates mode="z:Identification"
                       select="document(Include/@uri)/*"/>
</xsl:template>

<xsl:template mode="z:Identification" match="ValueList">
  <z:Identification xml:id="{generate-id(.)}" xmlns="">
    <!--internal masquerading metadata has precedence over external metadata-->
    <xsl:apply-templates mode="z:Identification" select="Identification"/>
    <!--external maquerading metadata has precedence over external metadata-->
    <xsl:apply-templates mode="z:Identification" 
                         select="document(@masqueradeUri,.)/*/Identification"/>
    <!--external actual metadata from the list being used-->
    <xsl:apply-templates mode="z:Identification" 
                         select="document(@uri,.)/*/Identification"/>
  </z:Identification>
</xsl:template>

<xsl:template mode="z:Identification"
              match="Identification | Identification//*">
  <xsl:element name="{local-name(.)}" xmlns="">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="z:Identification" select="node()"/>
  </xsl:element>
</xsl:template>

<xsl:template mode="z:Identification" match="*"/>
  <!--========================================================================-->
<!--the generated stylesheet-->

<xsl:template name="z:stylesheet">
  <xslo:stylesheet version="1.0" exclude-result-prefixes="z cva h">
    <z:data xmlns="">
      <xsl:apply-templates mode="z:Identification" select="."/>
    </z:data>
    <xslo:template match="h:* | x:*" xmlns:x="http://www.w3.org/1999/xhtml">
      <xslo:element name="{{local-name()}}"
                    namespace="http://www.w3.org/1999/xhtml">
        <xslo:copy-of select="@*"/>
        <xslo:apply-templates/>
      </xslo:element>
    </xslo:template>
    <xslo:template match="/">
      <xsl:apply-imports/>
    </xslo:template>
  </xslo:stylesheet>
</xsl:template>

<xsl:template name="metadataDetail">
  <xsl:param name="metadata" select="/.."/>
  <xsl:param name="valuelist" select="/.."/>
  <xsl:if test="$metadata/InstanceMetadata">
    <xslo:variable name="report">
      <xsl:for-each select="$metadata/InstanceMetadata">
        <xslo:for-each select="(document('')/*/
                  z:data/z:Identification[@xml:id='{generate-id($valuelist)}']/
                  Identification/{@identification})[1]">
          <li>
            <samp>
              <xsl:value-of select="@address"/>
              <xsl:text>="</xsl:text>
              <xslo:value-of select="."/>
              <xsl:text>"</xsl:text>
            </samp>
          </li>
        </xslo:for-each>
      </xsl:for-each>
    </xslo:variable>
    <xslo:if test="normalize-space($report)">
      <ul again="this">
        <xslo:copy-of select="$report"/>
      </ul>
    </xslo:if>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>

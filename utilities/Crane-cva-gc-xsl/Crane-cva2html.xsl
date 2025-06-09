<?xml version="1.0" encoding="US-ASCII"?>
<!--
     Render an OASIS context/value association file to a simple HTML 
     presentation.

     This provides the basic mechanics so that users can embellish on this
     presentation for their own purposes.

     This stylesheet accesses the Crane-gc2html.xsl stylesheet that
     is assumed to be in the same directory.

     To enable an OASIS context/value association file to be rendered in a 
     browser, add the following processing instruction to the start of 
     the file (changing the href= as required to point to the stylesheet):

     <?xml-stylesheet type="text/xsl" href="Crane-cva2html.xsl"?>

     When in a Windows interface, drag the association file from the Windows
     Explorer to Mozilla Firefox or Internet Explorer to engage the stylesheet
     presentation. 

     For operation in Internet Explorer it is necessary in Windows to indicate
     that ".cva" files are XML documents.  This is done in Windows Explorer
     under the Tools/FolderOptions... menu, under the File Types tab, clicking
     the "New" button, setting the File Extension to "cva", then clicking the
     "Advanced" button to set the Asociated File Type to "XML Document".  Using
     the "Change" button next to the "Opens with:" herald, one can then set
     the recommended program to be Internet Explorer.

     When creating standalone HTML from the XML, two examples of using Saxon
     are as follows, the first explicitly referencing the stylesheet and the
     second looking for the embedded stylesheet association:

       java -jar saxon.jar -o file.html file.cva Crane-cva2html.xsl
       java -jar saxon.jar -o file.html -a file.cva

     Note that it is not necessary for any referenced value list files to have
     an embedded stylesheet when using a stylesheet with an OASIS context/value
     association file.

     Implementation note: this version does not attempt to detect duplicate
     presentations of the same code list from multiple references either
     within one context/value file or included context/value files.

 $Id: Crane-cva2html.xsl,v 1.32 2013/04/16 00:40:21 admin Exp $

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
                xmlns:z="urn:x-Crane"
                xmlns:cva=
         "http://docs.oasis-open.org/codelist/ns/ContextValueAssociation/1.0/"
                xmlns:h="http://www.w3.org/TR/REC-html40"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="z cva h"
                version="1.0">

<xsl:import href="Crane-gc2html.xsl"/>

<xsl:key name="z:ids" match="*[@xml:id]" use="@xml:id"/>

<!--========================================================================-->
<!--all messages separated so they can be overridden in another language-->

<xsl:variable name="z:titlePrefix">Value list constraints: </xsl:variable>
<xsl:variable name="z:badDocElemTitle">Unexpected XML document for stylesheet</xsl:variable>
<xsl:variable name="z:noTitle">Untitled association file</xsl:variable>
<xsl:variable name="z:fileNotFound">(file not found)</xsl:variable>
<xsl:variable name="z:toc">Table of contents</xsl:variable>
<xsl:variable name="z:includes">Includes referenced</xsl:variable>
<xsl:variable name="z:valueTests">Value tests</xsl:variable>
<xsl:variable name="z:valueTest">value test</xsl:variable>
<xsl:variable name="z:noValueTests">(no tests defined)</xsl:variable>
<xsl:variable name="z:valueLists">Value lists</xsl:variable>
<xsl:variable name="z:valueList">value list</xsl:variable>
<xsl:variable name="z:override">overriding metadata</xsl:variable>
<xsl:variable name="z:detail">detail</xsl:variable>
<xsl:variable name="z:noValueLists">(no lists defined)</xsl:variable>
<xsl:variable name="z:valueUnexpected"
                        >unexpected element referenced for value</xsl:variable>
<xsl:variable name="z:instanceMetadataSets"
                                         >Instance metadata sets</xsl:variable>
<xsl:variable name="z:noInstanceMetadataSets"
                            >(no instance metadata sets defined)</xsl:variable>
<xsl:variable name="z:instancemetadataset"
                                         >instance metadata set</xsl:variable>
<xsl:variable name="z:contexts">Document contexts</xsl:variable>
<xsl:variable name="z:noContexts">(no document contexts defined)</xsl:variable>
<xsl:variable name="z:badListId">
  <font color="red">
    <b>(error: a list or test with this identifier is not defined)</b>
  </font>
</xsl:variable>
<xsl:variable name="z:badMDId">
  <font color="red">
    <b>(error: a metadata set with this identifier is not defined)</b>
  </font>
</xsl:variable>
<xsl:template name="z:badDocElem">
  <xsl:param name="ns"/>
  <p>
    Unexpected XML document for <samp>Crane-cva2html.xsl</samp> stylesheet.
  </p>
  <p>
    The document element is expected to be named 
    <samp>ContextValueAssociation</samp> in the
    <samp><xsl:value-of select="$ns"/></samp>
    namespace, otherwise this message is displayed.
  </p>
  <p>
    What was found in this document is the document element named
    <samp><xsl:value-of select="name(.)"/></samp> in the
    <samp><xsl:value-of select="namespace-uri(.)"/></samp> namespace.
  </p>
</xsl:template>

<!--========================================================================-->
<!--wrap processing of document element so that document element can be
processed on its own in another context-->
  
<xsl:variable name="z:htmlhead"/><!--additional content to add to the header-->

<xsl:template match="/">
  <!--all HTML documents start the same way-->
  <html>
    <head>
      <xsl:choose>
        <xsl:when test="cva:ContextValueAssociation">
          <!--document is what we are expecting-->
          <title>
            <xsl:choose>
              <xsl:when test="cva:ContextValueAssociation/Title">
                <xsl:value-of select="cva:ContextValueAssociation/Title"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="$z:titlePrefix"/>
                name="<xsl:value-of select="*/@name"/>"
                <xsl:for-each select="*/@id">
                  id="<xsl:value-of select="."/>"
                </xsl:for-each>
                <xsl:for-each select="*/@queryBinding">
                  querybinding="<xsl:value-of select="."/>"
                </xsl:for-each>
                <xsl:for-each select="*/@version">
                  version="<xsl:value-of select="."/>"
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </title>
        </xsl:when>
        <xsl:otherwise>
          <!--this is an error situation-->
          <title><xsl:copy-of select="$z:badDocElemTitle"/></title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$z:htmlhead"/>
    </head>
    <body>
      <!--present the association files first-->
      <xsl:apply-templates mode="z:cva2html" select="document('',.)/*"/>
         <!--the above select may look strange, but it prevents a distinction
             between the source document node and the node of the document
             opened up relative to the source; this is necessary for the
             detection of infinite loops-->
      <!--present the list files next-->
      <xsl:apply-templates mode="z:lists" select="document('',.)/*"/>
      <!--present the metadata-only list files next-->
      <xsl:apply-templates mode="z:masqueradeLists" select="document('',.)/*"/>
      <p align="right">
        <small>
          <xsl:text/>Report created by <samp>Crane-cva2html.xsl</samp>
          <xsl:text> $Revision: 1.32 $ </xsl:text>
          <a href="http://www.CraneSoftwrights.com/links/res-dev.htm">
            <xsl:text>Crane Softwrights Ltd.</xsl:text>
          </a>
        </small>
      </p>
    </body>
  </html>
</xsl:template>

<xsl:template match="/*" mode="z:cva2html">
  <!--the document being asked to be formatted is not as expected-->
  <xsl:call-template name="z:badDocElem">
    <xsl:with-param name="ns" select="string(document('')/*/namespace::a)"/>
  </xsl:call-template>
</xsl:template>

<!--========================================================================-->
<!--main without detail, but including infinite loop detection-->

<xsl:template match="/cva:ContextValueAssociation" mode="z:cva2html" 
              priority="2">
  <xsl:param name="main"/>
  <xsl:param name="loop-identifiers" select="' '"/>
  <xsl:if test="not( contains( $loop-identifiers, 
                                concat(' ',generate-id(.),' ' ) ) )">
    <!--then not in an infinite loop-->
    <xsl:if test="normalize-space($loop-identifiers)">
      <!--break between files with a horizontal rule-->
      <hr/>
    </xsl:if>
    <xsl:variable name="new-loop-identifiers"
                  select="concat($loop-identifiers,generate-id(.),' ' )"/>
    <!--anchor the title of the file-->
    <a name="{generate-id(.)}">
      <xsl:choose>
        <xsl:when test="Title">
          <xsl:apply-templates select="Title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$z:noTitle"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
    <!--subtitle with identification information-->
    <h4>
      <samp>name="<xsl:value-of select="@name"/>"<xsl:text/>
      <xsl:for-each select="@id">
        <br/>id="<xsl:value-of select="."/>"<xsl:text/>
      </xsl:for-each>
      <xsl:for-each select="@queryBinding">
        <br/>querybinding="<xsl:value-of select="."/>"<xsl:text/>
      </xsl:for-each>
      <xsl:for-each select="@version">
        <br/>version="<xsl:value-of select="."/>"<xsl:text/>
      </xsl:for-each>
      </samp>
    </h4>
    <!--any description information as a whole-->
    <xsl:apply-templates select="Annotation"/>
    <xsl:if test="ValueTests | ValueLists |
                  InstanceMetadataSets | Contexts">
      <h3><xsl:copy-of select="$z:toc"/></h3>
      <blockquote>
        <xsl:if test="ValueTests">
          <a href="#ValueTests">
            <xsl:value-of select="$z:valueTests"/>
            </a>
            <br/>
        </xsl:if>
        <xsl:if test="ValueLists">
          <a href="#ValueLists">
            <xsl:value-of select="$z:valueLists"/>
            </a>
            <br/>
        </xsl:if>
        <xsl:if test="InstanceMetadataSets">
          <a href="#InstanceMetadataSets">
            <xsl:value-of select="$z:instanceMetadataSets"/>
            </a>
            <br/>
        </xsl:if>
        <xsl:if test="Contexts">
          <a href="#Contexts">
            <xsl:value-of select="$z:contexts"/>
            </a>
            <br/>
        </xsl:if>
      </blockquote>
    </xsl:if>
    <!--make references to included files-->
    <xsl:if test="Include">
      <h3><xsl:value-of select="$z:includes"/></h3>
      <xsl:for-each select="Include">
        <xsl:variable name="uri" select="@uri"/>
        <p>
          <samp>
            <xsl:text>uri="</xsl:text>
            <xsl:for-each select="document($uri,.)/*">
              <a href="#{generate-id(.)}"><xsl:value-of select="$uri"/></a>
            </xsl:for-each>
            <xsl:if test="not(document($uri,.))">
              <xsl:value-of select="$uri"/>
            </xsl:if>
            <xsl:text>"</xsl:text>
          </samp>
          <xsl:if test="not(document($uri,.))">
            <xsl:copy-of select="$z:fileNotFound"/>
          </xsl:if>
        </p>
      </xsl:for-each>
    </xsl:if>
    <!--render the information in the current file-->
    <xsl:apply-templates select="ValueTests | ValueLists |
                                 InstanceMetadataSets | Contexts"/>
    <!--render the information for included files-->
    <xsl:if test="Include">
      <xsl:for-each select="Include">
        <xsl:variable name="uri" select="@uri"/>
        <xsl:choose>
          <xsl:when test="not(document($uri,.))">
            <p>
              <samp>
                <xsl:text/>uri="<xsl:value-of select="$uri"/>"<xsl:text/>
              </samp>
              <xsl:copy-of select="$z:fileNotFound"/>
            </p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="document($uri,.)/*" 
                                 mode="z:cva2html">
              <xsl:with-param name="loop-identifiers" 
                              select="$new-loop-identifiers"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!--========================================================================-->
<!--context vocabulary-->

<!--titles, identification and description-->
<xsl:template match="Title">
  <h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match="Annotation">
  <!--the text children of this are ignored, so just push the children-->
  <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="AppInfo">
  <!--suppress application information; but having the template allows the
      template to be overridden-->
</xsl:template>

<xsl:template match="Description">
  <!--documentary constructs targeted for the human reader-->
  <xsl:choose>
    <xsl:when test="text()[normalize-space(.)]">
      <p><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--value lists-->
<xsl:template match="ValueTests">
  <a name="ValueTests"/>
  <h3><xsl:copy-of select="$z:valueTests"/></h3>
  <xsl:if test="not(ValueTest)">
    <p><i><xsl:copy-of select="$z:noValueTests"/></i></p>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ValueTest">
  <h4>
    <!--identify the value test-->
    <a name="{generate-id(.)}">
      <samp>xml:id="<xsl:value-of select="@xml:id"/>"</samp>
      <xsl:text> </xsl:text>
      <samp>test="<xsl:value-of select="@test"/>"</samp>
    </a>
  </h4>
  <xsl:if test="normalize-space(.)">
    <!--documentation-->
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:if>
</xsl:template>

<!--value lists-->
<xsl:template match="ValueLists">
  <a name="ValueLists"/>
  <h3><xsl:copy-of select="$z:valueLists"/></h3>
  <xsl:if test="not(ValueList)">
    <p><i><xsl:copy-of select="$z:noValueLists"/></i></p>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ValueList">
  <h4>
    <!--identify the value list-->
    <a name="{generate-id(.)}">
      <samp>xml:id="<xsl:value-of select="@xml:id"/>"</samp>
      <xsl:for-each select="@key">
        <samp> key="<xsl:value-of select="."/>"</samp>
      </xsl:for-each>
      <samp> uri="<xsl:text/>
        <a href="#{generate-id(document(@uri)/*)}">
          <xsl:value-of select="@uri"/>
        </a>
        <xsl:text/>"</samp>
      <xsl:for-each select="@masqueradeUri">
        <samp> masqueradeUri="<xsl:text/>
        <a href="#{generate-id(document(.)/*)}">
          <xsl:value-of select="."/>
        </a>
        <xsl:text/>"</samp>
      </xsl:for-each>
      <xsl:for-each select="@*[name()!='xml:id' and name()!='key' and
                               name()!='uri' and name()!='masqueradeUri']">
        <samp>
          <xsl:text> </xsl:text>
          <xsl:value-of select="name(.)"/>="<xsl:value-of select="."/>"</samp>
      </xsl:for-each>
    </a>
  </h4>
  <xsl:if test="normalize-space(.)">
    <!--documentation-->
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:if>
</xsl:template>

<xsl:template match="Identification">
  <!--overriding metadata-->
  <table>
    <xsl:apply-templates select="*" mode="z:identification"/>
  </table>
</xsl:template>

<xsl:template match="*[*]" mode="z:identification">
  <!--reveal nested meta data using an oblique separator-->
  <xsl:param name="prefix"/>
  <xsl:apply-templates select="*" mode="z:identification">
    <xsl:with-param name="prefix" select="concat($prefix,local-name(.),'/')"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="z:identification">
  <!--show a single piece of meta data-->
  <xsl:param name="prefix"/>
  <tr>
    <td valign="top">
      <samp>
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="local-name(.)"/>
        <xsl:if test="@*">
          <!--indicate the presence of attributes-->
          <xsl:text> (</xsl:text>
          <xsl:for-each select="@*">
            <xsl:if test="position()>1"><xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="concat(name(.),'=&quot;',.,'&quot;')"/>
          </xsl:for-each>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </samp>
    </td>
    <td valign="top"><samp>=</samp></td>
    <td valign="top"><samp><xsl:value-of select="."/></samp></td>
  </tr>
</xsl:template>

<!--value lists-->
<xsl:template match="InstanceMetadataSets">
  <a name="InstanceMetadataSets"/>
  <h3><xsl:copy-of select="$z:instanceMetadataSets"/></h3>
  <xsl:if test="not(InstanceMetadataSet)">
    <p><i><xsl:copy-of select="$z:noInstanceMetadataSets"/></i></p>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="InstanceMetadataSet">
  <h4>
    <!--identify the value test-->
    <a name="{generate-id(.)}">
      <samp>xml:id="<xsl:value-of select="@xml:id"/>"</samp>
    </a>
  </h4>
  <xsl:if test="normalize-space(.)">
    <!--documentation-->
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:if>
</xsl:template>

<xsl:template match="InstanceMetadata">
  <p>
    <b>
      <!--identify the combination-->
      <samp>address="<xsl:value-of select="@address"/>"</samp>
      <xsl:text> </xsl:text>
      <samp>identification="<xsl:value-of select="@identification"/>"</samp>
    </b>
  </p>
  <xsl:if test="normalize-space(.)">
    <!--documentation-->
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:if>
</xsl:template>

<!--contexts-->
<xsl:template match="Contexts">
  <a name="Contexts"/>
  <h3><xsl:copy-of select="$z:contexts"/></h3>
  <xsl:if test="not(Context)">
    <p><i><xsl:copy-of select="$z:noContexts"/></i></p>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="Context">
  <!--identify the context-->
  <h4>
    <samp>address="<xsl:value-of select="@address"/>"</samp>
  </h4>
  <!--qualify the context-->
  <ul>
    <xsl:for-each select="@metadata">
      <li>
        <xsl:value-of select="$z:instancemetadataset"/>
        <xsl:text>: </xsl:text>
        <xsl:choose>
          <xsl:when test="not(key('z:ids',.))">
            <!--report missing information-->
            <samp><xsl:value-of select="."/></samp>
            <xsl:copy-of select="$z:badMDId"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="key('z:ids',.)">
              <samp>
                <a href="#{generate-id(.)}">
                  <xsl:value-of select="@xml:id"/>
                </a>
              </samp>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </xsl:for-each>
    <xsl:apply-templates select="@mark"/>
    <xsl:apply-templates select="Message"/>
    <xsl:call-template name="values">
      <xsl:with-param name="metadata" select="key('z:ids',@metadata)"/>
    </xsl:call-template>
  </ul>
  <!--documentation-->
  <xsl:if test="text()[normalize-space(.)] or *[not(self::Message)]">
    <blockquote>
      <xsl:comment/><!--browsers have a problem with an empty blockquote-->
      <xsl:apply-templates select="*[not(self::Message)]"/>
    </blockquote>
  </xsl:if>
</xsl:template>

<!--recursive reporting of the lists of values-->
<xsl:template name="values">
  <xsl:param name="metadata" select="/.."/>
  <xsl:param name="lists" select="concat(normalize-space(@values),' ' )"/>
  <xsl:variable name="list" select="substring-before($lists,' ')"/>
  <xsl:if test="$list">
    <xsl:if test="not(key('z:ids',$list))">
      <!--report missing information for the next linked list of values-->
      <li>
        <xsl:value-of select="$z:valueList"/>
        <xsl:text/>: <samp><xsl:value-of select="$list"/></samp>
        <xsl:copy-of select="$z:badListId"/>
      </li>
    </xsl:if>
    <xsl:for-each select="key('z:ids',$list)">
      <li>
        <!--report information for the next linked list of values-->
        <xsl:choose>
          <xsl:when test="self::ValueList">
            <xsl:value-of select="$z:valueList"/>            
          </xsl:when>
          <xsl:when test="self::ValueTest">
            <xsl:value-of select="$z:valueTest"/>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$z:valueUnexpected"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>: </xsl:text>
        <samp><a href="#{generate-id(.)}">
          <xsl:value-of select="@xml:id"/></a>
        </samp>
        <xsl:text> (</xsl:text>
        <xsl:if test="Identification/*">
          <a href="#{generate-id(.)}">
            <xsl:value-of select="$z:override"/>
          </a>
          <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:for-each select="document(@uri)/*">
          <a href="#{generate-id(.)}"><xsl:value-of select="$z:detail"/></a>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
        <xsl:call-template name="metadataDetail">
          <xsl:with-param name="metadata" select="$metadata"/>
          <xsl:with-param name="valuelist" select="."/>
        </xsl:call-template>
      </li>
    </xsl:for-each>
    <!--report the next value-->
    <xsl:call-template name="values">
      <xsl:with-param name="lists" select="substring-after($lists,' ')"/>
      <xsl:with-param name="metadata" select="$metadata"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!--a dummy function that is overridden when needed by the extended display-->
<xsl:template name="metadataDetail">
  <xsl:param name="metadata" select="/.."/>
  <xsl:param name="valuelist" select="/.."/>
</xsl:template>

<!--a customized Schematron message-->
<xsl:template match="Message">
  <li>
    <xsl:apply-templates select="." mode="z:expose"/>
  </li>
</xsl:template>

<!--what mark does this context value check have in the end results?-->
<xsl:template match="@mark">
  <li>
    <samp>mark="<xsl:value-of select="."/>"</samp>
  </li>
</xsl:template>

<!--expose the markup in monospaced text-->
<xsl:template match="*" mode="z:expose">
  <!--start tag-->
  <samp>
    <xsl:text/>&lt;<xsl:value-of select="name(.)"/>
    <xsl:for-each select="@*">
      <xsl:value-of select="concat(' ',name(.),'=&#34;',.,'&#34;')"/>
    </xsl:for-each>
    <!--check for empty tag-->
    <xsl:if test="not(node())">/</xsl:if>
    <xsl:text>></xsl:text>
  </samp>
  <xsl:if test="node()">
    <!--content-->
    <xsl:apply-templates mode="z:expose"/>
    <!--end tag-->
    <samp>
      <xsl:text/>&lt;/<xsl:value-of select="name(.)"/>><xsl:text/>
    </samp>
  </xsl:if>
</xsl:template>

<!--========================================================================-->
<!--finding genericode files-->

<!--this needs to be updated to prevent the presentation of duplicates-->
<xsl:template match="/cva:ContextValueAssociation" mode="z:lists">
  <!--keep track for infinite loops (doesn't accommodate duplicates)-->
  <xsl:variable name="cvas-visited" select="/.."/>
  <xsl:if test="count($cvas-visited | .) != count($cvas-visited)">
    <xsl:for-each select="ValueLists/ValueList/@uri">
      <hr/>
      <xsl:apply-templates select="document(.)/*">
        <xsl:with-param name="uri" select="."/>
      </xsl:apply-templates>
    </xsl:for-each>
    <!--make sure all of the included fragments are included-->
    <xsl:apply-templates select="document(Include/@uri)/*" mode="z:lists">
      <xsl:with-param name="cvas-visited" select="$cvas-visited | ."/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

<!--anything else in this mode doesn't trigger any output-->
<xsl:template match="*" mode="z:lists"/>

<!--this needs to be updated to prevent the presentation of duplicates-->
<xsl:template match="/cva:ContextValueAssociation" mode="z:masqueradeLists">
  <!--keep track for infinite loops (doesn't accommodate duplicates)-->
  <xsl:variable name="cvas-visited" select="/.."/>
  <xsl:if test="count($cvas-visited | .) != count($cvas-visited)">
    <xsl:for-each select="ValueLists/ValueList/@masqueradeUri">
      <hr/>
      <xsl:apply-templates select="document(.)/*">
        <xsl:with-param name="uri" select="."/>
        <xsl:with-param name="metadata-only" select="true()"/>
      </xsl:apply-templates>
    </xsl:for-each>
    <!--make sure all of the included fragments are included-->
    <xsl:apply-templates select="document(Include/@uri)/*"
                         mode="z:masqueradeLists">
      <xsl:with-param name="cvas-visited" select="$cvas-visited | ."/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

<!--anything else in this mode doesn't trigger any output-->
<xsl:template match="*" mode="z:masqueradeLists"/>

<!--========================================================================-->
<!--HTML vocabulary-->

<xsl:template match="h:* | x:*" xmlns:x="http://www.w3.org/1999/xhtml">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>

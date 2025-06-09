<?xml version="1.0" encoding="US-ASCII"?>
<!--
     Render an OASIS genericode file to a simple HTML presentation.

     This provides the basic mechanics so that users can embellish on this
     presentation for their own purposes.

     To enable an OASIS genericode file to be rendered in a browser,
     add the following processing instruction to the start of the file:

     <?xml-stylesheet type="text/xsl" href="Crane-gc2html.xsl"?>

     When in a Windows interface, drag the genericode file from the Windows
     Explorer to Mozilla Firefox or Internet Explorer to engage the stylesheet
     presentation.

     For operation in Internet Explorer it is necessary in Windows to indicate
     that ".gc" files are XML documents.  This is done in Windows Explorer
     under the Tools/FolderOptions... menu, under the File Types tab, clicking
     the "New" button, setting the File Extension to "gc", then clicking the
     "Advanced" button to set the Asociated File Type to "XML Document".  Using
     the "Change" button next to the "Opens with:" herald, one can then set
     the recommended program to be Internet Explorer.

     When creating standalone HTML from the XML, two examples of using Saxon
     are as follows, the first explicitly referencing the stylesheet and the
     second looking for the embedded stylesheet association:

       java -jar saxon.jar -o file.html file.gc Crane-gc2html.xsl
       java -jar saxon.jar -o file.html -a file.gc

     Note that it is not necessary for any referenced value list files to have
     an embedded stylesheet when using a stylesheet with an OASIS context/value
     association file.
     
     This stylesheet supports an OASIS genericode file with a document element
     of either <prefix:CodeList> or <prefix:CodeListSet>.

 $Id: Crane-gc2html.xsl,v 1.17 2011/11/13 01:40:31 admin Exp $

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
              xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
              xmlns:gcold="http://genericode.org/2006/ns/CodeList/0.4/"
              xmlns:h="http://www.w3.org/TR/REC-html40"
              xmlns:z="urn:x-Crane"
              xmlns="http://www.w3.org/1999/xhtml"
              exclude-result-prefixes="gc gcold h z"
              version="1.0">

<!--========================================================================-->
<!--all messages separated so they can be overridden in another language-->

<xsl:variable name="gc:listTitle">Enumeration:</xsl:variable>
<xsl:variable name="gc:listSetTitle">Enumeration set:</xsl:variable>
<xsl:variable name="gc:badDocElemTitle">Unexpected XML document for stylesheet</xsl:variable>
<xsl:variable name="gc:listMembersSuppressed"
>The presentation of list members has been suppressed because only the
metadata of this list is being referenced.</xsl:variable>
<xsl:variable name="gc:listHeading">List: </xsl:variable>
<xsl:variable name="gc:listSetHeading">List: </xsl:variable>
<xsl:template name="gc:badDocElem">
  <xsl:param name="ns"/>
  <p>
 Unexpected XML document for <samp>Crane-gc2html.xsl</samp> stylesheet.
  </p>
  <p>
    The document element is expected to be named either
    <samp>CodeList</samp> or <samp>CodeListSet</samp>in the
    <samp><xsl:value-of select="$ns"/></samp>
    namespace, otherwise this message is displayed.
  </p>
  <p>
    What was found in this document is the document element named
    <samp><xsl:value-of select="name(.)"/></samp> in the
    <samp><xsl:value-of select="namespace-uri(.)"/></samp> namespace.
  </p>
</xsl:template>

<xsl:variable name="alignment" select="'left'"/><!--or center or right-->
<xsl:variable name="padding-left" select="'3px'"/>
<xsl:variable name="padding-right" select="'3px'"/>

<!--========================================================================-->
<!--wrap processing of document element so that document element can be
    processed on its own in another context-->

<xsl:variable name="z:htmlhead"/><!--additional content to add to the header-->

<xsl:template match="/">
  <html>
    <head>
      <!--determine the text to put in the browser title bar-->
      <xsl:choose>
        <xsl:when test="gc:CodeList | gcold:CodeList |
                        gc:CodeListSet | gc:CodeListSet">
          <!--found what we are expecting-->
          <title>
            <xsl:choose>
              <xsl:when test="gc:CodeListSet | gc:CodeListSet">
                <xsl:copy-of select="$gc:listSetTitle"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="$gc:listTitle"/>
              </xsl:otherwise>
            </xsl:choose>
            ShortName=<xsl:value-of select="*/Identification/ShortName"/>
          </title>
        </xsl:when>
        <xsl:otherwise>
          <title><xsl:copy-of select="$gc:badDocElemTitle"/></title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$z:htmlhead"/>
    </head>
    <body>
      <!--process the information for the page-->
      <xsl:apply-templates/>
      <!--add source information at the end-->
      <p align="right">
        <small>
          <xsl:text/>Report created by <samp>Crane-gc2html.xsl</samp>
          <xsl:text> $Revision: 1.17 $ </xsl:text>
          <a href="http://www.CraneSoftwrights.com/links/res-dev.htm">
            <xsl:text>Crane Softwrights Ltd.</xsl:text>
          </a>
        </small>
      </p>
    </body>
  </html>
</xsl:template>

<!--ooops ... the document element isn't what is expected-->
<xsl:template match="/*">
  <xsl:call-template name="gc:badDocElem">
    <xsl:with-param name="ns" select="string(document('')/*/namespace::gc)"/>
  </xsl:call-template>
</xsl:template>

<!--========================================================================-->
<!--the document is a list set-->

<xsl:template match="gc:CodeListSet | gcold:CodeListSet" priority="2">
  <h2>
    <a name="{generate-id(.)}">
      <xsl:copy-of select="$gc:listHeading"/>
      <xsl:value-of select="Identification/LongName"/>
    </a>
  </h2>
  <!--documentation for the list set-->
  <xsl:apply-templates select="Annotation/Description/node()"/>
  <!--show the meta data for the list set-->
  <blockquote>
    <xsl:apply-templates select="Identification"/>
  </blockquote>
  <!--process the children-->
  <xsl:apply-templates select="CodeListRef | CodeListSet"/>
</xsl:template>

<xsl:template match="CodeListRef">
  <samp><xsl:value-of select="CanonicalUri"/></samp>
  <!--documentation for the list set-->
  <xsl:apply-templates select="Annotation/Description/node()"/>
  <ul>
    <xsl:for-each select="CanonicalVersionUri">
      <li><samp><xsl:value-of select="."/></samp></li>
    </xsl:for-each>
    <xsl:for-each select="LocationUri">
      <li><samp><a href="{.}"><xsl:value-of select="."/></a></samp></li>
    </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="CodeListSet">
  <h4>
    <a name="{generate-id(.)}">
      <xsl:copy-of select="$gc:listHeading"/>
      <xsl:value-of select="Identification/LongName"/>
    </a>
  </h4>
  <blockquote>
    <!--documentation for the list set-->
    <xsl:apply-templates select="Annotation/Description/node()"/>
    <!--show the meta data for the list set-->
    <blockquote>
      <xsl:apply-templates select="Identification"/>
    </blockquote>
    <!--process the children-->
    <xsl:apply-templates select="CodeListRef | CodeListSet"/>
  </blockquote>
</xsl:template>

<!--the document is a list-->
<xsl:template match="gc:CodeList | gcold:CodeList" priority="2">
  <!--when used from the OASIS context/value association file stylesheet, the
      $uri parameter reflects the URI at which this file is being referenced,
      and the $metadata-only parameter reflects the request to render only
      the metadata and not any list values-->
  <xsl:param name="uri"/>
  <xsl:param name="metadata-only" select="false()"/>
  <h2>
    <a name="{generate-id(.)}">
      <xsl:copy-of select="$gc:listHeading"/>
      <xsl:choose>
        <xsl:when test="$uri">
          <samp>uri=<xsl:value-of select="$uri"/></samp>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="Identification/LongName"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </h2>
  <!--documentation for the list-->
  <xsl:apply-templates select="Annotation/Description/node()"/>
  <!--show the meta data for the list-->
  <blockquote>
    <xsl:apply-templates select="Identification"/>
  </blockquote>
  <xsl:choose>
    <xsl:when test="$metadata-only">
      <!--show only the metadata; report if members have been suppressed-->
      <xsl:if test="SimpleCodeList/Row">
        <table border="1">
          <tr>
            <td>
              <xsl:value-of select="$gc:listMembersSuppressed"/>
            </td>
          </tr>
        </table>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!--show the list content, including the meta data for the items-->
      <table border="1">
        <xsl:apply-templates select="ColumnSet"/>
        <xsl:apply-templates select="SimpleCodeList"/>
      </table>
      <!--check for any annotations-->
      <xsl:for-each select="ColumnSet/*[.//Annotation/Description]">
        <!--each annotation into its own table in order to show citation-->
        <table>
          <tr valign="top">
            <td nowrap="nowrap">
              <!--show the citation-->
              <p>
                <sup>
                  <a name="{generate-id(.)}">
     <xsl:text/>(<xsl:number count="*[.//Annotation/Description]"/>)<xsl:text/>
                  </a>
                </sup>
              </p>
            </td>
            <td>
              <!--show the documentation for the Column-->
              <xsl:apply-templates select="Annotation/Description/node()"/>
              <!--show the documentation for constructs defining the column-->
              <xsl:for-each select=".//*[Annotation/Description]">
                <table>
                  <tr valign="top">
                    <!--use two columns in order to handle indentation-->
                    <td><xsl:value-of select="local-name(.)"/></td>
                    <td>
                  <xsl:apply-templates select="Annotation/Description/node()"/>
                    </td>
                  </tr>
                </table>
              </xsl:for-each>
            </td>
          </tr>
        </table>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--present the identification infromation in a table-->
<xsl:template match="Identification">
  <table>
    <xsl:apply-templates mode="gc:identification"/>
  </table>
</xsl:template>

<!--leaf-level identification information is in a cell-->
<xsl:template match="*" mode="gc:identification">
  <tr>
    <td valign="top">
      <samp>
        <xsl:value-of select="name(.)"/>
        <xsl:if test="@*">
          <xsl:text> (</xsl:text>
          <xsl:for-each select="@*">
            <xsl:if test="position()&gt;1"><xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="concat(name(.),'=&#34;',.,'&#34;')"/>
          </xsl:for-each>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </samp>
    </td>
    <td valign="top"><samp>=</samp></td>
    <td valign="top">
      <samp>
        <xsl:choose>
          <xsl:when test="contains(name(.),'LocationUri')">
            <a href="{.}"><xsl:value-of select="."/></a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </samp>
    </td>
  </tr>
</xsl:template>

<!--nested identification information is in a nested table-->
<xsl:template match="*[*]" mode="gc:identification">
  <tr>
    <td valign="top">
      <samp>
        <xsl:value-of select="name(.)"/>
      </samp>
    </td>
    <td valign="top"><br/></td>
    <td valign="top">
      <table>
        <xsl:apply-templates mode="gc:identification"/>
      </table>
    </td>
  </tr>
</xsl:template>

<!--========================================================================-->
<!--the headings of the columns of values-->

<xsl:template match="ColumnSet">
  <tr>
    <xsl:apply-templates/>
  </tr>
</xsl:template>

<!--a title for a piece of meta data of the items-->
<xsl:template match="Column">
  <th align="center" valign="top">
    <!--the column title-->
    <xsl:apply-templates select="ShortName"/>
    <xsl:if test=".//Annotation/Description">
      <!--link to documentation-->
      <sup>
        <small>
          <a href="#{generate-id(.)}">
<xsl:text/>(<xsl:number count="*[.//Annotation/Description]"/>)<xsl:text/>
          </a>
        </small>
      </sup>
    </xsl:if>
    <br/>
    <!--show the meta data-->
    <samp>
      <small>
        <i>Id="<xsl:value-of select="@Id"/>"</i>
        <br/>
        <xsl:text/>(<xsl:value-of select="@Use"/>)<xsl:text/>
        <br/>
        <xsl:for-each select="Data/@*">
          <xsl:if test="position()&gt;1"><xsl:text> </xsl:text></xsl:if>
          <xsl:value-of select="concat(name(.),'=&#34;',.,'&#34;')"/>
        </xsl:for-each>
        <!--if this is a key column, indicate the key information-->
        <xsl:for-each select="../Key[ColumnRef/@Ref=current()/@Id]">
          <br/>
          <xsl:text>[Key Id="</xsl:text>
          <xsl:value-of select="concat(@Id,'&#34;: ',ShortName)"/>
          <xsl:if test=".//Annotation/Description">
            <!--link to documentation-->
            <a href="#{generate-id(.)}">
<xsl:text/>(<xsl:number count="*[.//Annotation/Description]"/>)<xsl:text/>
            </a>
          </xsl:if>
          <xsl:text>]</xsl:text>
        </xsl:for-each>
      </small>
    </samp>
  </th>
</xsl:template>

<xsl:template match="ColumnSet/Key"/>

<!--========================================================================-->
<!--the rows of values-->

<xsl:template match="Row">
  <xsl:variable name="thisRow" select="."/>
  <tr>
    <!--present the columns of the data in the order of the column set
        (which may be different)-->
    <xsl:for-each select="../../ColumnSet/Column/@Id">
      <td align="{$alignment}" valign="top"
          style="padding-left:{$padding-left};padding-right:{$padding-right}">
        <xsl:variable name="thisValue"
                      select="$thisRow/Value[@ColumnRef=current()]"/>
        <xsl:choose>
          <xsl:when test="$thisValue">
            <!--there is an explicitly-named value, so use it-->
            <xsl:apply-templates select="$thisValue/node()"/>
          </xsl:when>
          <xsl:otherwise>
            <!--there is no explicitly-named value, so hunt for it using
                only those values that are not explicitly named-->
            <xsl:apply-templates select="$thisRow/Value[not(@ColumnRef)]">
              <xsl:with-param name="columnId" select="."/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:for-each>
    <!--no error checking that there are values in the row that do not
        correspond to the column sets-->
  </tr>
</xsl:template>

<!--hunt for the value indicated for the column reference-->
<xsl:template match="Value">
  <xsl:param name="columnId"/><!--the columnId being searched-->
  <!--the closest column that is actually referenced-->
  <xsl:variable name="previousRef"
                select="preceding-sibling::Value[@ColumnRef][1]/@ColumnRef"/>
  <!--determine the column reference of the matched column-->
  <xsl:variable name="thisValueReference">
    <xsl:choose>
      <xsl:when test="not($previousRef)">
        <!--count from the first column definition-->
        <xsl:value-of select="../../../ColumnSet/Column[1 +
                                count( current()/preceding-sibling::Value )]/
                              @Id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="../../../ColumnSet/Column[@Id=$previousRef]/
                              following-sibling::Column[
                          count( current()/preceding-sibling::Value ) -
                          count( $previousRef/../preceding-sibling::Value )]/
                              @Id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!--is this what we are looking for?  If so, then show the content-->
  <xsl:if test="$thisValueReference = $columnId">
    <xsl:apply-templates select="node()"/>
  </xsl:if>
</xsl:template>

<!--========================================================================-->
<!--HTML vocabulary-->

<xsl:template match="h:* | x:*" xmlns:x="http://www.w3.org/1999/xhtml">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>

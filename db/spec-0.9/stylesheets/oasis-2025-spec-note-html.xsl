<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY upper 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'>
  <!ENTITY lower 'abcdefghijklmnopqrstuvwxyz'>
  <!ENTITY separator " ">
<!--  <!ENTITY oasis.logo.base64.uri SYSTEM "../OASISLogo.png.base64">-->
  <!ENTITY css-uri            'css/'>   
  <!ENTITY css      SYSTEM '../css/' NDATA dummy>
  <!NOTATION dummy  SYSTEM "">
  <!ENTITY oasis.logo.base64 "
iVBORw0KGgoAAAANSUhEUgAAA+gAAADICAYAAAB758tPAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyVpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ2MCwgMjAyMC8wNS8xMi0xNjowNDoxNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDYyRTc0NzQwQTRDMTFFQjg5QjFGMTVBRjMwQzM2NzgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDYyRTc0NzUwQTRDMTFFQjg5QjFGMTVBRjMwQzM2NzgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDowODZCQjFGRjBBNEMxMUVCODlCMUYxNUFGMzBDMzY3OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDowODZCQjIwMDBBNEMxMUVCODlCMUYxNUFGMzBDMzY3OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Ph/ldRwAAEYWSURBVHja7J0H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
  ">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:lxslt="http://xml.apache.org/xslt"
                xmlns:xalanredirect="org.apache.xalan.xslt.extensions.Redirect"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="saxon xalanredirect lxslt exsl"
                version="1.0">
<!-- This stylesheet is a customization of the DocBook XSL Stylesheets -->
<!-- from http://docs.oasis-open.org/templates/ -->
<!-- See http://sourceforge.net/projects/docbook/ -->
<xsl:import href="../docbook/xsl/html/docbook.xsl"/>
<xsl:include href="titlepage-2025-html.xsl"/>
<xsl:include href="oasis-mathml-html.xsl"/>

<!-- ============================================================ -->
<!-- Parameters -->

<!--online configuration-->
<xsl:param name="css.path">
  <xsl:choose>
    <xsl:when test="false()"/>
    <!--
    <xsl:when test="/processing-instruction('oasis-spec-base-uri')">
      <xsl:value-of
               select="/processing-instruction('oasis-spec-base-uri')"/>
      <xsl:text>&css-uri;</xsl:text>
    </xsl:when>
    -->
    <xsl:otherwise>
      <xsl:for-each select="document('')">
        <xsl:value-of select="unparsed-entity-uri('css')"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="oasis.logo">data:image/png;base64,&oasis.logo.base64;</xsl:param>

<xsl:param name="oasis-base" select="'no'"/>

<!--common between offline and online-->

<xsl:param name="css.stylesheet">oasis-2025-spec-note.css.xml</xsl:param>

<xsl:param name="generate.css.header">1</xsl:param>
<xsl:param name="custom.css.source">
  <xsl:value-of select="$css.path"/>
  <xsl:value-of select="$css.stylesheet"/>
</xsl:param>

<xsl:param name="section.autolabel" select="'1'"/>
<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="toc.section.depth">3</xsl:param>

<xsl:param name="generate.component.toc" select="'1'"/>

<xsl:param name="method" select="'html'"/>
<xsl:param name="indent" select="'no'"/>
<xsl:param name="encoding" select="'UTF-8'"/>
<xsl:param name="automatic-output-filename" select="'no'"/>

<!-- ============================================================ -->
<!-- Filtering unexpected content -->
<xsl:template match="*[normalize-space(@condition) and
                       not(contains(@condition,'oasis'))]" priority="100">
  <!--not for this process-->
</xsl:template>
  
<xsl:template match="*[normalize-space(@condition) and
                       not(contains(@condition,'oasis'))]" priority="100"
              mode="titlepage.mode">
  <!--not for this process-->
</xsl:template>
  
<!-- ============================================================ -->
<!-- The document -->
<xsl:template match="/">
  <xsl:variable name="content">
    <xsl:apply-imports/>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:value-of select="/article/articleinfo/productname[1]"/>
    <xsl:if test="/article/articleinfo/productnumber">
      <xsl:text>-</xsl:text>
      <xsl:value-of select="/article/articleinfo/productnumber[1]"/>
    </xsl:if>
    <xsl:text>.html</xsl:text>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$automatic-output-filename!='yes' or
                    not(normalize-space($filename))">
      <xsl:copy-of select="$content"/>      
    </xsl:when>
    <xsl:when test="element-available('exsl:document')">
      <xsl:message>Writing <xsl:value-of select="$filename"/></xsl:message>
      <exsl:document href="{$filename}"
                     method="{$method}"
                     encoding="{$encoding}"
                     indent="{$indent}">
        <xsl:copy-of select="$content"/>
      </exsl:document>
    </xsl:when> 
    <xsl:when test="element-available('saxon:output')">
      <xsl:message>Writing <xsl:value-of select="$filename"/></xsl:message>
      <saxon:output href="{$filename}"
                    method="{$method}"
                    encoding="{$encoding}"
                    indent="{$indent}">
        <xsl:copy-of select="$content"/>
      </saxon:output>
    </xsl:when>
    <xsl:when test="element-available('xalanredirect:write')">
      <!-- Xalan uses xalanredirect -->
      <xsl:message>Writing <xsl:value-of select="$filename"/></xsl:message>
      <xalanredirect:write file="{$filename}">
        <xsl:copy-of select="$content"/>
      </xalanredirect:write>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->
<!-- HTML META -->

<xsl:template name="user.head.content.extension">
</xsl:template>

<xsl:template name="user.head.content">
  <xsl:param name="node" select="."/>
  <xsl:if test="$oasis-base='yes'">
    <xsl:for-each select="/*/articleinfo/releaseinfo
                          [starts-with(@role,'OASIS-specification-this')]
                          [contains(.,'.htm')]">
      <base href="{.}"/>
    </xsl:for-each>
  </xsl:if>
  <xsl:apply-templates select="/*/articleinfo/releaseinfo[@role='cvs']"
                       mode="head.meta.content"/>
  <xsl:call-template name="oasis.head.mathml"/>
  <xsl:call-template name="user.head.content.extension"/>
</xsl:template>

<xsl:template match="releaseinfo" mode="head.meta.content">
  <meta name="cvsinfo">
    <xsl:attribute name="content">
      <xsl:value-of select="substring-before(substring-after(.,'$'),'$')"/>
    </xsl:attribute>
  </meta>
</xsl:template>

<!-- ============================================================ -->
<!-- Titlepage -->

<xsl:template match="articleinfo/title" mode="titlepage.mode">
  <h1>
    <xsl:apply-templates/>
  </h1>
</xsl:template>

<xsl:template match="pubdate" mode="titlepage.mode">
  <h2>
    <xsl:choose>
      <xsl:when test="/*/@status">
        <xsl:call-template name="split-status">
          <xsl:with-param name="rest" select="/*/@status"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>???Unknown Status???</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </h2>

  <h2>
    <xsl:apply-templates mode="titlepage.mode"/>
  </h2>
</xsl:template>
  
<xsl:template name="split-status">
  <xsl:param name="rest"/>
  <xsl:choose>
    <xsl:when test="contains($rest,'/')">
      <xsl:value-of select="substring-before($rest,'/')"/>/<xsl:text/>
      <br/>
      <xsl:call-template name="split-status">
        <xsl:with-param name="rest">
          <xsl:value-of select="substring-after($rest,'/')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$rest"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="productname" mode="titlepage.mode">
  <!-- suppress -->
</xsl:template>

<xsl:template match="releaseinfo[@role='product']" mode="titlepage.mode" priority="2">
  <!-- suppress -->
</xsl:template>

<xsl:template match="releaseinfo[@role='product']" mode="product.mode" priority="2">
  <xsl:apply-templates mode="titlepage.mode"/>
</xsl:template>

<xsl:template match="releaseinfo[@role='committee']" mode="titlepage.mode" priority="2">
  <p>
    <span class="loc-heading">Technical Committee:</span>
    <br/>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="releaseinfo[@role='oasis-id']" mode="titlepage.mode" priority="2">
  <p>
    <span class="loc-heading">OASIS identifier:</span>
    <br/>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="releaseinfo[starts-with(@role,'OASIS-specification-')]"
              mode="titlepage.mode" priority="2">
  <xsl:if test="not(preceding-sibling::releaseinfo
                                 [starts-with(@role,'OASIS-specification-')])">
    <xsl:variable name="locations" 
                  select="../releaseinfo[starts-with(@role,
                                         'OASIS-specification-')]"/>
    <xsl:call-template name="spec-uri-group">
      <xsl:with-param name="header">This stage:</xsl:with-param>
      <xsl:with-param name="uris" 
           select="$locations[starts-with(@role,'OASIS-specification-this')]"/>
    </xsl:call-template>
    <xsl:call-template name="spec-uri-group">
      <xsl:with-param name="header">Previous stage:</xsl:with-param>
      <xsl:with-param name="uris" 
       select="$locations[starts-with(@role,'OASIS-specification-previous')]"/>
    </xsl:call-template>
    <xsl:call-template name="spec-uri-group">
      <xsl:with-param name="header">Latest stage:</xsl:with-param>
      <xsl:with-param name="uris" 
         select="$locations[starts-with(@role,'OASIS-specification-latest')]"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="spec-uri-group">
  <xsl:param name="header"/>
  <xsl:param name="uris"/>
  <p>
    <span class="loc-heading">
      <xsl:copy-of select="$header"/>
    </span>
    <br/>
    <xsl:choose>
      <xsl:when test="not($uris)">
        N/A
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$uris">
          <xsl:choose>
            <xsl:when test="contains(@role,'-draft')">
              <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
              <a href="{.}">
                <xsl:value-of select="."/>
              </a>
              <xsl:if test="contains(@role,'-authoritative')">
                (Authoritative)
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <br/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<xsl:template match="authorgroup" mode="titlepage.mode">
  <xsl:variable name="editors" select="editor"/>
  <xsl:variable name="authors" select="author"/>
  <xsl:variable name="chairs" select="othercredit[not(@role)]"/>
  <xsl:variable name="secretaries" select="othercredit[@role='secretary']"/>

  <xsl:if test="$chairs">
    <p>
      <span class="contrib-heading">
        <xsl:text>Chair</xsl:text>
        <xsl:if test="count($chairs) &gt; 1">s</xsl:if>
        <xsl:text>:</xsl:text>
      </span>
      <br/>
      <xsl:apply-templates select="$chairs" mode="titlepage.mode"/>
    </p>
  </xsl:if>

  <xsl:if test="$secretaries">
    <p>
      <span class="contrib-heading">
        <xsl:choose>
          <xsl:when test="count($secretaries) &gt; 1">Secretaries</xsl:when>
          <xsl:otherwise>Secretary</xsl:otherwise>
        </xsl:choose>
      </span>
      <br/>
      <xsl:apply-templates select="$secretaries" mode="titlepage.mode"/>
    </p>
  </xsl:if>

  <xsl:if test="$editors">
    <p>
      <span class="editor-heading">
        <xsl:text>Editor</xsl:text>
        <xsl:if test="count($editors) &gt; 1">s</xsl:if>
        <xsl:text>:</xsl:text>
      </span>
      <br/>
      <xsl:apply-templates select="$editors" mode="titlepage.mode"/>
    </p>
  </xsl:if>

  <xsl:if test="$authors">
    <p>
      <span class="author-heading">
        <xsl:text>Author</xsl:text>
        <xsl:if test="count($authors) &gt; 1">s</xsl:if>
        <xsl:text>:</xsl:text>
      </span>
      <br/>
      <xsl:apply-templates select="$authors" mode="titlepage.mode"/>
    </p>
  </xsl:if>

</xsl:template>

<xsl:template match="releaseinfo[@role='subject-keywords']" mode="titlepage.mode" priority="2">
  <p>
    <span class="loc-heading">Subject / Keywords:</span>
    <br/>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="releaseinfo[@role='topic']" mode="titlepage.mode" priority="2">
  <p>
    <span class="loc-heading">OASIS Conceptual Model Topic Area:</span>
    <br/>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template match="ulink" mode="revision-links">
  <xsl:if test="position() = 1"> (</xsl:if>
  <xsl:if test="position() &gt; 1">, </xsl:if>
  <a href="{@url}"><xsl:value-of select="@role"/></a>
  <xsl:if test="position() = last()">)</xsl:if>
</xsl:template>

<xsl:template match="editor|author|othercredit" mode="titlepage.mode">
  <xsl:call-template name="person.name"/>
  <xsl:if test="contrib">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="contrib" mode="titlepage.mode"/>
    <xsl:text>)</xsl:text>
  </xsl:if>
  <xsl:apply-templates select="email"
                       mode="titlepage.mode"/>
  <xsl:if test="affiliation/orgname">
    <xsl:text>, </xsl:text>
    <xsl:apply-templates select="affiliation/orgname" mode="titlepage.mode"/>
  </xsl:if>
  <xsl:if test="position()&lt;last()"><br/></xsl:if>
</xsl:template>

<xsl:template match="email" mode="titlepage.mode">
  <xsl:text>&separator;(</xsl:text>
  <a href="mailto:{.}">
    <xsl:apply-templates/>
  </a>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="abstract" mode="titlepage.mode">
  <p style="margin-bottom:-1em">
    <a>
      <xsl:attribute name="name">
        <xsl:call-template name="object.id"/>
      </xsl:attribute>
    </a>
    <span class="abstract-heading">
      <xsl:apply-templates select="." mode="object.title.markup"/>
      <xsl:text>:</xsl:text>
    </span>
    <br/>
  </p>
  <xsl:apply-templates mode="titlepage.mode"/>
</xsl:template>

<xsl:template match="legalnotice[title]" mode="titlepage.mode">
  <p style="margin-bottom:-1em">
    <a>
      <xsl:attribute name="name">
        <xsl:call-template name="object.id"/>
      </xsl:attribute>
    </a>
    <span class="status-heading">
      <xsl:apply-templates select="." mode="object.title.markup"/>
      <xsl:text>:</xsl:text>
    </span>
    <br/>
  </p>
  <xsl:apply-templates mode="titlepage.mode"/>
</xsl:template>

<xsl:template match="legalnotice/title" mode="titlepage.mode">
  <!-- nop -->
</xsl:template>

<xsl:template match="releaseinfo" mode="titlepage.mode">
  <xsl:comment>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
  </xsl:comment>
</xsl:template>

<xsl:template match="jobtitle|shortaffil|orgname|contrib"
              mode="titlepage.mode">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="phrase[@role='keyword']//text()">
  <xsl:value-of select="translate(.,'&lower;','&upper;')"/>
</xsl:template>

<!-- ============================================================ -->
<!-- Component TOC -->

<xsl:template name="component.toc">
  <xsl:if test="$generate.component.toc != 0">
    <xsl:variable name="nodes" select="section|sect1"/>
    <xsl:variable name="apps" select="bibliography|glossary|appendix"/>

    <xsl:if test="$nodes">
      <div class="toc">
        <h2>
          <xsl:call-template name="gentext">
            <xsl:with-param name="key">TableofContents</xsl:with-param>
          </xsl:call-template>
        </h2>

        <xsl:if test="$nodes">
          <xsl:element name="{$toc.list.type}">
            <xsl:apply-templates select="$nodes" mode="toc"/>
          </xsl:element>
        </xsl:if>

        <xsl:if test="$apps">
          <h3>Appendixes</h3>

          <xsl:element name="{$toc.list.type}">
            <xsl:apply-templates select="$apps" mode="toc"/>
          </xsl:element>
        </xsl:if>
      </div>
      <hr/>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="appendix" mode="object.title.template">
  <xsl:text>Appendix </xsl:text>
  <xsl:apply-imports/>
</xsl:template>

<!-- ================================================================= -->

<!-- support role='non-normative' -->
<xsl:template match="preface|chapter|appendix" mode="title.markup">
  <xsl:param name="allow-anchors" select="'0'"/>
  <xsl:variable name="title" select="(docinfo/title
                                      |prefaceinfo/title
                                      |chapterinfo/title
                                      |appendixinfo/title
                                      |title)[1]"/>
  <xsl:if test="@role='iso-normative'">
    <xsl:text>(normative) </xsl:text>
  </xsl:if>
  <xsl:if test="@role='iso-informative'">
    <xsl:text>(informative) </xsl:text>
  </xsl:if>
  <xsl:apply-templates select="$title" mode="title.markup">
    <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
  </xsl:apply-templates>
  <xsl:if test="@role='non-normative'">
    <xsl:text> (Non-Normative)</xsl:text>
  </xsl:if>
  <xsl:if test="@role='normative'">
    <xsl:text> (Normative)</xsl:text>
  </xsl:if>
  <xsl:if test="@role='informative'">
    <xsl:text> (Informative)</xsl:text>
  </xsl:if>
</xsl:template>

<!-- support role='non-normative' -->
<xsl:template match="section
                     |sect1|sect2|sect3|sect4|sect5
                     |refsect1|refsect2|refsect3
                     |simplesect"
              mode="title.markup">
  <xsl:param name="allow-anchors" select="'0'"/>
  <xsl:variable name="titleInPlay" select="(sectioninfo/title
                                           |sect1info/title
                                           |sect2info/title
                                           |sect3info/title
                                           |sect4info/title
                                           |sect5info/title
                                           |refsect1info/title
                                           |refsect2info/title
                                           |refsect3info/title
                                           |title)[1]"/>
  <xsl:if test="@role='iso-normative'">
    <xsl:text>(normative) </xsl:text>
  </xsl:if>
  <xsl:if test="@role='iso-informative'">
    <xsl:text>(informative) </xsl:text>
  </xsl:if>
  <xsl:apply-templates select="$titleInPlay" mode="title.markup">
    <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
  </xsl:apply-templates>
  <xsl:if test="@role='non-normative'">
    <xsl:text> (Non-Normative)</xsl:text>
  </xsl:if>
  <xsl:if test="@role='normative'">
    <xsl:text> (Normative)</xsl:text>
  </xsl:if>
  <xsl:if test="@role='informative'">
    <xsl:text> (Informative)</xsl:text>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->
<!-- Formatting changes for OASIS look&amp;feel -->

<xsl:template match="quote">
  <xsl:variable name="depth">
    <xsl:call-template name="dot.count">
      <xsl:with-param name="string">
        <xsl:number level="multiple"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$depth mod 2 = 0">
      <xsl:text>"</xsl:text>
      <xsl:call-template name="inline.charseq"/>
      <xsl:text>"</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>'</xsl:text>
      <xsl:call-template name="inline.charseq"/>
      <xsl:text>'</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="filename">
  <b>
    <xsl:apply-templates/>
  </b>
</xsl:template>

<!--the entire template has to change just to get italics and no bold-->
<xsl:template name="formal.object.heading">
  <xsl:param name="object" select="."/>
  <xsl:param name="title">
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:param>

  <p class="title">
    <i>
      <xsl:copy-of select="$title"/>
    </i>
  </p>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="para/revhistory">
  <xsl:variable name="numcols">
    <xsl:choose>
      <xsl:when test="//authorinitials">3</xsl:when>
      <xsl:otherwise>2</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="{name(.)}">
    <table border="1" width="100%" summary="Revision history">
      <xsl:apply-templates mode="titlepage.mode">
        <xsl:with-param name="numcols" select="$numcols"/>
      </xsl:apply-templates>
    </table>
  </div>
</xsl:template>

<xsl:template match="section[bibliography]/para">
  <!--suppress the paragraphs in the references, per OASIS layout-->
  <xsl:if test="normalize-space(.)">
    <xsl:message>
      <xsl:text>Warning: non-empty bibliographic paragraphs are </xsl:text>
      <xsl:text>ignored in order to meet OASIS layout requirements.</xsl:text>
    </xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template match="bibliolist">
  <xsl:apply-templates select="bibliomixed"/>
  <xsl:if test="*[not(self::bibliomixed)][normalize-space()]">
    <xsl:message>
    <xsl:text>Warning: non-empty non-bibliomixed children of </xsl:text>
    <xsl:text>bibliography elements are </xsl:text>
    <xsl:text>ignored in order to meet OASIS layout requirements.</xsl:text>
    </xsl:message>
  </xsl:if>
</xsl:template>
  
<xsl:template match="bibliomixed/abbrev">
  <b><xsl:apply-imports/></b>
</xsl:template>

<xsl:template match="title" mode="bibliomixed.mode">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="table[starts-with(@role,'font-size-')]//td/node() |
                     table[starts-with(@role,'font-size-')]//entry/node()">
  <span style="font-size:{substring-after(ancestor::table[@role][1]/@role,
                                          'font-size-')}">
    <xsl:apply-imports/>
  </span>
</xsl:template>

<xsl:template match="programlisting[starts-with(@role,'font-size-')]//text()">
  <span style="font-size:{
      substring-after(ancestor::programlisting[@role][1]/@role,'font-size-')}">
    <xsl:apply-imports/>
  </span>
</xsl:template>

<xsl:template name="user.footer.content">
  <table style="font-size:80%" width="100%">
    <tr>
      <td>
        <xsl:value-of select="/*/articleinfo/productname"/>
        <xsl:for-each select="/*/articleinfo/productnumber">
          <xsl:text/>-<xsl:value-of select="."/>
        </xsl:for-each>
        <br/>
        <xsl:value-of select="/*/articleinfo/releaseinfo[@role='track']"/>
      </td>
      <td style="text-align:center">
        <br/>
        <xsl:text>Copyright &#xa9; </xsl:text>
        <xsl:choose>
          <xsl:when test="/*/articleinfo/copyrightyear/holder">
            <xsl:for-each select="/*/articleinfo/copyrightyear/holder">
              <xsl:if test="position()>1">, </xsl:if>
              <xsl:value-of select="."/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>OASIS Open</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="/*/articleinfo/copyright/year"/>
        <xsl:text>. All rights reserved.</xsl:text>
      </td>
      <td style="text-align:right">
        <xsl:value-of select="/*/articleinfo/pubdate"/>
      </td>
    </tr>
  </table>
  
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="processing-instruction('lb')">
  <br/>
</xsl:template>

<!-- ============================================================ -->
<!--Localization-->
<!--Problems have been reported regarding NBSP characters being visible in
    Internet Explorer when dynamically creating the HTML from XML in the
    browser.  All of these localization strings originally had an NBSP
    and now use the separator defined above.  Also, punctuation has been
    modified as required.-->

<xsl:param name="local.l10n.xml" select="document('')"/>
<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
  <l:l10n language="en">
   <l:context name="title">
      <l:template name="abstract" text="%t"/>
      <l:template name="answer" text="%t"/>
      <l:template name="appendix" text="Appendix&separator;%n.&separator;%t"/>
      <l:template name="article" text="%t"/>
      <l:template name="authorblurb" text="%t"/>
      <l:template name="bibliodiv" text="%t"/>
      <l:template name="biblioentry" text="%t"/>
      <l:template name="bibliography" text="%t"/>
      <l:template name="bibliolist" text="%t"/>
      <l:template name="bibliomixed" text="%t"/>
      <l:template name="bibliomset" text="%t"/>
      <l:template name="biblioset" text="%t"/>
      <l:template name="blockquote" text="%t"/>
      <l:template name="book" text="%t"/>
      <l:template name="calloutlist" text="%t"/>
      <l:template name="caution" text="%t"/>
      <l:template name="chapter" text="Chapter&separator;%n.&separator;%t"/>
      <l:template name="colophon" text="%t"/>
      <l:template name="dedication" text="%t"/>
      <l:template name="equation" text="Equation&separator;%n.&separator;%t"/>
      <l:template name="example" text="Example&separator;%n.&separator;%t"/>
      <l:template name="figure" text="Figure&separator;%n.&separator;%t"/>
      <l:template name="foil" text="%t"/>
      <l:template name="foilgroup" text="%t"/>
      <l:template name="formalpara" text="%t"/>
      <l:template name="glossary" text="%t"/>
      <l:template name="glossdiv" text="%t"/>
      <l:template name="glosslist" text="%t"/>
      <l:template name="glossentry" text="%t"/>
      <l:template name="important" text="%t"/>
      <l:template name="index" text="%t"/>
      <l:template name="indexdiv" text="%t"/>
      <l:template name="itemizedlist" text="%t"/>
      <l:template name="legalnotice" text="%t"/>
      <l:template name="listitem" text=""/>
      <l:template name="lot" text="%t"/>
      <l:template name="msg" text="%t"/>
      <l:template name="msgexplan" text="%t"/>
      <l:template name="msgmain" text="%t"/>
      <l:template name="msgrel" text="%t"/>
      <l:template name="msgset" text="%t"/>
      <l:template name="msgsub" text="%t"/>
      <l:template name="note" text="%t"/>
      <l:template name="orderedlist" text="%t"/>
      <l:template name="part" text="Part&separator;%n.&separator;%t"/>
      <l:template name="partintro" text="%t"/>
      <l:template name="preface" text="%t"/>
      <l:template name="procedure" text="%t"/>
      <l:template name="procedure.formal" text="Procedure&separator;%n.&separator;%t"/>
      <l:template name="productionset" text="%t"/>
      <l:template name="productionset.formal" text="Production&separator;%n"/>
      <l:template name="qandadiv" text="%t"/>
      <l:template name="qandaentry" text="%t"/>
      <l:template name="qandaset" text="%t"/>
      <l:template name="question" text="%t"/>
      <l:template name="refentry" text="%t"/>
      <l:template name="reference" text="%t"/>
      <l:template name="refsection" text="%t"/>
      <l:template name="refsect1" text="%t"/>
      <l:template name="refsect2" text="%t"/>
      <l:template name="refsect3" text="%t"/>
      <l:template name="refsynopsisdiv" text="%t"/>
      <l:template name="refsynopsisdivinfo" text="%t"/>
      <l:template name="segmentedlist" text="%t"/>
      <l:template name="set" text="%t"/>
      <l:template name="setindex" text="%t"/>
      <l:template name="sidebar" text="%t"/>
      <l:template name="step" text="%t"/>
      <l:template name="table" text="Table&separator;%n.&separator;%t"/>
      <l:template name="task" text="%t"/>
      <l:template name="tip" text="%t"/>
      <l:template name="toc" text="%t"/>
      <l:template name="variablelist" text="%t"/>
      <l:template name="varlistentry" text=""/>
      <l:template name="warning" text="%t"/>
   </l:context>

    <l:context name="title-numbered">
      <l:template name="appendix" text="Appendix&separator;%n&separator;%t"/>
      <l:template name="article/appendix" text="%n&separator;%t"/>
      <l:template name="bridgehead" text="%n&separator;%t"/>
      <l:template name="chapter" text="Chapter&separator;%n&separator;%t"/>
      <l:template name="sect1" text="%n&separator;%t"/>
      <l:template name="sect2" text="%n&separator;%t"/>
      <l:template name="sect3" text="%n&separator;%t"/>
      <l:template name="sect4" text="%n&separator;%t"/>
      <l:template name="sect5" text="%n&separator;%t"/>
      <l:template name="section" text="%n&separator;%t"/>
      <l:template name="simplesect" text="%t"/>
      <l:template name="part" text="Part&separator;%n&separator;%t"/>
    </l:context>
    
   <l:context name="xref">
      <l:template name="abstract" text="%t"/>
      <l:template name="answer" text="A:&separator;%n"/>
      <l:template name="appendix" text="%t"/>
      <l:template name="article" text="%t"/>
      <l:template name="authorblurb" text="%t"/>
      <l:template name="bibliodiv" text="%t"/>
      <l:template name="bibliography" text="%t"/>
      <l:template name="bibliomset" text="%t"/>
      <l:template name="biblioset" text="%t"/>
      <l:template name="blockquote" text="%t"/>
      <l:template name="book" text="%t"/>
      <l:template name="calloutlist" text="%t"/>
      <l:template name="caution" text="%t"/>
      <l:template name="chapter" text="%t"/>
      <l:template name="colophon" text="%t"/>
      <l:template name="constraintdef" text="%t"/>
      <l:template name="dedication" text="%t"/>
      <l:template name="equation" text="%t"/>
      <l:template name="example" text="%t"/>
      <l:template name="figure" text="%t"/>
      <l:template name="foil" text="%t"/>
      <l:template name="foilgroup" text="%t"/>
      <l:template name="formalpara" text="%t"/>
      <l:template name="glossary" text="%t"/>
      <l:template name="glossdiv" text="%t"/>
      <l:template name="important" text="%t"/>
      <l:template name="index" text="%t"/>
      <l:template name="indexdiv" text="%t"/>
      <l:template name="itemizedlist" text="%t"/>
      <l:template name="legalnotice" text="%t"/>
      <l:template name="listitem" text="%n"/>
      <l:template name="lot" text="%t"/>
      <l:template name="msg" text="%t"/>
      <l:template name="msgexplan" text="%t"/>
      <l:template name="msgmain" text="%t"/>
      <l:template name="msgrel" text="%t"/>
      <l:template name="msgset" text="%t"/>
      <l:template name="msgsub" text="%t"/>
      <l:template name="note" text="%t"/>
      <l:template name="orderedlist" text="%t"/>
      <l:template name="part" text="%t"/>
      <l:template name="partintro" text="%t"/>
      <l:template name="preface" text="%t"/>
      <l:template name="procedure" text="%t"/>
      <l:template name="productionset" text="%t"/>
      <l:template name="qandadiv" text="%t"/>
      <l:template name="qandaentry" text="Q:&separator;%n"/>
      <l:template name="qandaset" text="%t"/>
      <l:template name="question" text="Q:&separator;%n"/>
      <l:template name="reference" text="%t"/>
      <l:template name="refsynopsisdiv" text="%t"/>
      <l:template name="segmentedlist" text="%t"/>
      <l:template name="set" text="%t"/>
      <l:template name="setindex" text="%t"/>
      <l:template name="sidebar" text="%t"/>
      <l:template name="table" text="%t"/>
      <l:template name="tip" text="%t"/>
      <l:template name="toc" text="%t"/>
      <l:template name="variablelist" text="%t"/>
      <l:template name="varlistentry" text="%n"/>
      <l:template name="warning" text="%t"/>
      <l:template name="olink.document.citation" text=" in %o"/>
      <l:template name="olink.page.citation" text=" (page %p)"/>
      <l:template name="page.citation" text=" [%p]"/>
      <l:template name="page" text="(page %p)"/>
      <l:template name="docname" text=" in %o"/>
      <l:template name="docnamelong" text=" in the document titled %o"/>
      <l:template name="pageabbrev" text="(p. %p)"/>
      <l:template name="Page" text="Page %p"/>
      <l:template name="bridgehead" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsection" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsect1" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsect2" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsect3" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect1" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect2" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect3" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect4" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect5" text="the section called &#8220;%t&#8221;"/>
      <l:template name="section" text="the section called &#8220;%t&#8221;"/>
      <l:template name="simplesect" text="the section called &#8220;%t&#8221;"/>
   </l:context>

   <l:context name="xref-number">
      <l:template name="answer" text="A:&separator;%n"/>
      <l:template name="appendix" text="Appendix&separator;%n"/>
      <l:template name="bridgehead" text="Section&separator;%n"/>
      <l:template name="chapter" text="Chapter&separator;%n"/>
      <l:template name="equation" text="Equation&separator;%n"/>
      <l:template name="example" text="Example&separator;%n"/>
      <l:template name="figure" text="Figure&separator;%n"/>
      <l:template name="part" text="Part&separator;%n"/>
      <l:template name="procedure" text="Procedure&separator;%n"/>
      <l:template name="productionset" text="Production&separator;%n"/>
      <l:template name="qandadiv" text="Q &amp; A&separator;%n"/>
      <l:template name="qandaentry" text="Q:&separator;%n"/>
      <l:template name="question" text="Q:&separator;%n"/>
      <l:template name="sect1" text="Section&separator;%n"/>
      <l:template name="sect2" text="Section&separator;%n"/>
      <l:template name="sect3" text="Section&separator;%n"/>
      <l:template name="sect4" text="Section&separator;%n"/>
      <l:template name="sect5" text="Section&separator;%n"/>
      <l:template name="section" text="Section&separator;%n"/>
      <l:template name="table" text="Table&separator;%n"/>
   </l:context>

   <l:context name="xref-number-and-title">
      <l:template name="appendix" text="Appendix&separator;%n, %t"/>
      <l:template name="bridgehead" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="chapter" text="Chapter&separator;%n, %t"/>
      <l:template name="equation" text="Equation&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="example" text="Example&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="figure" text="Figure&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="part" text="Part&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="procedure" text="Procedure&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="productionset" text="Production&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="qandadiv" text="Q &amp; A&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="refsect1" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsect2" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsect3" text="the section called &#8220;%t&#8221;"/>
      <l:template name="refsection" text="the section called &#8220;%t&#8221;"/>
      <l:template name="sect1" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="sect2" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="sect3" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="sect4" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="sect5" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="section" text="Section&separator;%n, &#8220;%t&#8221;"/>
      <l:template name="simplesect" text="the section called &#8220;%t&#8221;"/>
      <l:template name="table" text="Table&separator;%n, &#8220;%t&#8221;"/>
   </l:context>

  </l:l10n>
</l:i18n>
<xsl:param name="autotoc.label.separator" select="'&separator;'"/>

</xsl:stylesheet>

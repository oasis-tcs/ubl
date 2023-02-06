<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:u="urn:X-UBL"
  exclude-result-prefixes="xs u"
  version="2.0">

<xsl:output indent="yes" omit-xml-declaration="yes"/>

<xsl:param name="UBLversion" as="xs:string" required="yes"/>
  
<xsl:param name="gc-uri" as="xs:string" required="yes"/>

<xsl:template match="/">
 <xsl:result-document href="UBL-{$UBLversion}-catalog.xml">
   <xsl:message select="'Creating XML catalogue file'"/>
  <xsl:comment>
This UBL <xsl:value-of select="$UBLversion"/> catalogue conforms to XML Catalogs 1.1
https://www.oasis-open.org/committees/download.php/14809/xml-catalogs.html

Note that "system" entries are created only for those namespaces that are
user facing, and not for those namespaces that are used internally only by
the schema expressions.
</xsl:comment>
   <xsl:text>&#xa;</xsl:text>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
  <xsl:text>&#xa;</xsl:text>
  <xsl:text>&#xa;</xsl:text>
	<system
		systemId="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
		uri="common/UBL-CommonAggregateComponents-{$UBLversion}.xsd" />
  <system
		systemId="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
		uri="common/UBL-CommonBasicComponents-{$UBLversion}.xsd" />
  <system
		systemId="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
		uri="common/UBL-CommonExtensionComponents-{$UBLversion}.xsd" />
  <xsl:text>&#xa;</xsl:text>
  <xsl:text>&#xa;</xsl:text>
  <xsl:for-each select="/schemadocs/schema">
    <xsl:sort select="name"/>
    <xsl:variable name="compact" select="translate(name,' ','')"/>
    <system
    	systemId="urn:oasis:names:specification:ubl:schema:xsd:{$compact}-2"
    	uri="maindoc/UBL-{$compact}-{$UBLversion}.xsd" />
  </xsl:for-each>
  <xsl:text>&#xa;</xsl:text>
  <xsl:text>&#xa;</xsl:text>
</catalog>   
 </xsl:result-document>
 <xsl:result-document href="summary-namespaces-ent.xml">
   <xsl:message select="'Creating entity with namespace summary'"/>
  <xsl:comment>
To get an updated version of this entity file, please run the build process
and obtain a copy from the archive-only-not-in-final-distribution/new-entities
directory.


</xsl:comment><xsl:text>&#xa;</xsl:text>
  <xsl:comment select="'a total of',count(/*/schema),'document types'"/>
  <xsl:text>&#xa;</xsl:text>
   
  <legalnotice role="namespaces">
   <title>Declared XML Namespaces</title>
   <para> 
    <simplelist lang="none">
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2 </member>
      <member>
        urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2
      </member>
    </simplelist>
   </para>
    
   <para>
    <simplelist lang="none">
      <xsl:for-each select="/schemadocs/schema">
        <xsl:sort select="name"/>
        <member>urn:oasis:names:specification:ubl:schema:xsd:<xsl:value-of
                  select="translate(normalize-space(name),' ','')"/>-2</member>
      </xsl:for-each>
    </simplelist>
   </para>
  </legalnotice>
 </xsl:result-document>
 <xsl:result-document href="summary-schemas-ent.xml">
   <xsl:message select="'Creating entity with schema summaries'"/>
   <xsl:comment>
To get an updated version of this entity file, please run the build process
and obtain a copy from the archive-only-not-in-final-distribution/new-entities
directory.
</xsl:comment><xsl:text>&#xa;</xsl:text>
  <xsl:for-each select="/schemadocs/schema">
    <xsl:sort select="name"/>
    <xsl:variable name="normname" select="normalize-space(name)"/>
    <xsl:variable name="compname" select="translate($normname,' ','')"/>
    <section id="S-{translate(upper-case($normname),' ,()','-')}-SCHEMA">
      <title><xsl:value-of select="$normname"/> Schema</title>
      <para>
        <xsl:text>Description: </xsl:text>
        <xsl:value-of select="
       u:col(key('rows',concat(name,'. Details'),doc($gc-uri)),'Definition')"/>
        <xsl:apply-templates select="description/node()"/>
      </para>
      <informaltable>
        <tgroup cols="2">
          <colspec colwidth="30*"/>
          <colspec colwidth="70*"/>
          <tbody>
            <row>
              <entry><para>Processes involved</para></entry>
              <entry>
                <para>
                  <xsl:choose>
                    <xsl:when test="not(processes/process)">
                      <xsl:text>Any collaboration</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="processes/process">
                        <xsl:if test="position()>1">, </xsl:if>
                      <link linkend="S-{translate(upper-case(.),' ,()','-')}">
                        <xsl:value-of select="."/>
                      </link>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </para>
              </entry>
            </row>
            <row>
              <entry><para>Submitter role</para></entry>
              <entry>
                <para>
                  <xsl:value-of select="submitterRole"/>
                </para>
              </entry>
            </row>
            <row>
              <entry><para>Receiver role</para></entry>
              <entry>
                <para>
                  <xsl:value-of select="receiverRole"/>
                </para>
              </entry>
            </row>
            <row>
              <entry><para>Normative schema</para></entry>
              <entry>
                <para>
                  <literal>
                    <ulink url="xsd/maindoc/UBL-{$compname}-{$UBLversion}.xsd"
                            >xsd/maindoc/UBL-<xsl:value-of select="$compname"
                            />-<xsl:value-of select="$UBLversion"/>.xsd</ulink>
                  </literal>
                </para>
              </entry>
            </row>
            <row>
              <entry><para>Runtime schema</para></entry>
              <entry>
                <para>
                  <literal>
                   <ulink url="xsdrt/maindoc/UBL-{$compname}-{$UBLversion}.xsd"
                            >xsdrt/maindoc/UBL-<xsl:value-of select="$compname"
                            />-<xsl:value-of select="$UBLversion"/>.xsd</ulink>
                  </literal>
                </para>
              </entry>
            </row>
            <row>
              <entry><para>Summary report</para></entry>
              <entry>
                <para>
                  <literal>
            <ulink url="mod/summary/reports/UBL-{$compname}-{$UBLversion}.html"
                      >mod/summary/reports/UBL-<xsl:value-of select="$compname"
                      />-<xsl:value-of select="$UBLversion"/>.html</ulink>
                  </literal>
                </para>
              </entry>
            </row>
            <xsl:for-each select="examples/example">
              <xsl:if test="
     not(matches(.,concat('UBL-',$compname,'-2\.\d-Example((-\d)|.*)?.xml')))">
                <xsl:message terminate="yes" select="'Bad: ',.,'&#xa;Expecting:',
                  concat('UBL-',$compname,'-2\.\d-Example((-\d)|.*)?.xml')"/>
              </xsl:if>
              <row>
                <entry><para>UBL <xsl:value-of select="normalize-space(
                  replace(.,'.+?-2.(.)-Example(-(\d)?.*)?.xml',
                            ' 2.$1 example instance $3'))"/></para></entry>
                <entry role="schemaExample">
                  <para>
                    <literal>
                      <ulink url="xml/{.}"
                                        >xml/<xsl:value-of select="."/></ulink>
                    </literal>
                  </para>
                </entry>
              </row>
            </xsl:for-each>
          </tbody>
        </tgroup>
      </informaltable>
    </section>
  </xsl:for-each>
 </xsl:result-document>
 <xsl:result-document href="summary-examples-ent.xml">
   <xsl:message select="'Creating entity with example list'"/>
  <xsl:comment>
To get an updated version of this entity file, please run the build process
and obtain a copy from the archive-only-not-in-final-distribution/new-entities
directory.
</xsl:comment><xsl:text>&#xa;</xsl:text>
  <blockquote role="summaryExamples">
    <simplelist>
      <xsl:for-each select="//example">
        <xsl:sort select="." lang="en"/>
        <member>
          <literal>
            <ulink url="xml/{.}">xml/<xsl:value-of select="."/></ulink>
          </literal>
        </member>
      </xsl:for-each>
    </simplelist>
  </blockquote>
 </xsl:result-document>
</xsl:template>

<xsl:template match="link[@schema]">
  <link 
     linkend="S-{translate(upper-case(normalize-space(.)),' ,()','-')}-SCHEMA">
    <xsl:value-of select="normalize-space(.)"/>
  </link>
</xsl:template>

<xsl:template match="link">
  <link linkend="S-{translate(upper-case(normalize-space(.)),' ,()','-')}">
    <xsl:value-of select="normalize-space(.)"/>
  </link>
</xsl:template>

<xsl:template match="link[@figure]">
  <link linkend="F-{translate(upper-case(normalize-space(.)),' ,()','-')}">
    <xsl:value-of select="normalize-space(.)"/>
  </link>
</xsl:template>

<xsl:template match="*">
  <xsl:message terminate="yes" select="'Not handled:',name(.)"/>
</xsl:template>

<xsl:key name="rows" match="Row" use="u:col(.,'DictionaryEntryName')"/>

<xsl:function name="u:col" as="element(SimpleValue)?">
  <xsl:param name="row" as="element(Row)"/>
  <xsl:param name="col" as="xs:string+"/>
  <xsl:sequence select="$row/Value[@ColumnRef=$col]/SimpleValue"/>
</xsl:function>

</xsl:stylesheet>
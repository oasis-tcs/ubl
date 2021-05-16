<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslstyle/xslstyle-docbook.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.CraneSoftwrights.com/ns/xslstyle"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gu="urn:X-gc2obdndr"
                xmlns:dt="urn:X-Crane-gc2obdndr"
                exclude-result-prefixes="xs gu xsd dt"
                version="2.0">

<xs:doc info="$Id: Crane-gc2obdndr.xsl,v 1.66 2020/04/13 18:40:15 admin Exp $"
        filename="Crane-gc2obdndr.xsl" vocabulary="DocBook" internal-ns="gu">
  <xs:title>Translating genericode to OASIS BUsiness Document NDR XSD
    schemas</xs:title> 
  <note>
    <title>Documentation note:</title>
  <para>
    This documentation is only for the stylesheet creating validation artefacts
    from genericode files.
    Please see the paper <ulink url="CreatingSchemasWithUBLNDR.html"
      ><literal>CreatingSchemasWithUBLNDR.html</literal></ulink> for
    more details on the process as a whole.
  </para>
  </note>
  <para> 
    This stylesheet reads as input a <emphasis>checked</emphasis> 
    OASIS genericode expression of the serialization of OASIS Business
    Document NDR spreadsheets (see <xref linkend="ingc"/>) and a
    configuration file (see <xref linkend="invoke"/>). The output is the
    following set of W3C XML Schema XSD files and a single OASIS CVA file:
  </para>
  <itemizedlist>
    <listitem>
      a common library aggregate schema for all common library ABIEs
    </listitem>
    <listitem>
      a common library basic schema for all common library BBIEs
    </listitem>
    <listitem>
      a document schema for each document ABIE
    </listitem>
    <listitem>
      OASIS Context/Value Association files as needed for all code
      list qualifications
    </listitem>
  </itemizedlist>
  <para>
    This stylesheet also creates JSON schema artefacts:
  </para>
  <itemizedlist>
    <listitem>
      a common library aggregate schema for all common library ABIEs
    </listitem>
    <listitem>
      a common library basic schema for all common library BBIEs
    </listitem>
    <listitem>
      a document schema for each document ABIE
    </listitem>
  </itemizedlist>
  <note>
    <title>Important prerequisite</title>
      <para>
        The required checking is done by the <ulink
          url="readme-Crane-checkgc4obdndr.html"
            ><literal>Crane-checkgc4obdndr</literal></ulink> stylesheet before
        running this schema generator. This schema generator does not make all
        of the checks that the checker does, thus without checking, this
        generator may produce nonsensical results.
      </para>
  </note>
  <para>
    Additionally, this stylesheet can be invoked in order to create the
    necessary artefacts for either an extension for use under the 
    extension point, or as an additional document that shares the use of
    the common library.  In these cases the output is the following set
    of W3C XML Schema XSD files and OASIS CVA file:
  </para>
  <itemizedlist>
    <listitem>
      an extension aggregate schema for all extension ABIEs
    </listitem>
    <listitem>
      an extension basic schema for all extension BBIEs
    </listitem>
    <listitem>
      an extension point schema or a document schema for each document ABIE
    </listitem>
    <listitem>
      OASIS Context/Value Association files as needed for all code
      list qualifications in the extension or document
    </listitem>
  </itemizedlist>
  <para>
    The same is true for JSON schema artefacts:
  </para>
  <itemizedlist>
    <listitem>
      an extension aggregate schema for all extension ABIEs
    </listitem>
    <listitem>
      an extension basic schema for all extension BBIEs
    </listitem>
    <listitem>
      an extension point schema or a document schema for each document ABIE
    </listitem>
  </itemizedlist>
  <para>
    All input arguments that are relative URI strings are resolved relative
    to the stylesheet input file (which is not, necessarily, in the stylesheet
    directory or the invocation directory).
  </para>
  <para>
    All output files are emitted relative to the base URI of the
    <emphasis>invoked</emphasis> output file (which, itself, is never 
    actually written to).  Therefore, supply a bogus filename in a bona fide
    output directory in order to specify where the output artefacts are 
    created.
  </para>
  <para>
    For example, the two invocations for the Saxon-HE 
<ulink url="http://saxon.sf.net"><literal>http://saxon.sf.net</literal></ulink>
    processor would be along the lines of the following in order to generate
    a set of directories under the current directory,
    first for the base set of artefacts and second for the signature
    extension artefacts (as is created when invoking
    <literal>createUBL.sh</literal> or <literal>createUBL.bat</literal>):
  </para>
  <blockquote>
    <programlisting
>java -jar ../saxon9he/saxon9he.jar -s:mod/UBL-Signature-Entities-2.1.gc
     -xsl:../Crane-gc2ublndr.xsl -o:junk.out
     config-uri=../config-ubl-2.1-ext.xml
     base-uri=UBL-Entities-2.1.gc
     base-config-uri=../config-ubl-2.1.xml 
     common-library-singleton-model-name=UBL-SignatureLibrary-2.1

java -jar ../saxon9he/saxon9he.jar -s:mod/UBL-Entities-2.1.gc
     -xsl:../Crane-gc2ublndr.xsl -o:junk.out
     config-uri=../config-ubl-2.1.xml 
</programlisting>
  </blockquote>
  <para>
    ... where the <literal>junk.out</literal> file is never actually created
    as it is used only to indicate the directory in which the output belongs.
  </para>
  <para>
    The two invocations would be along the lines of the following in order to
    generate customized construct artefacts, first for an extension for under
    the extension point, and the second for additional documents sharing
    the common library:
  </para>
  <blockquote>
    <programlisting
>java -jar ../saxon9he.jar -s:mod/MyTimesheetExtension-Entities.gc
     -xsl:../Crane-gc2obdndr.xsl -o:junk.out
     config-uri=../config-myext.xml
     base-uri=UBL-Entities-2.1.gc
     base-config-uri=../config-ubl-2.1.xml

java -jar ../saxon9he/saxon9he.jar -s:mod/MyRARequestResponse-Entities.gc
     -xsl:../Crane-gc2obdndr.xsl -o:junk.out
     config-uri=../config-rar.xml 
     base-uri=UBL-Entities-2.1.gc 
     base-config-uri=../config-ubl-2.1.xml
</programlisting>
  </blockquote>
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

<xsl:include href="support/Crane-commonndr.xsl"/>
<xsl:include href="support/ndrSubset.xsl"/>
<xsl:include href="support/Crane-commonjson.xsl"/>

<!--========================================================================-->
<xs:doc>
  <xs:title>Global properties</xs:title>
</xs:doc>

<xs:param ignore-ns="yes">
  <para>
    Indicate that UBL 2.1 generation applies forcing no qualified data types.
  </para>
</xs:param>
<xsl:param name="qdt-for-UBL-2.1-only" as="xsd:string" select="'no'"/>

<xs:variable ignore-ns="yes">
  <para>
    Indicate that UBL 2.1 generation applies forcing no qualified data types.
  </para>
</xs:variable>
<xsl:variable name="gu:qdt4UBL2.1Only" as="xsd:boolean"
              select="starts-with('yes',lower-case($qdt-for-UBL-2.1-only))"/>

<xs:param ignore-ns="yes">
  <para>
    Indicate that generation of the QDT file is to be skipped because it is
    otherwise supplied.
  </para>
</xs:param>
<xsl:param name="skip-qdt" as="xsd:string" select="'no'"/>

<xs:variable ignore-ns="yes">
  <para>
    Indicate that generation of the QDT file is to be skipped because it is
    otherwise supplied.
  </para>
</xs:variable>
<xsl:variable name="gu:skipQDT" as="xsd:boolean"
              select="starts-with('yes',lower-case($skip-qdt))"/>

<xs:param ignore-ns="yes">
  <para>
    Indicate that extensions are to be added to all ABIEs
  </para>
</xs:param>
<xsl:param name="extensions-for-abies" as="xsd:string" select="'no'"/>

<xs:variable ignore-ns="yes">
  <para>
    Indicate that extensions are to be added to all ABIEs
  </para>
</xs:variable>
<xsl:variable name="gu:extensions4abies" as="xsd:boolean"
              select="starts-with('yes',lower-case($extensions-for-abies))"/>

<xs:output>
  <para>Indent the output assuming humans will be reading this.</para>
</xs:output>
<xsl:output indent="yes"/>
  
<!--========================================================================-->
<xs:doc>
  <xs:title>Overall stylesheet flow</xs:title>
</xs:doc>

<xs:template>
  <para>
    In the absence of a schema for the configuration file, first check
    simple assumptions regarding the configuration file.
  </para>
  <para>
    Then each of the individual document ABIE files are created, then the 
    common library ABIE files, then the CVA file.
  </para>
</xs:template>
<xsl:template match="/">
  <!--check assumptions regarding the configuration file-->
  <xsl:variable name="gu:messages">
    <xsl:choose>
      <xsl:when test="not($gu:configMain)">
        <xsl:text>Cannot open specified configuration file "</xsl:text> 
        <xsl:value-of select="$config-uri"/>
        <xsl:text>" resolved relative to the input genericode file: </xsl:text>
        <xsl:value-of select="document-uri(/)"/>
      </xsl:when>
      <xsl:when test="$base-config-uri and not($gu:configOther)">
        <xsl:text>Cannot open specified base configuration file "</xsl:text> 
        <xsl:value-of select="$base-config-uri"/>
        <xsl:text>" resolved relative to the input genericode file: </xsl:text>
        <xsl:value-of select="document-uri(/)"/>
      </xsl:when>
      <xsl:when test="($gu:outputFiles[@type=('XABIE','AABIE')]) and
                      not($gu:gcOther)">
        <xsl:text>Cannot open specified base genericode file "</xsl:text> 
        <xsl:value-of select="$base-gc-uri"/>
        <xsl:text>" resolved relative to the input genericode file: </xsl:text>
        <xsl:value-of select="document-uri(/)"/>
      </xsl:when>
      <xsl:otherwise>
        <!--validate the contents of the configuration file-->
        <xsl:call-template name="gu:validateInputs"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="normalize-space($gu:messages)">
    <xsl:message terminate="yes" select="$gu:messages"/>
  </xsl:if>
  <!--note that files in the "other" configuration file are not created-->
  <xsl:variable name="gu:makeConfig" select="$gu:config/*/configuration[1]"/>
  <!--the CVA files are processed first in case of problem finding skeleton -->
  <xsl:apply-templates select="key('gu:files','CVA',$gu:makeConfig)"/>
  <!--first assume no runtime output, then request runtime output if needed,
      for each of the files that generate XSD schemas-->
  <xsl:for-each select="false(),
                 if( $gu:makeConfig//dir[@runtime-name] ) then true() else ()">
    <!--determine if working with an extension/addition or not-->
    <xsl:choose>
      <xsl:when test="$gu:outputFiles[@type='XABIE']">
        <!--yes, working with an extension, so need to find which
            one and process those components related to that one-->
        <xsl:apply-templates select="key('gu:files','XABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'XABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','SABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'SABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','SBBIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'SBBIE'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$gu:outputFiles[@type='AABIE']">
        <!--yes, working with additions, so need to find which
            one and process those components related to that one-->
        <xsl:apply-templates select="key('gu:files','AABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'AABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','SABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'SABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','SBBIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'SBBIE'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!--no, working with the base set of business objects-->
        <xsl:apply-templates select="key('gu:files','DABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'DABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','CABIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'CABIE'"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="key('gu:files','CBBIE',$gu:makeConfig)">
          <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
          <xsl:with-param name="gu:schemaType" tunnel="yes" select="'CBBIE'"/>
        </xsl:apply-templates>
        <xsl:if test="not($gu:skipQDT)">
          <xsl:apply-templates select="key('gu:files','QDT',$gu:makeConfig)">
            <xsl:with-param name="gu:runtime" tunnel="yes" select="."/>
            <xsl:with-param name="gu:schemaType" tunnel="yes" select="'QDT'"/>
          </xsl:apply-templates>
          </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>
  
<xs:template>
  <para>
    A single XSD file is being created
  </para>
  <xs:param name="gu:runtime">
    <para>
      An indication if the file being created is for a runtime directory
      as compared to a directory of fully-documented constructs.
    </para>
  </xs:param>
</xs:template>
<xsl:template match="configuration//file">
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:variable name="gu:modulePathAndFilename" 
        select="gu:relativeConfigURI( ., ancestor::schema, $gu:runtime )"/>
  <xsl:if test="not(@syntax='JSON' and $gu:runtime)">
    <xsl:message select="'Creating',$gu:modulePathAndFilename,'...'"/>
  </xsl:if>
  <xsl:variable name="gu:moduleABIEsAndASBIEs"
          select="if( @type=('DABIE','XABIE','AABIE') )
                  then if( @abie )
          then $gu:subsetDocumentABIEs[gu:col(.,$gu:names)=current()/@abie]
          else $gu:subsetDocumentABIEs[1]
                  else (:'CABIE','SABIE','CBBIE','SBBIE':)
                       ( ( $gu:subsetDocumentABIEs/
                   key('gu:asbie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                          [gu:isSubsetBIE(.)]/(.,
            key('gu:abie-by-class',gu:col(.,'AssociatedObjectClass'),$gu:gc)),
                         $gu:subsetLibraryABIEs,
                         $gu:subsetLibraryABIEs/
                   key('gu:asbie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                          [gu:isSubsetBIE(.)]/(.,
          key('gu:abie-by-class',gu:col(.,'AssociatedObjectClass'),$gu:gc) ) )
                         except $gu:subsetDocumentABIEs )"/>
  <xsl:variable name="gu:moduleBBIEs"
                select="($gu:subsetDocumentABIEs,$gu:moduleABIEsAndASBIEs)/
                     key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                           [gu:col(.,'ComponentType')='BBIE']
                           [gu:isSubsetBIE(.)]"/>
  <!--refine the BIEs when doing the QDTs-->
  <xsl:variable name="gu:moduleABIEsAndASBIEs"
             select="if( @type='QDT' ) then () else $gu:moduleABIEsAndASBIEs"/>
  <xsl:variable name="gu:moduleBBIEs"
                select="if( @type='QDT' ) 
                        then $gu:moduleBBIEs[gu:col(.,'DataTypeQualifier')]
                        else $gu:moduleBBIEs"/>
  <xsl:if test="@abie and not( $gu:moduleABIEsAndASBIEs )">
    <xsl:message terminate="yes">
      <xsl:text>Cannot find requested ABIE in the set of document </xsl:text>
      <xsl:text>ABIES: </xsl:text>
      <xsl:value-of select="@abie"/>
    </xsl:message>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@syntax='JSON'">
      <!--
        FRG21 Document ABIE JSON schema fragments
        There shall be one JSON schema fragment created for each Document
        ABIE.
        
        FRG25 Library ABIE schema fragment
        There shall be one common schema fragment created to contain all
        ASBIEs (that is, from every Document ABIE and every Library ABIE)
        and all Library ABIEs.
        
        FRG28 BBIE schema fragment
        There shall be one common schema fragment created to describe all
        BBIEs in the model (that is, from every Document ABIE and every
        Library ABIE).
      -->
      <xsl:if test="not($gu:runtime)">
        <xsl:result-document href="{$gu:modulePathAndFilename}" method="text">
          <xsl:call-template name="gu:JSONschemaWrite">
            <xsl:with-param name="gu:modulePathAndFilename" 
                            select="$gu:modulePathAndFilename"/>
            <xsl:with-param name="gu:moduleABIEsAndASBIEs" tunnel="yes"
                            select="$gu:moduleABIEsAndASBIEs"/>
            <xsl:with-param name="gu:moduleBBIEs" tunnel="yes"
                         select="$gu:moduleBBIEs"/>
            <xsl:with-param name="gu:namespace" select="(@namespace,'')[1]"/>
          </xsl:call-template>
        </xsl:result-document>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <!--
        FRG01 Document ABIE schema fragments
        There shall be one schema fragment created for each Document ABIE.
        
        FRG04 Library ABIE schema fragment
        There shall be one common schema fragment created to contain all
        ASBIEs (that is, from every Document ABIE and every Library ABIE)
        and all Library ABIEs.
        
        FRG07 BBIE schema fragment
        There shall be one common schema fragment created to describe all
        BBIEs in the model (that is, from every Document ABIE and every 
        Library ABIE).
      -->
      <xsl:result-document href="{$gu:modulePathAndFilename}">
        <xsl:call-template name="gu:XMLschemaWrite">
          <xsl:with-param name="gu:modulePathAndFilename" 
                          select="$gu:modulePathAndFilename"/>
          <xsl:with-param name="gu:moduleABIEsAndASBIEs" tunnel="yes"
                          select="$gu:moduleABIEsAndASBIEs"/>
          <xsl:with-param name="gu:moduleBBIEs" tunnel="yes"
                       select="$gu:moduleBBIEs"/>
          <xsl:with-param name="gu:namespace" select="(@namespace,'')[1]"/>
        </xsl:call-template>
      </xsl:result-document>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:template>
  <para>
    A number of files are being created, but not including those that are
    created individually.
  </para>
  <xs:param name="gu:runtime">
    <para>
      An indication if the file being created is for a runtime directory
      as compared to a directory of fully-documented constructs.
    </para>
  </xs:param>
</xs:template>
<xsl:template match="configuration//files">
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:variable name="gu:thisFiles" select="."/>
  <!--determine which names are already being written individually-->
  <xsl:variable name="gu:singleDocumentNames" as="xsd:string*"
                select="key('gu:files',@type,$gu:config)/@abie"/>
<!--
    FRG01 Document ABIE schema fragments
    There shall be one schema fragment created for each Document ABIE.
-->  
  <!--write out all those models not included in the names already written-->
  <xsl:for-each select=
      "$gu:allDocumentABIEs[not(gu:col(.,$gu:names)=$gu:singleDocumentNames)]">
    <xsl:variable name="gu:thisDocumentABIE" select="."/>
    <!--reposition to the node in the configuration tree-->
    <xsl:for-each select="$gu:thisFiles">
      <xsl:variable name="gu:modulePathAndFilename" 
          select="gu:substituteFields($gu:thisDocumentABIE/gu:col(.,$gu:names),
                ( gu:relativeConfigURI( ., ancestor::schema, $gu:runtime) ))"/>
      <xsl:if test="gu:isSubsetABIE( $gu:thisDocumentABIE ) and
                    not(@syntax='JSON' and $gu:runtime)">
        <xsl:message select="'Creating',$gu:modulePathAndFilename,'...'"/>
        <xsl:choose>
          <xsl:when test="@syntax='JSON'">
            <xsl:result-document href="{$gu:modulePathAndFilename}"
                                 method="text">
              <xsl:call-template name="gu:JSONschemaWrite">
                <xsl:with-param name="gu:modulePathAndFilename"
                                select="$gu:modulePathAndFilename"/>
                <xsl:with-param name="gu:moduleABIEsAndASBIEs" tunnel="yes" 
                      select="$gu:thisDocumentABIE"/>
                <xsl:with-param name="gu:moduleBBIEs" tunnel="yes"
                      select="$gu:thisDocumentABIE/
                   key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                                          [gu:col(.,'ComponentType')='BBIE']
                                          [gu:isSubsetBIE(.)]"/>
                <xsl:with-param name="gu:namespace" select="
                gu:substituteFields($gu:thisDocumentABIE/gu:col(.,$gu:names),
                                    (@namespace,'')[1])"/>
                <xsl:with-param name="gu:schemaType" tunnel="yes"
                                select="@type"/>
             </xsl:call-template>
           </xsl:result-document>
          </xsl:when>
          <xsl:otherwise>
            <xsl:result-document href="{$gu:modulePathAndFilename}">
              <xsl:call-template name="gu:XMLschemaWrite">
                <xsl:with-param name="gu:modulePathAndFilename"
                                select="$gu:modulePathAndFilename"/>
                <xsl:with-param name="gu:moduleABIEsAndASBIEs" tunnel="yes" 
                      select="$gu:thisDocumentABIE"/>
                <xsl:with-param name="gu:moduleBBIEs" tunnel="yes"
                      select="$gu:thisDocumentABIE/
                     key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                                            [gu:col(.,'ComponentType')='BBIE']
                                            [gu:isSubsetBIE(.)]"/>
                <xsl:with-param name="gu:namespace" select="
                  gu:substituteFields($gu:thisDocumentABIE/gu:col(.,$gu:names),
                                      (@namespace,'')[1])"/>
             <xsl:with-param name="gu:schemaType" tunnel="yes" select="@type"/>
             </xsl:call-template>
           </xsl:result-document>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xs:template>
  <para>
    Write out the OASIS Context/Value Association (CVA) file reflecting
    model information.
  </para>
  <para>
    It is assumed that this artefact does not live in any runtime directory
    and thus is not looking for any <literal>runtime-name=</literal> 
    attributes in the configuration file.
  </para>
</xs:template>
<xsl:template match="configuration//file[@type='CVA']" priority="1">
  <xsl:variable name="gu:skeleton" select="document(@skeleton-uri)"/>
  <xsl:variable name="gu:module" 
                select="gu:relativeConfigURI( ., ancestor::schema, false() )"/>
  <xsl:message select="'Creating',$gu:module,'...'"/>
  <xsl:result-document href="{$gu:module}">
    <xsl:apply-templates mode="gu:CVAWrite" select="$gu:skeleton"/>
  </xsl:result-document>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>JSON Schema generator</xs:title>
</xs:doc>
  
<xs:template>
  <para>
    Create a schema for the configuration file entry at the current node.
  </para>
  <xs:param name="gu:modulePathAndFilename">
    <para>The schema module being written (e.g. UBL-Invoice-2.1.json).</para>
  </xs:param>
  <xs:param name="gu:namespace">
    <para>The target namespace of the schema.</para>
  </xs:param>
  <xs:param name="gu:schemaType">
    <para>
      The type of schema being written (CABIE, CBBIE, DABIE, SABIE, SBBIE,
      XABIE, AABIE ).</para>
  </xs:param>
  <xs:param name="gu:moduleABIEsAndASBIEs">
    <para>
      The ABIEs under influence of this schema fragment.
    </para>
  </xs:param>
  <xs:param name="gu:moduleBBIEs">
    <para>
      The BBIEs under influence of this schema fragment.
    </para>
  </xs:param>
</xs:template>
<xsl:template name="gu:JSONschemaWrite">
  <xsl:param name="gu:modulePathAndFilename" as="xsd:string"/>
  <xsl:param name="gu:namespace" as="xsd:string"/>
  <xsl:param name="gu:schemaType" tunnel="yes" as="xsd:string"/>
  <xsl:param name="gu:moduleABIEsAndASBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:param name="gu:moduleBBIEs" tunnel="yes" as="element(Row)*"/>
  
  <xsl:variable name="gu:thisFile" select="."/>
  <xsl:variable name="gu:resultJSON">
    <o>
      <xsl:if test="$gu:schemaType=('DABIE','AABIE')">
        <s n="$schema" v="http://json-schema.org/draft-07/schema#"/>
      </xsl:if>
      <s n="title" v="{
   gu:substituteFields($gu:modulePathAndFilename,$gu:modulePathAndFilename)}"/>
      <s n="description" v="{string-join(
                   (gu:substituteFields($gu:modulePathAndFilename,
                                        (comment,ancestor::schema/comment)[1]),
                    (copyright,ancestor::schema/copyright)[1]),'&#xa;')}"/>
      <xsl:if test="$gu:schemaType=('DABIE','AABIE','XABIE')">
        <xsl:variable name="gu:name"
                      select="$gu:moduleABIEsAndASBIEs/gu:col(.,$gu:names)"/>
        <l n="required"><!--FRG23-->
          <s v="{$gu:name}"/>
        </l>
        <o n="properties">
          <!--FRG22 Document ABIE object namespace declarations-->
          <o n="_D">
            <s n="description" v="Document ABIE XML namespace string"/>
            <s n="type" v="string"/>
          </o>
          <o n="_A">
            <s n="description" 
               v="Library ABIE XML namespace string (for ASBIEs)"/>
            <s n="type" v="string"/>
          </o>
          <o n="_B">
            <s n="description" v="BBIE XML namespace string"/>
            <s n="type" v="string"/>
          </o>
          <o n="_E">
            <s n="description" v="Extension scaffolding XML namespace string"/>
            <s n="type" v="string"/>
          </o>
          <!--FRG23 Document ABIE object reference declaration-->
          <o n="{$gu:name}">
            <s n="description"
               v="{$gu:moduleABIEsAndASBIEs/gu:col(.,'Definition')}"/>
            <o n="items">
              <s n="$ref" v="#/definitions/{$gu:name}"/>
            </o>
            <n n="maxItems" v="1"/>
            <n n="minItems" v="1"/>
            <s n="type" v="array"/>
          </o>
        </o>
        <f n="additionalProperties"/>
        <s n="type" v="object"/>
      </xsl:if>
      <o n="definitions">
        <!--refine collection based on the target fragment-->
        <xsl:choose>
          <xsl:when test="$gu:schemaType='QDT'">
            <xsl:for-each-group select="$gu:moduleBBIEs
                                       [exists(gu:col(.,'DataTypeQualifier'))]"
                                group-by="gu:col(.,'DataType')">
              <xsl:sort select="gu:col(.,'DataType')"/>
              <o n="{translate(gu:col(.,'DataType'),'. ','')}">
                <s n="title" v="{gu:col(.,'DataType')}"/>
                <s n="$ref" v="{
               gu:relativeConfigURI( (key('gu:files','UDT',$gu:configMain),
                                      key('gu:files','UDT',$gu:configOther))
                                      [@syntax='JSON'][1],$gu:thisFile,false())
                                      }#/definitions/{
               gu:comp(concat(gu:col(.,'RepresentationTerm'),'Type'))}"/>
              </o>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:when test="$gu:schemaType=('CBBIE','SBBIE')">
            <xsl:for-each-group select="$gu:moduleBBIEs"
                                group-by="gu:col(.,$gu:names)">
              <xsl:sort select="gu:col(.,$gu:names)"/>
              <o n="{gu:col(.,$gu:names)}">
                <s n="$ref" v="{
          gu:relativeConfigURI( (if( exists(gu:col(.,'DataTypeQualifier')) )
                                 then (key('gu:files','QDT',$gu:configMain),
                                       key('gu:files','QDT',$gu:configOther))
                                 else (key('gu:files','UDT',$gu:configMain),
                                       key('gu:files','UDT',$gu:configOther)) )
                                 [@syntax='JSON'][1],$gu:thisFile,false())
                    }#/definitions/{translate(gu:col(.,'DataType'),'. ','')}"/>
              </o>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
           <!--
             FRG24 Document ABIE object definition declaration
             FRG26 Library ABIE object reference declarations
             FRG27 Library ABIE object definition declarations
             FRG29 Library ABIE object definition declarations
           -->
           <xsl:for-each-group select="$gu:moduleABIEsAndASBIEs
                        [$gu:schemaType='CABIE' or not(gu:isInOtherLibrary(.))]
                        [gu:isSubsetBIE(.)][not(gu:isInOtherLibrary(.))]"
                                group-by="gu:col(.,$gu:names)">
             <xsl:sort select="gu:col(.,$gu:names)"/>
             <!--reorder so that the ABIE is handled before the ASBIE-->
             <xsl:for-each select="current-group()">
              <xsl:sort select="gu:col(.,'ComponentType')"/>    
              <xsl:choose>
                <xsl:when test="position()>1">
                  <!--ignore all except the first one which will be an
                      ABIE when there are both an ABIE and ASBIE-->
                </xsl:when>
                <xsl:when test="gu:col(.,'ComponentType')='ASBIE'">
                  <o n="{gu:col(.,$gu:names)}">
                    <s n="$ref" v="#/definitions/{
                                 gu:comp(gu:col(.,'AssociatedObjectClass'))}"/>
                  </o>
                </xsl:when>
                <xsl:when test="not($gu:schemaType=('DABIE','AABIE')) and
                                ( some $gu:doc in $gu:subsetDocumentABIEs
                                  satisfies $gu:doc is . )">
                  <!--do nothing because the document ABIE is not common-->
                </xsl:when>
                <xsl:otherwise>
              <o n="{gu:col(.,$gu:names)}">
                <s n="title" v="{gu:col(.,'DictionaryEntryName')}"/>
                <s n="description" v="{gu:col(.,'Definition')}"/>
                <xsl:variable name="gu:required" as="element(s)*">
                  <xsl:for-each select="key('gu:bie-by-abie-class',
                                            gu:col(.,'ObjectClass') )">
                    <xsl:if test="gu:minCard(.)='1'">
                      <s v="{gu:col(.,$gu:names)}"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="exists($gu:required)">
                  <l n="required">
                    <xsl:copy-of select="$gu:required"/>
                  </l>
                </xsl:if>
                <o n="properties">
                  <xsl:if test="$gu:schemaType=('DABIE','AABIE') or 
                                ( $gu:extensions4abies and 
                                  $gu:schemaType=('XABIE','CABIE','SABIE') )">
                    <extension/>
                  </xsl:if>
                  <xsl:for-each select="if( gu:col(.,'ComponentType')=
                                                             ('BBIE','ASBIE') )
                                        then .
                                        else key('gu:bie-by-abie-class',
                                            gu:col(.,'ObjectClass') )">
                    <xsl:variable name="gu:thisBIE" select="."/>
                    <xsl:variable name="gu:thisBIEname"
                                  select="gu:col(.,$gu:names)"/>
                    <xsl:variable name="gu:thisBIEtype"
                                  select="gu:col(.,'ComponentType')"/>
                    <xsl:variable name="gu:thisBIEmin" select="gu:minCard(.)"/>
                    <xsl:variable name="gu:thisBIEmax" select="gu:maxCard(.)"/>
                    <xsl:variable name="gu:dtQualifier"
                                  select="gu:col(.,'DataTypeQualifier')"/>
                    <xsl:variable name="gu:dtCompressed"
                             select="translate(gu:col(.,'DataType'),'. ','')"/>
                    <xsl:if test="gu:isSubsetBIE(.)">
                      <o n="{$gu:thisBIEname}">
                        <s n="title" v="{gu:col(.,'DictionaryEntryName')}"/>
                        <s n="description" v="{gu:col(.,'Definition')}"/>
                        <o n="items">
                          <s n="$ref" v="{
                     for $gu:otherFile in
                       if( $gu:thisBIEtype = 'BBIE' )
                       then if( $gu:schemaType=('CBBIE','SBBIE') )
                            then if( $gu:dtQualifier )
                                 then key('gu:files','QDT',$gu:config)
                                 else key('gu:files','UDT',$gu:config)
                            else if( gu:isInOtherLibrary($gu:thisBIE) )
                                 then key('gu:files','CBBIE',$gu:configOther)
                                 else (key('gu:files','CBBIE',$gu:config),
                                       key('gu:files','SBBIE',$gu:config))
                       else if( gu:isInOtherLibrary($gu:thisBIE) )
                            then key('gu:files','CABIE',$gu:configOther)
                            else (key('gu:files','CABIE',$gu:config),
                                  key('gu:files','SABIE',$gu:config))
                     return if( not( $gu:otherFile/@syntax='JSON' ) or
                                ( $gu:otherFile is $gu:thisFile ) )
                            then ()
                            else gu:relativeConfigURI($gu:otherFile,
                                                      $gu:thisFile,false())
                            }#/definitions/{gu:comp($gu:thisBIEname)}"/>
                        </o>
                        <xsl:if test="$gu:thisBIEmax='1'">
                          <n n="maxItems" v="1"/>
                        </xsl:if>
                        <n n="minItems" v="1"/>
                        <s n="type" v="array"/>
                      </o>
                    </xsl:if>
                  </xsl:for-each>
                </o>
                <f n="additionalProperties"/>
                <s n="type" v="object"/>
              </o>
                </xsl:otherwise>
              </xsl:choose>
             </xsl:for-each>
           </xsl:for-each-group>
          </xsl:otherwise>
        </xsl:choose>
      </o>
    </o>
  </xsl:variable>
  <xsl:apply-templates select="$gu:resultJSON" mode="gu:jsonSerialize"/>
</xsl:template>

<xs:template>
  <para>Handle the injection of extension information verbatim</para>
</xs:template>
<xsl:template match="extension" mode="gu:jsonSerialize">
  <xsl:copy-of select="key('gu:files','EXT',$gu:config)[@syntax='JSON']/
                       declaration/string(.)"/>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>XML Schema generator</xs:title>
</xs:doc>
  
<xs:template>
  <para>
    Create a schema for the configuration file entry at the current node.
  </para>
  <xs:param name="gu:modulePathAndFilename">
    <para>The schema module being written (e.g. UBL-Invoice-2.1.xsd).</para>
  </xs:param>
  <xs:param name="gu:namespace">
    <para>The target namespace of the schema.</para>
  </xs:param>
  <xs:param name="gu:schemaType">
    <para>
      The type of schema being written (CABIE, CBBIE, DABIE, SABIE, SBBIE,
      XABIE, AABIE ).</para>
  </xs:param>
  <xs:param name="gu:moduleABIEsAndASBIEs">
    <para>
      The ABIEs under influence of this schema fragment.
    </para>
  </xs:param>
  <xs:param name="gu:moduleBBIEs">
    <para>
      The BBIEs under influence of this schema fragment.
    </para>
  </xs:param>
  <xs:param name="gu:runtime">
    <para>
      An indication if the file being created is for a runtime directory
      as compared to a directory of fully-documented constructs.
    </para>
  </xs:param>
</xs:template>
<xsl:template name="gu:XMLschemaWrite">
  <xsl:param name="gu:modulePathAndFilename" as="xsd:string"/>
  <xsl:param name="gu:namespace" as="xsd:string"/>
  <xsl:param name="gu:schemaType" tunnel="yes" as="xsd:string"/>
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:param name="gu:moduleABIEsAndASBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:param name="gu:moduleBBIEs" tunnel="yes" as="element(Row)*"/>
  
  <xsl:variable name="gu:thisFile" select="."/>
  <xsl:text>&#xa;</xsl:text>
  <xsl:for-each select="(comment,ancestor::schema/comment)[1]">
    <!--put out either the specific comment or the generic comment-->
    <xsl:comment>
      <xsl:value-of select="gu:substituteFields($gu:modulePathAndFilename,.)"/>
    </xsl:comment>
    <xsl:text>&#xa;</xsl:text>
  </xsl:for-each>
  <!--put out either the specific copyright or the generic copyright-->
  <xsl:for-each 
  select="(copyright,ancestor::schema/copyright)[1][@position='start']">
    <xsl:comment> ===== Copyright Notice ===== </xsl:comment>
    <xsl:text>&#xa;</xsl:text>
    <xsl:comment select="."/>
  </xsl:for-each>
  <xsd:schema targetNamespace="{$gu:namespace}"
              elementFormDefault="qualified"
              attributeFormDefault="unqualified"
              version="{ancestor::schema/@version}">
  <xsl:variable name="gu:otherParticipatingFiles" as="element(file)*">
    <!--next check need for the supplemental ABIEs and BBIEs-->
    <xsl:if test="$gu:schemaType=('XABIE','AABIE') and
                  $gu:moduleABIEsAndASBIEs[not(gu:isInOtherLibrary(.))]">
      <xsl:sequence select="key('gu:files','SABIE',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    <xsl:if test="$gu:schemaType=('XABIE','AABIE','SABIE') and
                  $gu:moduleBBIEs[not(gu:isInOtherLibrary(.))]">
      <xsl:sequence select="key('gu:files','SBBIE',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    
    <!--next check need for the common library ABIEs-->
    <xsl:if test="( (:a document ABIE needs access to the library:)
                    ( $gu:schemaType='DABIE' and
                      $gu:moduleABIEsAndASBIEs[not(gu:isInOtherLibrary(.))] )
                or  (:an extension construct needs access to the library:)
                    ( $gu:schemaType=('XABIE','AABIE','SABIE') and
                  $gu:moduleABIEsAndASBIEs[gu:col(.,'ComponentType')='ABIE']/
                  key('gu:asbie-by-abie-class',gu:col(.,'ObjectClass'))/
                  ( for $gu:class in gu:col(.,'AssociatedObjectClass')
                    return $gu:gcOther/key('gu:abie-by-class',$gu:class))))">
      <xsl:sequence select="key('gu:files','CABIE',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    <!--next check need for the common library BBIEs-->
    <xsl:if test="( $gu:schemaType='DABIE' and
                    $gu:moduleBBIEs[not(gu:isInOtherLibrary(.))] ) or
                  ( $gu:schemaType='CABIE' and $gu:moduleBBIEs ) or
                  ( $gu:schemaType=('XABIE','AABIE','SABIE') and
                    $gu:moduleABIEsAndASBIEs[gu:col(.,'ComponentType')='ABIE']/
                  key('gu:bie-by-abie-class',gu:col(.,'ObjectClass'))
                  [gu:col(.,'ComponentType')='BBIE']/
                  ( for $gu:BBIEname in gu:col(.,$gu:names)
                  return $gu:gcOther/key('gu:bbie-by-name',$gu:BBIEname)))">
      <xsl:sequence select="key('gu:files','CBBIE',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    <xsl:if test="$gu:schemaType=('CBBIE','SBBIE')">
      <!--might need to make reference to the data types-->
      <xsl:sequence select="key('gu:files','QDT',$gu:config)[not(@syntax)],
                            key('gu:files','UDT',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    <xsl:if test="$gu:schemaType='QDT'">
      <!--will need to make reference to the data types-->
      <xsl:sequence select="key('gu:files','UDT',$gu:config)[not(@syntax)]"/>
    </xsl:if>
    <!--document-level ABIEs are augmented with extensions -->
    <xsl:if test="$gu:schemaType=('DABIE','AABIE') or 
                  ( $gu:extensions4abies and 
                    $gu:schemaType=('XABIE','CABIE','SABIE') )">
      <xsl:sequence select="key('gu:files','EXT',$gu:config)[not(@syntax)]"/>
    </xsl:if>
  </xsl:variable>
  
  <!--the module's namespace is needed for local references-->
  <xsl:namespace name="" select="$gu:namespace"/>
  <!--add namespaces for all participating files-->
  <xsl:for-each select="(:first check self-referencing common aggregates:)
                        .[$gu:schemaType=('CABIE','SABIE')],
                        (:then add in all of the participating files:)
                        $gu:otherParticipatingFiles">
    <xsl:namespace name="{@prefix}" select="@namespace"/>
  </xsl:for-each>
  <!--add namespaces from any descendants-->
  <xsl:copy-of select=".//namespace::*"/>
  <!--documentation namespaces may be needed-->
  <xsl:if test="not($gu:runtime) and not($gu:schemaType=('CBBIE','SBBIE'))">
    <xsl:copy-of select="(type-documentation,
           $gu:config/combination/configuration/schema/type-documentation)[1]//
                         namespace::*"/>
    <xsl:copy-of select="(element-documentation,
        $gu:config/combination/configuration/schema/element-documentation)[1]//
                         namespace::*"/>
  </xsl:if>

  <!--deal with import statements-->
  <xsl:if test="$gu:otherParticipatingFiles or imports/node()">
    <xsl:call-template name="gu:sectionComment">
      <xsl:with-param name="section">Imports</xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="$gu:otherParticipatingFiles">
      <xsl:element name="xsd:import">
        <xsl:attribute name="namespace" select="@namespace"/>
        <xsl:attribute name="schemaLocation"
                    select="gu:relativeConfigURI(.,$gu:thisFile,$gu:runtime)"/>
      </xsl:element>
    </xsl:for-each>
   <!--the config file declaration may include some import constructs to add-->
    <xsl:copy-of select="imports/node()"/>
  </xsl:if>

  <xsl:if test="not($gu:schemaType='QDT')">
    <xsl:call-template name="gu:elementsSection"/>
  </xsl:if>

  <xsl:call-template name="gu:typesSection"/>

  </xsd:schema>
  <!--put out either the specific copyright or the generic copyright-->
  <xsl:for-each 
    select="(copyright,ancestor::schema/copyright)[1][@position='end']">
    <xsl:comment> ===== Copyright Notice ===== </xsl:comment>
    <xsl:comment select="."/>
  </xsl:for-each>
</xsl:template>
  
<xs:template>
  <para>
    The elements section declares all of the elements and the types they have.
  </para>
  <xs:param name="gu:moduleABIEsAndASBIEs">
    <para>The ABIEs under influence of this schema fragment.</para>
  </xs:param>
  <xs:param name="gu:moduleBBIEs">
    <para>
      The BBIEs under influence of this schema fragment.
    </para>
  </xs:param>
  <xs:param name="gu:schemaType">
    <para>The type of schema being written (CABIE, CBBIE, DABIE).</para>
  </xs:param>
  <xs:param name="gu:runtime">
    <para>
      An indication if the file being created is for a runtime directory
      as compared to a directory of fully-documented constructs.
    </para>
  </xs:param>
</xs:template>
<xsl:template name="gu:elementsSection">
  <xsl:param name="gu:moduleABIEsAndASBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:param name="gu:moduleBBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:param name="gu:schemaType" tunnel="yes" as="xsd:string"/>
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:variable name="gu:thisFile" select="."/>

  <xsl:call-template name="gu:sectionComment">
    <xsl:with-param name="section">Element Declarations</xsl:with-param>
  </xsl:call-template>
  <xsl:choose>
    <xsl:when test="$gu:schemaType=('DABIE','XABIE','AABIE')">
<!--
    FRG02 Document ABIE element declaration
    Each Document ABIE schema fragment shall include a single element
    declaration, that being for the Document ABIE.
-->
      <xsl:element name="xsd:element">
        <xsl:attribute name="name"
                       select="$gu:moduleABIEsAndASBIEs/gu:col(.,$gu:names)"/>
        <xsl:attribute name="type"
                       select="concat($gu:moduleABIEsAndASBIEs/
                                      gu:col(.,$gu:names),'Type')"/>
        <xsl:for-each select="(element-documentation,
             $gu:config/combination/configuration/schema/element-documentation)
                              [1][not($gu:runtime)]">
          <xsl:element name="xsd:annotation">
            <xsl:element name="xsd:documentation">
              <xsl:copy-of select="node()" copy-namespaces="no"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:when>
    <xsl:when test="$gu:schemaType=('CABIE','SABIE')">
<!--
    FRG05 Library ABIE element declarations
    The common Library ABIE schema fragment shall include an element
    declaration for every ASBIE in the model (that is, from every 
    Document ABIE and every Library ABIE) and for every Library ABIE.
-->
      <xsl:variable name="gu:nameTypePairs" as="element(pair)*">
        <!--only work with the ABIEs that are not in the other library and
            are not, themselves, a document-level ABIE-->
        <xsl:if test="$gu:subsetIncludeTypeElements">
          <xsl:for-each select="$gu:moduleABIEsAndASBIEs
                        [$gu:schemaType='CABIE' or not(gu:isInOtherLibrary(.))]
                        [gu:isSubsetBIE(.)][not(gu:isInOtherLibrary(.))]
                        [not( some $gu:doc in $gu:subsetDocumentABIEs
                              satisfies $gu:doc is . )]
                        [gu:col(.,'ComponentType')='ABIE' or
                        not( for $gu:class in gu:col(.,'AssociatedObjectClass')
                       return $gu:gcOther/key('gu:abie-by-class',$gu:class))]">
            <xsl:variable name="type"
            select="(gu:colcomp(.,'AssociatedObjectClass')[normalize-space(.)],
                                   gu:colcomp(.,'ObjectClass'))[1]"/>
            <pair den="{gu:col(.,'DictionaryEntryName')}"
                  typedElement="">
              <name><xsl:value-of select="$type"/></name>
              <xsl:text>&#xd;</xsl:text>
              <type><xsl:value-of select="$type"/></type>
            </pair>
          </xsl:for-each>
        </xsl:if>
        <!--check each ASBIE whether it is already an ABIE or its ABIE is
            in the other library-->
        <xsl:for-each select="$gu:moduleABIEsAndASBIEs/
                   key('gu:asbie-by-abie-class',gu:col(.,'ObjectClass'),$gu:gc)
                         [$gu:schemaType=('CABIE','SABIE') or
                          not(gu:isInOtherLibrary(.)) ]
                         [gu:isSubsetBIE(.)]">
          <!--create a pair whenever the ASBIE is not in the other library-->
<!--
    DCL09 ASBIE schema element declaration

    Every ASBIE element shall be declared with the ASBIE name as the element
    name and the ABIE name of the associated object class suffixed with 
    "Type" as the type.
-->
          <pair den="{gu:col(.,'DictionaryEntryName')}">
            <xsl:attribute name="gu:isSubsetABIE" 
              select="gu:isSubsetABIE(preceding-sibling::Row
                                      [gu:col(.,'ComponentType')='ABIE'][1])"/>
            <xsl:attribute name="gu:isSubsetBIE" 
                           select="gu:isSubsetBIE(.)"/>
            <name><xsl:value-of select="gu:col(.,$gu:names)"/></name>
            <xsl:text>&#xd;</xsl:text>
            <type>
              <!--need to determine if the type is local or common-->
              <xsl:for-each select="gu:col(.,'AssociatedObjectClass')">
               <xsl:if test="$gu:gcOther/key('gu:abie-by-class',current())">
                  <!--the type is common, so the prefix is needed-->
                  <xsl:value-of select="$gu:cabiePrefixColon"/>
               </xsl:if>
               <xsl:value-of select="translate(.,' ','')"/>
              </xsl:for-each>
            </type>
          </pair>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each-group select="$gu:nameTypePairs" group-by="name">
        <xsl:sort select="."/>
<!--    
    DCL01 Element declarations
    Every BIE element declaration shall be global.

    DCL02 Element declaration references
    Every BIE element in an ABIE type definition shall be declared by
    reference.
    
    DCL04 ABIE element declaration
    Every ABIE element shall be declared with the ABIE name as the 
    element name and the ABIE name suffixed with "Type" as the type.
    
    DCL05 ABIE type declaration
    Every ABIE complex type name shall be declared with the name of
    the ABIE suffixed with "Type" as the name.
-->
        <xsl:element name="xsd:element">
          <xsl:attribute name="name" select="name"/>
          <xsl:attribute name="type" select="concat(type,'Type')"/>
        </xsl:element>
      </xsl:for-each-group>
    </xsl:when>
    <xsl:when test="$gu:schemaType=('CBBIE','SBBIE')">
<!--
    FRG08 BBIE element declarations
    The common BBIE schema fragment shall include an element declaration
    for every BBIE in the model (that is, from every Document ABIE and
    every Library ABIE) describing the content of each BBIE.
-->
      <xsl:for-each-group select="$gu:moduleBBIEs[
                                 gu:isSubsetABIE(preceding-sibling::Row
                                       [gu:col(.,'ComponentType')='ABIE'][1])]"
                          group-by="gu:col(.,$gu:names)">
        <xsl:sort select="current-grouping-key()"/>
        <xsl:if test="$gu:schemaType='CBBIE' or not(gu:isInOtherLibrary(.))">
<!--
    DCL10 BBIE element declaration
    Every BBIE element shall be declared with the BBIE name as the element 
    name and the concatenation of the BBIE name and "Type" as the type.
-->
          <xsl:element name="xsd:element">
            <xsl:attribute name="name" select="current-grouping-key()"/>
            <xsl:attribute name="type" 
                           select="concat(current-grouping-key(),'Type')"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:when>
  </xsl:choose>
</xsl:template>
  
<xs:template>
  <para>
    The types section defines the type of each element.
  </para>
  <xs:param name="gu:moduleABIEsAndASBIEs">
    <para>The ABIEs under influence of this schema fragment.</para>
  </xs:param>
  <xs:param name="gu:moduleBBIEs">
    <para>
      The BBIEs under influence of this schema fragment.
    </para>
  </xs:param>
  <xs:param name="gu:schemaType">
    <para>The type of schema being written (CABIE, CBBIE, DABIE).</para>
  </xs:param>
  <xs:param name="gu:runtime">
    <para>
      as compared to a directory of fully-documented constructs.
      An indication if the file being created is for a runtime directory
    </para>
  </xs:param>
</xs:template>
<xsl:template name="gu:typesSection">
  <xsl:param name="gu:schemaType" tunnel="yes" as="xsd:string"/>
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:param name="gu:moduleABIEsAndASBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:param name="gu:moduleBBIEs" tunnel="yes" as="element(Row)*"/>
  <xsl:variable name="gu:thisFile" select="."/>
  <xsl:variable name="gu:documentation"
              select="(type-documentation,
                $gu:config/combination/configuration/schema/type-documentation)
                      [1][not($gu:runtime)]"/>
  <xsl:choose>
    <xsl:when test="$gu:schemaType=('DABIE','CABIE','XABIE','AABIE','SABIE')">
      <xsl:variable name="gu:thisCBCprefixColon"
                    select="if( $gu:schemaType = ('DABIE','CABIE') ) 
                            then $gu:cbbiePrefixColon
                            else $gu:sbbiePrefixColon"/>
      <xsl:variable name="gu:thisCACprefixColon"
                    select="if( $gu:schemaType = 'DABIE' ) 
                            then $gu:cabiePrefixColon
                            else if( $gu:schemaType=('XABIE','AABIE','SABIE') )
                            then $gu:sabiePrefixColon
                            else ''"/>
<!--
    FRG03 Document ABIE type declaration
    Each Document ABIE schema fragment shall include a single type
    declaration, that being for the content of the Document ABIE.
    
    FRG06 Library ABIE type declarations
    The common Library ABIE schema fragment shall include a type 
    declaration for every Library ABIE, each being for the content 
    of each Library ABIE.
    
    DCL03 Type declarations
    Every BIE type declaration shall be global.
-->
      <xsl:call-template name="gu:sectionComment">
        <xsl:with-param name="section" 
          select="'Type Definitions',
                  'Aggregate Business Information Entity Type Definitions'"/>
      </xsl:call-template>

      <xsl:for-each-group select="( 
        $gu:moduleABIEsAndASBIEs[gu:col(.,'ComponentType')='ABIE'],
        $gu:moduleABIEsAndASBIEs[gu:col(.,'ComponentType')='ASBIE']/
        key('gu:abie-by-class',gu:col(.,'AssociatedObjectClass')) )
                                        [not(gu:isInOtherLibrary(.))]"
                          group-by="gu:col(.,'ObjectClass')">
        <xsl:sort select="current-grouping-key()"/>
        
        <xsl:variable name="gu:thisABIE" select="."/>
        <xsl:choose>
          <xsl:when test="not($gu:subsetIncludeIgnoredTypes) and
                          not($gu:subsetIncludeTypeElements) and
                          not(gu:isADocumentABIE(.)) and
                          not(gu:isAReferencedABIE(.))">
            <xsl:if test="not($gu:runtime) and $gu:subsetExclusions">
              <xsl:comment>
                <xsl:text>Subset has no use of: den="</xsl:text>
                <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
                <xsl:text>"</xsl:text>
              </xsl:comment>
              <xsl:text>&#xa;   </xsl:text>
            </xsl:if>
          </xsl:when>            
          <xsl:when test="not( gu:isSubsetABIE(.) )">
            <xsl:if test="not($gu:runtime) and $gu:subsetExclusions">
              <!--document the fact that the item is removed-->
              <xsl:comment>
                <xsl:text>Subset excludes: den="</xsl:text>
                <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
                <xsl:text>"</xsl:text>
              </xsl:comment>
              <xsl:text>&#xa;   </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
        <xsl:element name="xsd:complexType">
          <xsl:attribute name="name" 
                         select="concat(gu:colcomp(.,'ObjectClass'),'Type')"/>
          <!--document the construct-->
          <xsl:for-each select="$gu:documentation">
            <xsl:element name="xsd:annotation">
              <xsl:element name="xsd:documentation">
                <xsl:apply-templates select="*" 
                                     mode="gu:documentation-replacement">
                <xsl:with-param name="bie" tunnel="yes" select="$gu:thisABIE"/>
                </xsl:apply-templates>
              </xsl:element>
            </xsl:element>
          </xsl:for-each>
          <!--the children of the construct-->
<!--
    DCL06 Library ABIE type declaration content order
    The members of a Library ABIE shall be ordered as the sequence (in 
    the order the BIEs appear in the semantic model of the ABIE) of all
    BBIE element references first, followed by all ASBIE references.

    DCL07 Document ABIE type declaration content order
    The members of a Document ABIE shall be ordered first with a 
    reference to the extension collection element, followed by the
    sequence (in the order the BIEs appear in the semantic model of
    the ABIE) of all BBIE element references first, followed by all 
    ASBIE references.
-->
          <xsl:element name="xsd:sequence">
            <!--first, a document ABIE starts with the extension constructs,
                but not for the extension apex-->
            <xsl:if test="$gu:schemaType=('DABIE','AABIE') or 
                          ( $gu:extensions4abies and 
                            $gu:schemaType=('XABIE','CABIE','SABIE') )">
<!--
    DCL08 Document ABIE extension element cardinality
    In the content type for every Document ABIE the extension collection
    element cardinality shall be declared as optional and not repeatable.
-->
              <xsl:apply-templates mode="gu:noRuntimeAnnotations" 
                        select="key('gu:files','EXT',$gu:config)[not(@syntax)]/
                                                     elements/node()"/>
            </xsl:if>
            <!--next the children of the ABIE-->
            <xsl:for-each select="key('gu:bie-by-abie-position',
                                      gu:col($gu:thisABIE,'ObjectClass'),
                                      $gu:gc)">
              <xsl:variable name="gu:thisBIE" select="."/>
              <xsl:variable name="gu:thisBIEtype"
                            select="gu:col(.,'ComponentType')"/>
              <xsl:variable name="gu:thisBIEassociatedObjectClass"
                            select="gu:col(.,'AssociatedObjectClass')"/>
              <xsl:variable name="gu:thisBIEisCommon"
                            select="$gu:schemaType='CABIE' or
                                    gu:isInOtherLibrary($gu:thisBIE)"/>
              <xsl:variable name="gu:thisBIEmin" select="gu:minCard(.)"/>
              <xsl:variable name="gu:thisBIEmax" select="gu:maxCard(.)"/>
              <xsl:variable name="gu:thisBIEcard"
                            select="normalize-space(gu:col(.,'Cardinality'))"/>
              <xsl:variable name="gu:thisBIEsubsetCard"
                     select="normalize-space(gu:col(.,$gu:subsetColumnName))"/>
              <xsl:variable name="gu:ref" select="concat(
                    if( $gu:thisBIEtype='BBIE' )
                     then if( $gu:thisBIEisCommon )
                          then $gu:cbbiePrefixColon else $gu:thisCBCprefixColon
                     else if( $gu:thisBIEisCommon )
                          then $gu:cabiePrefixColon else $gu:thisCACprefixColon
                                                       ,gu:col(.,$gu:names))"/>
              <xsl:choose>
                <xsl:when test="not(gu:isSubsetBIE(.))">
                  <xsl:if test="not($gu:runtime) and $gu:subsetExclusions">
                    <!--first time around there is no indentation when doing
                        other than the DABIE (because of extension)-->
                    <xsl:if test="position()=1 and 
                                  not($gu:schemaType=('DABIE','AABIE'))">
                      <xsl:text>&#xa;         </xsl:text>
                    </xsl:if>
                    <!--document the fact that the item is removed-->
                    <xsl:comment>
                      <xsl:text>Subset excludes: ref="</xsl:text>
                      <xsl:value-of select="$gu:ref"/>
                      <xsl:text>" cardinality="</xsl:text>
                      <xsl:value-of select="$gu:thisBIEcard"/>
                      <xsl:text>" den="</xsl:text>
                      <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
                      <xsl:text>"</xsl:text>
                    </xsl:comment>
                    <xsl:text>&#xa;         </xsl:text>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                 <xsl:element name="xsd:element">
                    <xsl:attribute name="ref" select="$gu:ref"/>
                    <xsl:attribute name="minOccurs" select="$gu:thisBIEmin"/>
                    <xsl:attribute name="maxOccurs" select="$gu:thisBIEmax"/>
                    <!--document the construct-->
                    <xsl:if test="not($gu:runtime) and
                               $gu:thisBIEsubsetCard!='' and
                               not( $gu:thisBIEsubsetCard=$gu:thisBIEcard ) and
                               $gu:activeSubsetting and
                               $gu:subsetExclusions">
                      <!--document the fact that the item is removed-->
                      <xsl:text>&#xa;            </xsl:text>
                      <xsl:comment>
                        <xsl:text>Subset changes: ref="</xsl:text>
                        <xsl:value-of select="$gu:ref"/>
                        <xsl:text>"; original cardinality="</xsl:text>
                        <xsl:value-of select="$gu:thisBIEcard"/>
                        <xsl:text>" den="</xsl:text>
                       <xsl:value-of select="gu:col(.,'DictionaryEntryName')"/>
                        <xsl:text>"</xsl:text>
                      </xsl:comment>
                      <xsl:text>&#xa;            </xsl:text>
                    </xsl:if>
                    <xsl:for-each select="$gu:documentation">
                      <xsl:element name="xsd:annotation">
                        <xsl:element name="xsd:documentation">
                          <xsl:apply-templates select="*" 
                                           mode="gu:documentation-replacement">
                            <xsl:with-param name="bie" tunnel="yes" 
                                            select="$gu:thisBIE"/>
                          </xsl:apply-templates>
                        </xsl:element>
                      </xsl:element>
                    </xsl:for-each>
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <!--the config file declaration may include some elements to add-->
            <xsl:copy-of select="$gu:thisFile/elements[
                                @abie=gu:col($gu:thisABIE,$gu:names)]/node()"/>
          </xsl:element>
        </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:when>
    <xsl:when test="$gu:schemaType=('CBBIE','SBBIE')">
      <xsl:call-template name="gu:sectionComment">
        <xsl:with-param name="section" 
          select="'Type Definitions',
                  'Basic Business Information Entity Type Definitions'"/>
      </xsl:call-template>
<!--
    FRG09 Library ABIE type declarations
    The one BBIE schema fragment shall include a type declaration for 
    every BBIE in the model (that is, from every Document ABIE and every 
    Library ABIE), each being for the content of each BBIE.
    
    DCL03 Type declarations
    Every BIE type declaration shall be global.
-->
      
      <xsl:for-each-group select="$gu:moduleBBIEs" 
                          group-by="gu:col(.,$gu:names)">
        <xsl:sort select="concat(current-grouping-key(),'Type')"/>
        <xsl:if test="$gu:schemaType = 'CBBIE' or
                      not( gu:isInOtherLibrary(.) )">
<!--
    DCL11 BBIE type declaration
    Every BBIE element type shall be declared as simple content extended from
    a base of either a qualified data type or an unqualified data type without
    the addition of any additional attributes.
-->
          <xsl:element name="xsd:complexType">
            <xsl:attribute name="name"
                           select="concat(current-grouping-key(),'Type')"/>
            <xsl:variable name="gu:rawDataType"
                          select="gu:col(.,'DataType')"/>
            <xsl:variable name="gu:dataType"
                       select="if( contains( $gu:rawDataType, '_' ) )
                               then substring-after($gu:rawDataType,'_')
                               else $gu:rawDataType"/>
            <xsl:variable name="gu:isQDT"
                          select="contains($gu:rawDataType, '_')
                                  and not($gu:qdt4UBL2.1Only)"/>
            <xsl:element name="xsd:simpleContent">
              <xsl:element name="{if( $gu:qdt4UBL2.1Only )
                                 then 'xsd:extension' else 'xsd:restriction'}">
                <xsl:attribute name="base">
                  <!--in which library is this data item going to be found?-->
                  <xsl:choose>
                    <xsl:when test="$gu:isQDT">
                  <xsl:value-of select="concat(key('gu:files','QDT',$gu:config)
                                                 [not(@syntax)]/@prefix,':',
                                        translate($gu:rawDataType,'_ .',''))"/>
                    </xsl:when>
                    <xsl:otherwise>
                  <xsl:value-of select="concat(key('gu:files','UDT',$gu:config)
                                               [not(@syntax)]/@prefix,':',
                                            translate($gu:dataType,' .',''))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:when>
    <xsl:when test="$gu:schemaType=('QDT')">
      <xsl:call-template name="gu:sectionComment">
        <xsl:with-param name="section" 
          select="'Qualified Data Type Definitions'"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$gu:qdt4UBL2.1Only">
          <!--no qualified data types defined at this time-->
        </xsl:when>
        <xsl:otherwise>
         <xsl:for-each-group select="$gu:moduleBBIEs" 
                             group-by="gu:col(.,'DataType')">
           <xsl:sort select="current-grouping-key()"/>
             <xsl:element name="xsd:complexType">
               <xsl:attribute name="name"
                         select="translate(current-grouping-key(),'_ .','')"/>
               <xsl:element name="xsd:simpleContent">
                   <xsl:element name="xsd:restriction">
                     <xsl:attribute name="base">
                       <xsl:variable name="gu:rawDataType"
                                     select="gu:col(.,'DataType')"/>
                  <xsl:value-of select="concat(key('gu:files','UDT',$gu:config)
                                                  [not(@syntax)]/@prefix,':',
                    translate(substring-after($gu:rawDataType,'_'),' .',''))"/>
                    </xsl:attribute>
                  </xsl:element>
               </xsl:element>
             </xsl:element>
         </xsl:for-each-group>
           </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>
  
<xs:template>
  <para>
    This template copies a documentation template, replacing the content
    of any element with text but no element children with the genericode
    column value of the name of that text.
  </para>
  <para>
    For example: <literal>&lt;description>Definition&lt;/description></literal>
    will produce an element named <literal>&lt;description></literal> with
    the content of the row's column named "Definition".
  </para>
  <xs:param name="bie">
    <para>The row in genericode for the BIE</para>
  </xs:param>
</xs:template>
<xsl:template match="*" mode="gu:documentation-replacement">
  <xsl:param name="bie" tunnel="yes" as="element(Row)"/>
  <xsl:choose>
    <xsl:when test="*">
      <!--preserve element structure down to the content of a leaf element-->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates select="*" mode="gu:documentation-replacement"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <!--preserve leaf element if there is corresponding column content-->
      <xsl:if test="gu:col($bie,.)[normalize-space(.)]">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:value-of select="gu:col($bie,.)"/>
        </xsl:copy>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xs:template>
  <para>Prune XSD annotations while copying a schema fragment</para>
  <xs:param name="gu:runtime">
    <para>
      An indication if the file being created is for a runtime directory
      as compared to a directory of fully-documented constructs.
    </para>
  </xs:param>
</xs:template>
<xsl:template match="xsd:annotation | text()" mode="gu:noRuntimeAnnotations">
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:if test="not($gu:runtime)">
    <xsl:next-match/><!--go ahead and preserve this element; not in runtime-->
  </xsl:if>
</xsl:template>

<xs:template>
  <para>Preserve elements while copying a schema fragment</para>
</xs:template>
<xsl:template match="*" mode="gu:noRuntimeAnnotations">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="gu:noRuntimeAnnotations"/>
  </xsl:copy>
</xsl:template>

<!--========================================================================-->
<xs:doc>
  <xs:title>CVA generator</xs:title>
  <para>
    The request for CVA output infers that qualified data types are
    entirely implemented using an OASIS Context/Value Association file.
    The value "yes" will inhibit all data type qualifications using a formal
    Qualified Data Type, instead using an Unqualified Data Type by assuming
    that a CVA file will take the responsibility of checking data type 
    qualifications.
  </para>
  <para>
    The OASIS Context/Value Association specification is available at
    <ulink url="http://docs.oasis-open.org/codelist/ContextValueAssociation/">
<literal>http://docs.oasis-open.org/codelist/ContextValueAssociation/</literal>
    </ulink>.
  </para>
  <para>
    This program presumes the presence of an application annotation named 
    <literal>DataType</literal> that indicates which data type BBIE contexts
    are to be used for the CVA context. The string in @address is copied to
    the end of each context address. In this excerpt from the
    "ubl/UBL-2.1-CVA-Skeleton.cva" example:
  </para>
  <programlisting>  ...xmlns:c="urn:X-Crane-gc2obdndr"...      
  &lt;Context values="UnitOfMeasure-2.0 UnitOfMeasure-2.1"
           metadata="cctsV2.01-quantity"
           address="/@unitCode">
    &lt;Annotation>
      &lt;AppInfo>
        &lt;c:DataType>Quantity. Type&lt;/c:DataType>
      &lt;/AppInfo>
    &lt;/Annotation>
  &lt;/Context>
</programlisting>
</xs:doc>

<xs:template>
  <para>
    This creates the selection of contexts that are pertinent and makes it
    available to other tests.
  </para>
</xs:template>
<xsl:template match="/*" mode="gu:CVAWrite">
  <xsl:copy>
    <xsl:apply-templates mode="gu:CVAWrite" select="@*,node()">
      <xsl:with-param name="contexts" as="element(Context)*" tunnel="yes">
        <xsl:apply-templates select="Contexts/Context" mode="gu:CVAWrite"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    This is an identity transform replicating the skeleton CVA file but
    intercepting a reference to an NDR data type.  This template is the
    identity transform portion.
  </para>
</xs:template>
<xsl:template match="@*|node()" mode="gu:CVAWrite">
  <xsl:copy>
    <xsl:apply-templates mode="gu:CVAWrite" select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    Remove known element white-space that 
  </para>
</xs:template>
<xsl:template match="InstanceMetadataSets/text() | ValueLists/text()"
              mode="gu:CVAWrite"/>

<xs:template>
  <para>
    Only copy the instance metadata set if it is being used.
  </para>
  <xs:param name="contexts">
    <para>Those contexts that expected to be written out.</para>
  </xs:param>
</xs:template>
<xsl:template match="ValueList" mode="gu:CVAWrite">
  <xsl:param name="contexts" as="element(Context)*" tunnel="yes"/>
  <xsl:if test="exists($contexts[tokenize(@values,'\s+')=current()/@xml:id])">
   <xsl:copy>
     <xsl:apply-templates mode="gu:CVAWrite" select="@*,node()"/>
   </xsl:copy>
  </xsl:if>
</xsl:template>

<xs:template>
  <para>
    Only copy the instance metadata set if it is being used.
  </para>
  <xs:param name="contexts">
    <para>Those contexts that expected to be written out.</para>
  </xs:param>
</xs:template>
<xsl:template match="InstanceMetadataSet" mode="gu:CVAWrite">
  <xsl:param name="contexts" as="element(Context)*" tunnel="yes"/>
  <xsl:if test="exists($contexts[@metadata=current()/@xml:id])">
   <xsl:copy>
     <xsl:apply-templates mode="gu:CVAWrite" select="@*,node()"/>
   </xsl:copy>
  </xsl:if>
</xsl:template>

<xs:template>
  <para>
    Only copy the contexts that are needed.
  </para>
  <xs:param name="contexts">
    <para>Those contexts that expected to be written out.</para>
  </xs:param>
</xs:template>
<xsl:template match="Contexts" mode="gu:CVAWrite">
  <xsl:param name="contexts" as="element(Context)*" tunnel="yes"/>
  <xsl:copy>
    <xsl:copy-of select="@*,Annotation,$contexts"/>
  </xsl:copy>
</xsl:template>

<xs:template>
  <para>
    Translate <literal>DataType</literal> annotation into a CVA
    <literal>address=</literal> attribute.  If there are no such datatypes,
    use the empty XPath address.
  </para>
</xs:template>
<xsl:template match="Context[Annotation/AppInfo/dt:DataType]" 
              mode="gu:CVAWrite">
  <xsl:variable name="gu:contexts"
                select="gu:contexts(Annotation/AppInfo/dt:DataType,
                                    @address)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!--use an impossible match pattern when there are no contexts-->
      <xsl:attribute name="address"
       select="(normalize-space($gu:contexts)[string(.)],'/*[parent::*]')[1]"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
</xsl:template>

<xs:function>
  <para>
    Determine the contexts for a given data type.
  </para>
  <xs:param name="gu:dataType">
    <para>The data types to find</para>
  </xs:param>
  <xs:param name="gu:suffix">
    <para>The suffix to add to each address</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:contexts" as="xsd:string">
  <xsl:param name="gu:dataType" as="xsd:string+"/>
  <xsl:param name="gu:suffix" as="xsd:string?"/>
  <xsl:value-of>
      <xsl:for-each-group select="for $each in $gu:dataType return
                                  key('gu:bbie-by-data-type',$each,$gu:gc)
                                                           [gu:isSubsetBIE(.)]"
                         group-by="gu:col(.,$gu:names)">
       <xsl:sort select="current-grouping-key()"/>
       <xsl:if test="position()>1"> | </xsl:if>

       <xsl:choose>
         <xsl:when test="count(distinct-values(
                               key('gu:bbie-by-name',current-grouping-key())/
                               gu:col(.,'DataTypeQualifier')/string(.)))>1">
           <!--simply using the name would be ambiguous, so add all parents
               based on the ASBIE use of the ABIE with the BBIE-->
          <xsl:variable name="gu:ABIEs" select="current-group()/
                 preceding-sibling::Row[gu:col(.,'ComponentType')='ABIE'][1]"/>
           <xsl:variable name="gu:ASBIEs"
                         select="$gu:ABIEs/gu:col(.,'ObjectClass')/
                                           key('gu:asbie-by-referred-abie',.)
                                           [gu:isSubsetBIE(.)]"/>

           <xsl:for-each select="$gu:ASBIEs">
             <xsl:sort select="gu:col(.,$gu:names)"/>
             <xsl:if test="position()>1"> | </xsl:if>
             <xsl:value-of select="concat($gu:cabiePrefixColon,
                                          gu:col(.,$gu:names),
                                          '/',
                                          $gu:cbbiePrefixColon,
                                          current-grouping-key(),
                                          $gu:suffix)"/>
           </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="concat($gu:cbbiePrefixColon,
                                        current-grouping-key(),
                                        $gu:suffix)"/>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:for-each-group>
  </xsl:value-of>
</xsl:function>

<!--========================================================================-->
<xs:doc>
  <xs:title>URI calculation functions</xs:title>
</xs:doc>
  
<xs:function>
  <para>
      Return a relative URI of the target config node relative to the source
      config node, perhaps using the runtime name of a directory.
  </para>
  <xs:param name="gu:target">
    <para>The config element to which the URI points.</para>
  </xs:param>
  <xs:param name="gu:source">
    <para>The config element from which the URI points.</para>
  </xs:param>
  <xs:param  name="gu:runtime">
    <para>
      An indication that the runtime directory name is to be used in 
      preference to the directory name.
    </para>
  </xs:param>
</xs:function>
<xsl:function name="gu:relativeConfigURI" as="xsd:string">
  <xsl:param name="gu:target" as="element()"/>
  <xsl:param name="gu:source" as="element()"/>
  <xsl:param name="gu:runtime" as="xsd:boolean"/>
  
  <xsl:variable name="gu:closestTargetDir"
    select="($gu:target/ancestor::dir[@name=$gu:source/ancestor::dir/@name][1],
             $gu:target/ancestor::schema)[1]"/>
  <xsl:variable name="gu:closestSourceDir"
    select="($gu:source/ancestor::dir[@name=$gu:target/ancestor::dir/@name][1],
             $gu:source/ancestor::schema)[1]"/>
  <xsl:value-of>
    <xsl:for-each 
       select="$gu:source/ancestor::*[ancestor::*[. is $gu:closestSourceDir]]">
      <xsl:text>../</xsl:text>
    </xsl:for-each>
    <xsl:for-each 
       select="$gu:target/ancestor::*[ancestor::*[. is $gu:closestTargetDir]]">
      <xsl:value-of select="if( @runtime-name and $gu:runtime )
                            then @runtime-name else @name"/>
      <xsl:text>/</xsl:text>
    </xsl:for-each>
    <xsl:value-of select="$gu:target/@name"/>
  </xsl:value-of>
</xsl:function>

<!--========================================================================-->
<xs:doc>
  <xs:title>Utility templates and functions</xs:title>
</xs:doc>
  
<xs:template>
  <para>Return any problems with the inputs and arguments</para>
  <!--
    not checked:  all pairs of sabie-prefix=/sbbie-prefix same or exclusive
  -->
</xs:template>
<xsl:template name="gu:validateInputs">
  <!--check all extension information is present-->
  <xsl:choose>
    <xsl:when test="boolean($base-gc-uri) != 
                    exists($gu:outputFiles[@type=('XABIE','AABIE')])">
      <xsl:text>Creating extension/addition constructs requires and </xsl:text>
      <xsl:text>satisfies base-uri being specified.  One cannot </xsl:text>
      <xsl:text>have one without having the other.&#xa;</xsl:text>
    </xsl:when>
  </xsl:choose>
  
  <!--check the input genericode files-->
  <xsl:for-each select="$gu:gc,$gu:gcOther">
    <xsl:choose>
      <xsl:when test="namespace-uri(/*) !=
                       'http://docs.oasis-open.org/codelist/ns/genericode/1.0/'
                      or local-name(/*) != 'CodeList'">
     <xsl:text>Expected {http://docs.oasis-open.org/codelist/ns/</xsl:text>
     <xsl:text>genericode/1.0/}CodeList as the document element of "</xsl:text>
        <xsl:value-of select="document-uri(/)"/>
        <xsl:text>", but found the document element: </xsl:text>
      <xsl:value-of select="concat('{',namespace-uri(/*),'}',local-name(/*))"/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="gu:abie-models" as="element()*">
          <xsl:for-each-group group-by="gu:col(.,'ModelName')"
            select="/*/SimpleCodeList/Row[gu:col(.,'ComponentType')='ABIE']">
              <model name="{current-grouping-key()}" 
                     abie-count="{count(current-group())}"/>
          </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="count($gu:abie-models[@abie-count>1])>1">
          <xsl:text>Found in the genericode input too many common </xsl:text> 
          <xsl:text>library models with multiple ABIE constructs: </xsl:text>
          <xsl:value-of select="$gu:abie-models[@abie-count>1]"
                        separator=", "/>
          <xsl:text>&#xa;</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:for-each>

  <!--check the input for any subsetting issues-->
  <xsl:call-template name="gu:checkSubsetting"/>
    
  <!--check the configuration files-->
  <xsl:for-each select="$gu:configMain, $gu:configOther">
   <xsl:choose>
    <xsl:when test="not(/configuration)">
      <xsl:text>Expected {}configuration as the document element of </xsl:text>
      <xsl:text>the configuration file, but in "</xsl:text>
      <xsl:value-of select="document-uri(/)"/>
      <xsl:text>" found the document element: </xsl:text>
      <xsl:value-of select="concat('{',namespace-uri(/*),'}',local-name(/*))"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(/*/ndr) and not(/*/schema)">
        <xsl:text>The configuration file must have an ndr section </xsl:text>
        <xsl:text>and/or a schema section and neither has been </xsl:text>
        <xsl:text>detected.&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="exists(/*/ndr/abbreviations)">
        <xsl:text>The use of &lt;abbreviations> is archaic and </xsl:text>
        <xsl:text>the configuration file needs to be modified.&#xa;</xsl:text>
      </xsl:if>
      <!--version= is a required attribute-->
      <xsl:if test="not(normalize-space(/*/schema/@version))">
  <xsl:text>A version of the suite of schemas must be specified </xsl:text>
  <xsl:text>using version= on the configuration file document </xsl:text>
  <xsl:text>element.&#xa;</xsl:text>
      </xsl:if>
      <!--does every copyright have a position?-->
      <xsl:for-each select="/*/schema/copyright">
        <xsl:if test="not(@position=('start','end'))">
          <xsl:text>Every copyright statement must have </xsl:text>
          <xsl:text>position="start" or position="end": </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <!--does every file element have reqired attributes?-->
      <xsl:for-each select="/*/schema//(file|files)">
        <xsl:choose>
          <xsl:when test="@type='CVA' and not(normalize-space(@name)) and
                          not(normalize-space(@skeleton))">
            <xsl:text>Each of type= and name= and skeleton= must be </xsl:text>
            <xsl:text>specified: </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="not(normalize-space(@type)) or 
                          not(normalize-space(@name)) or
                        (@type != 'CVA' and not(@syntax) and
                         not(normalize-space(@namespace)))">
            <xsl:text>Each of type=, name= and namespace= must be </xsl:text>
            <xsl:text>specified: </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="not(normalize-space(@type)) or 
                          not(normalize-space(@name))">
            <xsl:text>Each of type= and name= must be specified: </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="not(@type=('CABIE','CBBIE','QDT','UDT','EXT','DABIE',
                                     'CVA','XABIE','AABIE','SABIE','SBBIE'))">
            <xsl:text>Invalid type attribute: </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@abie and (not(self::file) or 
                                     not(@type=('DABIE','AABIE','XABIE')))">
            <xsl:text>abie= can only be specified for a single </xsl:text>
            <xsl:text>file with type 'DABIE', 'XABIE' or 'AABIE': </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="self::file and @type=('DABIE','AABIE','XABIE')
                          and not(string(@abie))">
            <xsl:text>abie= must be specified for a single </xsl:text>
            <xsl:text>file with type 'DABIE', 'XABIE' or 'AABIE': </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@type=('DABIE','AABIE','XABIE') and
                          count($gu:allDocumentABIEnames)=0">
     <xsl:text>No document-level ABIEs supplied to satisfy type='</xsl:text>
            <xsl:value-of select="@type"/>
            <xsl:text>': </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="self::files and 
                          not(@type=( 'DABIE','XABIE','AABIE'))">
   <xsl:text>&lt;files> must have a type of DABIE, XABIE or AABIE': </xsl:text>
            <xsl:value-of select="gu:reportElement(.)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
        </xsl:choose>
        <!--additional tests for CVA files; the skeleton must exist-->
        <xsl:if test="@type='CVA'">
          <xsl:variable name="gu:skeleton" select="document(@skeleton-uri)"/>
          <xsl:if test="not($gu:skeleton)">
        <xsl:text>Unable to open specified input CVA skeleton file "</xsl:text>
              <xsl:value-of select="@skeleton-uri"/>
              <xsl:text>" relative to configuration file: </xsl:text>
              <xsl:value-of select="base-uri(@skeleton-uri)"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:if>
          <xsl:for-each select="$gu:skeleton">
            <xsl:if test="local-name(/*) != 'ContextValueAssociation' or
                          namespace-uri(/*) !=
        'http://docs.oasis-open.org/codelist/ns/ContextValueAssociation/1.0/'">
      <xsl:text>Expected {http://docs.oasis-open.org/codelist/ns/</xsl:text>
      <xsl:text>ContextValueAssociation/1.0/}ContextValueAssociation</xsl:text>
      <xsl:text> as the document element of </xsl:text>
      <xsl:text>the input file "</xsl:text>
      <xsl:value-of select="document-uri(/)"/>
      <xsl:text>", but found the document element: </xsl:text>
      <xsl:value-of select="concat('{',namespace-uri(/*),'}',local-name(/*))"/>
      <xsl:text>&#xa;</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
</xsl:template>
  
<xs:template>
  <para>
    Format section comments consistently.  All supplied sections are
    emitted on adjacent lines.  Use separate calls to separate comments
    with a blank line.
  </para>
  <xs:param name="section">
    <para>Used to identify the section.</para>
  </xs:param>
  <xs:param name="gu:runtime">
    <para>Indication in runtime mode so suppress section comments</para>
  </xs:param>
</xs:template>
<xsl:template name="gu:sectionComment">
  <xsl:param name="section" as="xsd:string+"/>
  <xsl:param name="gu:runtime" tunnel="yes" as="xsd:boolean"/>
  <xsl:if test="not($gu:runtime)">
    <xsl:text>
   </xsl:text>
    <xsl:for-each select="$section">
      <xsl:comment> ===== <xsl:value-of select="."/> ===== </xsl:comment>
      <xsl:text>
   </xsl:text>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

<xs:function>
  <para>
    Return true() if the construct defined by the passed row is a construct
    found in the $gu:gcOther input.
  </para>
  <xs:param name="gu:thisBIE">
    <para>The BIE name.</para>
  </xs:param>
</xs:function>
<xsl:function name="gu:isInOtherLibrary" as="xsd:boolean">
  <xsl:param name="gu:thisBIE" as="element(Row)"/>
  <xsl:variable name="gu:thisBIEname" select="gu:col($gu:thisBIE,$gu:names)"/>
  <xsl:choose>
    <xsl:when test="gu:col($gu:thisBIE,'ComponentType')='BBIE'">
      <!--if the construct is a BBIE, simply check all of the same name-->
      <xsl:sequence select="boolean($gu:gcOther/key('gu:bie-by-type','BBIE',.)
                                     [gu:col(.,$gu:names)=$gu:thisBIEname]) "/>
    </xsl:when>
    <xsl:when test="gu:col($gu:thisBIE,'ComponentType')='ASBIE'">
      <!--if the construct is a ASBIE, simply check all of the same name-->
      <xsl:sequence select="boolean($gu:gcOther/key('gu:bie-by-type','ASBIE',.)
                                     [gu:col(.,$gu:names)=$gu:thisBIEname]) "/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="boolean($gu:gcOther/key('gu:bie-by-type','ABIE',.)
                            [gu:col(.,'ModelName')=$gu:otherCommonLibraryModel]
                            [gu:col(.,$gu:names)=$gu:thisBIEname])"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>
</xsl:stylesheet>

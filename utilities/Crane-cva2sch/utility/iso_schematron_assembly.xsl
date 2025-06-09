<?xml version="1.0"?>
<!--
     ISO Schematron assembly script

$Id: iso_schematron_assembly.xsl,v 1.13 2007/07/28 20:10:29 G. Ken Holman Exp $

     Implementation note:  this will interpret only the <include> directive
     of ISO/IEC 19757-3 Schematron, creating a result assembly of the source
     with all included fragments incorporated.

Code List Representation:
     Implemented as part of the OASIS Schematron-based Value Validation Using
     Genericode (check the latest version of the following document in the
     OASIS repository):

     http://www.oasis-open.org/committees/document.php?document_id=24810

Copyright (C) OASIS Open (2006). All Rights Reserved.

This document and translations of it may be copied and furnished to others, and
derivative works that comment on or otherwise explain it or assist in its
implementation may be prepared, copied, published and distributed, in whole or
in part, without restriction of any kind, provided that the above copyright
notice and this paragraph are included on all such copies and derivative works.
However, this document itself may not be modified in any way, such as by
removing the copyright notice or references to OASIS, except as needed for the
purpose of developing OASIS specifications, in which case the procedures for
copyrights defined in the OASIS Intellectual Property Rights document must be
followed, or as required to translate it into languages other than English.

The limited permissions granted above are perpetual and will not be revoked by
OASIS or its successors or assigns.

This document and the information contained herein is provided on an "AS IS"
basis and OASIS DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT
INFRINGE ANY RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE.
-->

<xsl:stylesheet version="1.0" 
	        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	        xmlns:iso="http://purl.oclc.org/dsdl/schematron">

<!--
     Identity transform for constructs that are not the inclusion construct
-->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!--
     Inclusion construct will implement the following from 
     ISO/IEC 19757-3:2006(E):

     5.4.4 include element

     The required href attribute references an external well-formed XML 
     document whose document element is a Schematron element of a type 
     which allowed by the grammar for Schematron at the current position 
     in the schema. The external document is inserted in place of the 
     include element.
-->
<xsl:template match="iso:include">
  <xsl:if test="not(document(@href,.))">
    <xsl:message terminate="yes">
      <xsl:text>Unable to open referenced included file: </xsl:text>
      <xsl:value-of select="@href"/>
    </xsl:message>
  </xsl:if>
  <xsl:apply-templates select="document(@href,.)/iso:*"/>
</xsl:template>

<xsl:template match="iso:include[not(normalize-space(@href))]">
  <xsl:message terminate="yes">
    <xsl:text>Invalid href= attribute for include directive</xsl:text>
  </xsl:message>
</xsl:template>

</xsl:stylesheet>
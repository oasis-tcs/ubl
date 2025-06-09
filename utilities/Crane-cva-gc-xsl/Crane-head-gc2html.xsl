<?xml version="1.0" encoding="US-ASCII"?>
<!--
     This stylesheet illustrates how the output styling is augmented
     by adding content to the HTML <head> element.

     To enable an OASIS genericode file to be rendered in a browser
     with this alternate version of Crane-gc2html.xsl, add the following 
     processing instruction to the start of the file:

     <?xml-stylesheet type="text/xsl" href="Crane-head-gc2html.xsl"?>

     See Crane-gc2html.xsl for more information.

 $Id: Crane-head-gc2html.xsl,v 1.1 2011/04/14 14:15:26 admin Exp $

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
                xmlns="http://www.w3.org/TR/REC-html40"
                version="1.0">

<xsl:import href="Crane-gc2html.xsl"/>

<!--========================================================================-->
<!--all messages separated so they can be overridden in another language-->

<xsl:variable name="z:htmlhead">
  <style type="text/css">
    body { background-color:#DDFFDD }
  </style>
</xsl:variable>

</xsl:stylesheet>
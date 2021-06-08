Crane-mergegc.xsl 20190528-0010z

This is a stylesheet to merge the genericode representation of an OASIS
Business Document NDR 3.0 CCTS model into an existing model, while
accommodating an old version of the existing model.

Where something is new in the merge model, it is added to the result. Where
there is something different in the merge model, the existing model is 
checked against the old model, and if there are no changes between the 
existing and the old, then the merge item is used. If there are changes 
between the existing and the old, and between the merge and the old, a 
conflict is reported and the merge halts.

Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/training-gctk.htm

Portions copyright (C) - OASIS Open 2016. All Rights Reserved.
                       - http://www.oasis-open.org/who/intellectualproperty.php

This documentation and the URI resolution of the XSLT processor both presume
the use of the free Saxon9HE XSLT processor from http://saxon.sf.net ... if
that XSLT 2.0 processor is not being used, then the results may not be as
expected.

Typical invocation (HTML output to standard output):

  java -jar saxon9he.jar {arguments}

Mandatory Invocation arguments (URI's are relative to the input):

 - stylesheet file:             -xsl:Crane-mergegc-obfuscated.xsl
 - input base genericode file   -s:{filename}
 - output merged file           -o:filename
 - old genericode file          +old={filename} or old-uri={filename}
   - a previous version of the base file against which changes are checked
 - merge genericode file        +merge={filename} or merge-uri={filename}
   - the set of changes to make to the base file 

Necessary invocation argument when the common library has exactly one ABIE:

 - specify the model name      common-library-singleton-model-name={string}


Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.


Note: for your reference, the above is the "BSD-3-Clause license"; this text
      was obtained 2017-07-24 at https://opensource.org/licenses/BSD-3-Clause

THE COPYRIGHT HOLDERS MAKE NO REPRESENTATION ABOUT THE SUITABILITY OF THIS
CODE FOR ANY PURPOSE.


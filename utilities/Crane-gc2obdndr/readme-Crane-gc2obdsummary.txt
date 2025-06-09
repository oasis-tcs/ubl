Crane-gc2obdsummary.xsl 20200412-1330z

This is a stylesheet to generate the summary HTML reports of CCTS models.

Copyright (C) - Crane Softwrights Ltd. 
              - http://www.CraneSoftwrights.com/links/res-dev.htm

Portions copyright (C) - OASIS Open. All Rights Reserved.
                       - http://www.oasis-open.org/who/intellectualproperty.php

Typical invocation:

  java -jar saxon9he.jar {arguments}

Mandatory invocation arguments (URIs are relative to input genericode file):

 - stylesheet file:                     -xsl:Crane-gc2obdsummary-obfuscated.xsl
 - input genericode file                -s:{filename}
 - placebo output in target directory   -o:{dir}/junk.out
 - title prefix at report top           title-prefix={string}
 - copyright of final report            copyright-text={string}

Optional invocation arguments (column names have no spaces):

 - time stamp for the package              date-time={string}
 - amalgam report base name                all-documents-base-name={string}
   - when there is more than one document, this is the filename to use for
     the report that combines the members of all documents
 - which profile to report on              subset-column-name={string-no-sp}
 - only minimum subset of all models       subset-result={no(default)/yes}
   - this prunes away items that are never used by any model
 - a particular subset of some models      subset-model-regex={string}
 - a particular subset of some constructs  subset-column-name={string-no-sp}
   - the string value of the column name must have all of the spaces removed
     from the column name in the spreadsheet used to create the genericode file
 - lazy pruning of the model               subset-absent-is-zero=(no(def)/yes)
   - this only applies to items that have a minimum cardinality of 0; to
     preserve the item the original cardinality must be included in the subset
 - document the exclusion of items         subset-exclusions=(yes(default)/no)
 - document only the entire "all" model    do-all-only=(no(default)/yes)
 - reorganize the report                   ABIE-sort-column-name={string-no-sp}
 - supplement the tables with additional   doc-column-names-regex={regex}
   columns from the model
 - abbreviate the tables by removing the   abbreviate-columns=(no(default)/yes)
   detailed CCTS columns

Optional invocation arguments for summaries of extensions (both of which
must exist):

 - genericode file for base vocabulary      base-gc-uri={filename}
 - the summary report of the base model     base-summary-uri={string}
   - use this to link out of an extension summary into the base model summary
 
Necessary invocation argument when the common library has exactly one ABIE:

 - specify the model name          common-library-singleton-model-name={string}

Optional invocation argument to support parallel processing invocation:

 - specify the number of groups    parallel-group-count={integer} (default:0)
 - specify the group number        parallel-group-index={integer} (default:0)

Optional invocation argument to support linking into UBL 2.1-era reports:

 - specify the URI delimiter as    heritage-external-html=(no(default)/yes)
   being the one used in UBL 2.1 HTML reports

IMPLEMENTATION NOTE:

This stylesheet logic does not accommodate qualified object classes.


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


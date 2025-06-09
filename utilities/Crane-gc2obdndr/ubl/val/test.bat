@echo off
call validate.bat ..\xsd\maindoc\UBL-Invoice-2.1.xsd InvoiceExt.xml
call validate.bat ..\xsd\maindoc\UBL-Invoice-2.1.xsd InvoiceExtBad.xml
call validate.bat ..\xsd\mydoc\MyReturnAuthorizationRequest.xsd MyRARequest.xml
call validate.bat ..\xsd\mydoc\MyReturnAuthorizationRequest.xsd MyRARequestBad.xml
call validate.bat ..\xsd\mydoc\MyReturnAuthorizationResponse.xsd MyRAResponse.xml
call validate.bat ..\xsd\mydoc\MyReturnAuthorizationResponse.xsd MyRAResponseBad.xml
call validate.bat ..\xsdrt\maindoc\UBL-Invoice-2.1.xsd InvoiceExt.xml
call validate.bat ..\xsdrt\maindoc\UBL-Invoice-2.1.xsd InvoiceExtBad.xml
call validate.bat ..\xsdrt\mydoc\MyReturnAuthorizationRequest.xsd MyRARequest.xml
call validate.bat ..\xsdrt\mydoc\MyReturnAuthorizationRequest.xsd MyRARequestBad.xml
call validate.bat ..\xsdrt\mydoc\MyReturnAuthorizationResponse.xsd MyRAResponse.xml
call validate.bat ..\xsdrt\mydoc\MyReturnAuthorizationResponse.xsd MyRAResponseBad.xml
rem call validatejson.bat ..\json-schema\maindoc\UBL-Invoice-2.1.json Invoice.json
rem call validatejson.bat ..\json-schema\maindoc\UBL-Invoice-2.1.json InvoiceBad.json

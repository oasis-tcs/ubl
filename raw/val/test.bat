@echo off
call validate ..\xsd\maindoc\UBL-Order-2.3.xsd order-test-bad-syntax.xml
call validate ..\xsd\maindoc\UBL-Order-2.3.xsd order-test-bad-model.xml
call validate ..\xsd\maindoc\UBL-Order-2.3.xsd order-test-bad-code.xml
call validate ..\xsd\maindoc\UBL-Order-2.3.xsd order-test-good.xml

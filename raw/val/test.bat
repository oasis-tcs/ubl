@echo off
set UBLversion=2.5
call validate ..\xsd\maindoc\UBL-Order-%UBLversion%.xsd order-test-bad-syntax.xml
call validate ..\xsd\maindoc\UBL-Order-%UBLversion%.xsd order-test-bad-model.xml
call validate ..\xsd\maindoc\UBL-Order-%UBLversion%.xsd order-test-bad-code.xml
call validate ..\xsd\maindoc\UBL-Order-%UBLversion%.xsd order-test-good.xml

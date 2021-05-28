set UBLversion=2.4
call validatejson  ..\json-schema\maindoc\UBL-Order-%UBLversion%.json order-test-good.json
call validatejson  ..\json-schema\maindoc\UBL-Order-%UBLversion%.json order-test-bad1.json
call validatejson  ..\json-schema\maindoc\UBL-Order-%UBLversion%.json order-test-bad2.json
call validatejson  ..\json-schema\maindoc\UBL-Order-%UBLversion%.json order-test-bad3.json
call validatejson  ..\json-schema\maindoc\UBL-Order-%UBLversion%.json order-test-bad4.json

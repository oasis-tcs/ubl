UBLversion=2.4
sh validatejson.sh ../json-schema/maindoc/UBL-Order-$UBLversion.json order-test-good.json
sh validatejson.sh ../json-schema/maindoc/UBL-Order-$UBLversion.json order-test-bad1.json
sh validatejson.sh ../json-schema/maindoc/UBL-Order-$UBLversion.json order-test-bad2.json
sh validatejson.sh ../json-schema/maindoc/UBL-Order-$UBLversion.json order-test-bad3.json
sh validatejson.sh ../json-schema/maindoc/UBL-Order-$UBLversion.json order-test-bad4.json

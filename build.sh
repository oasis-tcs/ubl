#!/bin/bash

if [ "$5" = "" ]; then echo Missing results directory, platform, label, realta-username, realta-password arguments ; exit 1 ; fi

export targetdir="$1"
export platform=$2
export label=$3

# Configuration parameters

export title="UBL 2.3"
export package=UBL-2.3
export UBLversion=2.3
export UBLstage=cs02
export UBLprevStageVersion=2.3
export UBLprevStage=csd05
export UBLprevVersion=2.2
export rawdir=raw
export includeISO=false

export libGoogle=https://docs.google.com/spreadsheets/d/1eilb2NOKIuiy5kzCpp5O8vbZZk-oU9Ao7TiswJmVsvs
export docGoogle=https://docs.google.com/spreadsheets/d/1_YamjYiJ5DFnWiA5h1tASDCOBTBSOgMYcS5ffHPFa3g
export sigGoogle=https://docs.google.com/spreadsheets/d/1T6z2NZ4mc69YllZOXE5TnT5Ey-FlVtaXN1oQ4AIMp7g

bash build-common.sh "$1" "$2" "$3" "$4" "$5" "$6"

exit 0 # always be successful so that github returns ZIP of results

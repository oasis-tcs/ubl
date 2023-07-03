#!/bin/bash

if [ "$3" = "" ]; then echo Missing results directory, platform, label \(, realta-username, realta-password arguments \) ; exit 1 ; fi

export targetdir="$1"
export platform=$2
export label=$3

# Configuration parameters

export title="UBL 2.4"
export package=UBL-2.4
export UBLversion=2.4
export UBLstage=csd02
export UBLprevStageVersion=2.4
export UBLprevStage=csd01
export UBLprevVersion=2.3
export rawdir=raw
export includeISO=false

export libGoogle=https://docs.google.com/spreadsheets/d/1kxlFLz2thJOlvpq2ChRAcv76SiKgEIRtoVRqsZ7OBUs
export docGoogle=https://docs.google.com/spreadsheets/d/1GNpHCS7_QkJtP3QIOdPJWL5N3kQ1EzPznT6M8sPsA0Y
export sigGoogle=https://docs.google.com/spreadsheets/d/1T6z2NZ4mc69YllZOXE5TnT5Ey-FlVtaXN1oQ4AIMp7g

bash build-common.sh "$1" "$2" "$3" "$4" "$5" "$6"

exit 0 # always be successful so that github returns ZIP of results

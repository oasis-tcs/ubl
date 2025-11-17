#!/bin/bash

if [ ! -d "$targetdir" ]; then mkdir "$targetdir" ; fi
if [ ! -d "$targetdir"/"$package"-"$UBLstage"-"$label" ]; then 
mkdir     "$targetdir"/"$package"-"$UBLstage"-"$label"
fi
if [ ! -d "$targetdir"/"$package"-"$UBLstage"-"$label"/intermediate-support-files/ ]; then 
mkdir     "$targetdir"/"$package"-"$UBLstage"-"$label"/intermediate-support-files/
fi

targetdirabs=$(cd "$targetdir" && pwd)

echo Building package...
java -Dant.home=utilities/ant -classpath "utilities/saxon/saxon.jar:utilities/ant/lib/ant-launcher.jar:utilities/saxon9he/saxon9he.jar" org.apache.tools.ant.launch.Launcher -buildfile build.xml "-Dtitle=$title" "-Dpackage=$package" "-DUBLversion=$UBLversion" "-DUBLprevStageVersion=$UBLprevStageVersion" "-DUBLprevStage=$UBLprevStage" "-DUBLprevVersion=$UBLprevVersion" "-Drawdir=$rawdir" "-DlibraryGoogle=$libGoogle" "-DdocumentsGoogle=$docGoogle" "-DsignatureGoogle=$sigGoogle" "-Ddir=$targetdirabs" "-DUBLstage=$UBLstage" "-Dlabel=$label" "-DisDraft=$isDraft" "-Drealtauser=$4" "-Drealtapass=$5" "-Dplatform=$platform"
serverReturn=$?
sleep 2

if [ ! -d "$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only/ ]; then mkdir "$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only/ ; fi
mv build.console."$label".txt "$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only/
if compgen -G "saxon*.log" > /dev/null; then
  mv saxon*.log "$targetdir/$package-$UBLstage-$label-archive-only/"
fi
echo $serverReturn         >"$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only/build.exitcode."$label".txt
touch                       "$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only/build.console."$label".txt

# reduce GitHub storage costs by zipping results and deleting intermediate files
pushd "$targetdir" || return
if [ -f "$package"-"$UBLstage"-"$label"-archive-only.7z ]; then rm "$package"-"$UBLstage"-"$label"-archive-only.7z ; fi
7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa "$package"-"$UBLstage"-"$label"-archive-only.7z "$package"-"$UBLstage"-"$label"-archive-only
if [ -f "$package"-"$UBLstage"-"$label"-iso-iec-19845.7z ]; then rm "$package"-"$UBLstage"-"$label"-iso-iec-19845.7z ; fi
7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa "$package"-"$UBLstage"-"$label"-iso-iec-19845.7z "$package"-"$UBLstage"-"$label"-iso-iec-19845
if [ -f "$package"-"$UBLstage"-"$label".7z ]; then rm "$package"-"$UBLstage"-"$label".7z ; fi
7z a -t7z -mx=9 -mfb=128 -md=64m -mqs=on -aoa "$package"-"$UBLstage"-"$label".7z "$package"-"$UBLstage"-"$label"
popd || return

if [ "$targetdir" = "target" ]
then
if [ "$platform" = "github" ]
then
if [ "$6" = "DELETE-REPOSITORY-FILES-AS-WELL" ] #secret undocumented failsafe
then
# further reduce GitHub storage costs by deleting repository files

find . -not -name target -not -name .github -maxdepth 1 -exec rm -r -f {} \;

mv "$targetdir"/"$package"-"$UBLstage"-"$label"-archive-only.7z .
mv "$targetdir"/"$package"-"$UBLstage"-"$label"-iso-iec-19845.7z .
mv "$targetdir"/"$package"-"$UBLstage"-"$label".7z .
rm -r -f "$targetdir"

fi
fi
fi

exit 0 # always be successful so that github returns ZIP of results

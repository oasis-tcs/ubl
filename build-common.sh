#!/bin/bash

if [ ! -d $targetdir ]; then mkdir $targetdir ; fi
if [ ! -d $targetdir/$package-$UBLstage-$label ]; then 
mkdir     $targetdir/$package-$UBLstage-$label
fi
if [ ! -d $targetdir/$package-$UBLstage-$label/intermediate-support-files/ ]; then 
mkdir     $targetdir/$package-$UBLstage-$label/intermediate-support-files/
fi

echo Building package...
java -Dant.home=utilities/ant -classpath utilities/saxon/saxon.jar:utilities/ant/lib/ant-launcher.jar:utilities/saxon9he/saxon9he.jar:. org.apache.tools.ant.launch.Launcher -buildfile build.xml "-Dtitle=$title" "-Dpackage=$package" "-DUBLversion=$UBLversion" "-DUBLprevStageVersion=$UBLprevStageVersion" "-DUBLprevStage=$UBLprevStage" "-DUBLprevVersion=$UBLprevVersion" "-Drawdir=$rawdir" "-DlibraryGoogle=$libGoogle" "-DdocumentsGoogle=$docGoogle" "-DsignatureGoogle=$sigGoogle" "-Ddir=$targetdir" "-DUBLstage=$UBLstage" "-Dlabel=$label" "-DisDraft=$isDraft" "-Drealtauser=$4" "-Drealtapass=$5" "-Dplatform=$platform"
serverReturn=$?

sleep 2
if [ ! -d $targetdir/$package-$UBLstage-$label-archive-only/ ]; then mkdir $targetdir/$package-$UBLstage-$label-archive-only/ ; fi
mv build.console.$label.txt $targetdir/$package-$UBLstage-$label-archive-only/
echo $serverReturn         >$targetdir/$package-$UBLstage-$label-archive-only/build.exitcode.$label.txt
touch                       $targetdir/$package-$UBLstage-$label-archive-only/build.console.$label.txt

# reduce GitHub storage costs by zipping results and deleting intermediate files
pushd $targetdir
if [ -f $package-$UBLstage-$label-archive-only.zip ]; then rm $package-$UBLstage-$label-archive-only.zip ; fi
7z a $package-$UBLstage-$label-archive-only.zip $package-$UBLstage-$label-archive-only
if [ -f $package-$UBLstage-$label.zip ]; then rm $package-$UBLstage-$label.zip ; fi
7z a $package-$UBLstage-$label.zip $package-$UBLstage-$label
popd

if [ "$targetdir" = "target" ]
then
if [ "$platform" = "github" ]
then
if [ "$6" = "DELETE-REPOSITORY-FILES-AS-WELL" ] #secret undocumented failsafe
then
# further reduce GitHub storage costs by deleting repository files

find . -not -name target -not -name .github -maxdepth 1 -exec rm -r -f {} \;

mv $targetdir/$package-$UBLstage-$label-archive-only.zip .
mv $targetdir/$package-$UBLstage-$label.zip .
rm -r -f $targetdir

fi
fi
fi

exit 0 # always be successful so that github returns ZIP of results

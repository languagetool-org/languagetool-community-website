#!/bin/bash
# Build LanguageTool core test and copy the JAR to "lib".
# Requires a local checkout of all LanguageTool sources.

CUR_DIR=$(basename $PWD)
if [ $CUR_DIR != 'languagetool-community-website' ]
  then
    echo "Error: please start this script from the 'languagetool-community-website' directory"
    exit
fi

echo "Building and copying latest LanguageTool core test to lib/"

cd ../languagetool
echo "NOTE: will skip tests on build!"
./build.sh languagetool-standalone clean install -DskipTests

cd -

cp ../languagetool/languagetool-standalone/target/LanguageTool-*-SNAPSHOT/LanguageTool-*-SNAPSHOT/libs/languagetool-core-tests.jar lib/

echo "Done - core test JAR has been copied to lib/"

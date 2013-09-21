#!/bin/bash
# Build LanguageTool and copied the JARs etc to "libs".
# Requires a local checkout of all LanguageTool sources.

CUR_DIR=$(basename $PWD)
if [ $CUR_DIR != 'languagetool-community-website' ]
  then
    echo "Error: please start this script from the 'languagetool-community-website' directory"
    exit
fi

echo "Building and copying latest LanguageTool to libs/"

cd ../languagetool
echo "NOTE: will skip tests on build!"
./build.sh languagetool-standalone clean package -DskipTests

cd -

rm -r lib/META-INF
rm -r lib/org

cp -r ../languagetool/languagetool-standalone/target/LanguageTool-*-SNAPSHOT/LanguageTool-*-SNAPSHOT/org/ lib/
cp -r ../languagetool/languagetool-standalone/target/LanguageTool-*-SNAPSHOT/LanguageTool-*-SNAPSHOT/META-INF lib/
cp ../languagetool/languagetool-standalone/target/LanguageTool-*-SNAPSHOT/LanguageTool-*-SNAPSHOT/libs/* lib/

cd ../languagetool
./build.sh languagetool-wikipedia clean package -DskipTests

cd -

cp ../languagetool/languagetool-wikipedia/target/LanguageTool-wikipedia*-SNAPSHOT/LanguageTool-wikipedia*-SNAPSHOT/languagetool-wikipedia.jar lib/
cp ../languagetool/languagetool-wikipedia/target/LanguageTool-wikipedia*-SNAPSHOT/LanguageTool-wikipedia*-SNAPSHOT/libs/* lib/

echo "Done - all JARs etc. have been copied to lib/"

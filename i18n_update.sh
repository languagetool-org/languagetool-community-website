#!/bin/sh
# Download latest community website translations from Transifex and copy them over the existing local files.

# Transifex username and password
USERNAME=dnaber
PASSWORD=fixme

rm -I i18n-temp
mkdir i18n-temp
cd i18n-temp

# list of languages in the same order as on https://www.transifex.com/projects/p/languagetool/:
for lang in en ast be br ca zh da nl eo fr gl de el_GR it pl ru sl es tl uk ro sk cs sv is lt km pt_PT pt_BR
do
  SOURCE=downloaded.tmp
  # download and hackish JSON cleanup:
  curl --user $USERNAME:$PASSWORD https://www.transifex.net/api/2/project/languagetool/resource/community-website/translation/$lang/?file >$SOURCE
  TARGET="../grails-app/i18n/messages_${lang}.properties"
  echo "Moving $SOURCE to $TARGET"
  mv $SOURCE $TARGET
done

cd ..
rm -r i18n-temp

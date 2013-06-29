#/bin/sh
# small helper script for deployment

SERVER=176.28.12.50

grails war
scp -i /home/dnaber/.ssh/openthesaurus target/ltcommunity-0.1.war languagetool@$SERVER:/tmp
ssh -i /home/dnaber/.ssh/openthesaurus languagetool@$SERVER unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war
echo "Now log in to the server and call ./restart-tomcat.sh to activate the update"

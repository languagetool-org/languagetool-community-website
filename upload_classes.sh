#/bin/sh
# small helper script for deployment

#old:
#SERVER=83.169.5.38
#new (August 2012):
SERVER=176.28.12.50

grails war
scp -i /home/dnaber/.ssh/openthesaurus target/ltcommunity-0.1.war languagetool@$SERVER:/tmp
ssh -i /home/dnaber/.ssh/openthesaurus languagetool@$SERVER unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war
ssh -i /home/dnaber/.ssh/openthesaurus languagetool@$SERVER ./restart.sh

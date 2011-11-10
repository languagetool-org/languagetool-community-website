#/bin/sh
# small helper script for deployment

grails war
scp -i /home/dnaber/.ssh/openthesaurus target/ltcommunity-0.1.war languagetool@83.169.5.38:/tmp
ssh -i /home/dnaber/.ssh/openthesaurus languagetool@83.169.5.38 unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war
echo "Now restart Tomcat yourself"

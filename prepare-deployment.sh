#/bin/sh
# small helper script for deployment

echo ""
echo "###"
echo "### This will deploy the code for http://community.languagetool.org ###"
echo "### Admin only - you will need the server password to deploy the code ###"
echo "###"
echo ""
sleep 1

grails war

scp target/ltcommunity-0.1.war languagetool@languagetool.org:/tmp
ssh languagetool@languagetool.org unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war

echo "Now log in to the server and call ./restart-tomcat.sh to activate the update"

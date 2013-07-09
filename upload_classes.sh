#/bin/sh
# small helper script for deployment

echo ""
echo "###"
echo "### Admin only - you will need the server password to deploy the code ###"
echo "### This will deploy the code for http://community.languagetool.org ###"
echo "###"
echo ""
sleep 1

grails war

scp target/ltcommunity-0.1.war languagetool@languagetool.org:/tmp
ssh languagetool@languagetool.org unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war

cd lib
zip -r /tmp/languagetool-not-in-jars.jar META-INF/ org/
scp /tmp/languagetool-not-in-jars.jar languagetool@languagetool.org:tomcat/webapps/ROOT/WEB-INF/lib/
rm /tmp/languagetool-not-in-jars.jar
cd -

echo "Now log in to the server and call ./restart-tomcat.sh to activate the update"

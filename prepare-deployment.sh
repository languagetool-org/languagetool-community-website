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

scp -i ~/.ssh/lt2017 target/ltcommunity-0.1.war languagetool@community:/tmp
ssh -i ~/.ssh/lt2017 root@community unzip -d /home/languagetool/webapps/ROOT/ /tmp/ltcommunity-0.1.war

echo "Now wait for Tomcat to auto-restart (or call 'systemctl restart tomcat9.service' on the server)"

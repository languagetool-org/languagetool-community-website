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

scp -i ~/.ssh/lt2017 target/ltcommunity-0.1.war languagetool@community.languagetool.org:/tmp
ssh -i ~/.ssh/lt2017 languagetool@community.languagetool.org unzip -d /home/languagetool/tomcat/webapps/ROOT/ /tmp/ltcommunity-0.1.war

echo "Now log in to the server and call:"
echo "sh /home/languagetool/languagetool.org/languagetool-website/deploy-jars.sh `date +%Y%m%d` (or with yesterday's date if there's no snapshot for today yet)"
echo " (this will place the latest LT snapshot JARs in WEB-INF/lib)"

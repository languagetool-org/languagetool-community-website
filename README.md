LanguageTool Community Website
==============================

* Visit **[community.languagetool.org](https://community.languagetool.org)**
* Help translate it at [Transifex](https://www.transifex.com/projects/p/languagetool/resource/community-website/).

Dependencies
------------

```bash
mkdir LanguageTool
cd LanguageTool

git clone https://github.com/languagetool-org/languagetool.git
cd languagetool
mvn install
cd ..

git clone https://github.com/languagetool-org/languagetool-community-website.git
cd languagetool-community-website
./update_languagetool.sh
wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.2.4.zip
unzip grails-2.2.4.zip
```

Build
-----

Configure database access by editing `grails-app/conf/DataSource.groovy` in section *production*.

```bash
grails-2.2.4/bin/grails clean
grails-2.2.4/bin/grails compile --refresh-dependencies
grails-2.2.4/bin/grails war
```

Test
----

Configure database access by editing `grails-app/conf/DataSource.groovy` in section *development*.

```bash
grails-2.2.4/bin/grails clean
grails-2.2.4/bin/grails compile --refresh-dependencies
grails-2.2.4/bin/grails run-app
```
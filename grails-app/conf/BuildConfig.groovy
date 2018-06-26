grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.6
grails.project.source.level = 1.6
//grails.project.war.file = "target/${appName}-${appVersion}.war"

grails.project.dependency.resolver = "maven"

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }
    log "error" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve

    repositories {
        inherits true // Whether to inherit repository definitions from plugins
        grailsPlugins()
        grailsHome()
        mavenLocal()
        grailsCentral()
        mavenCentral()

        // uncomment these to enable remote dependency resolution from public Maven repositories
        //mavenCentral()
        //mavenRepo "http://snapshots.repository.codehaus.org"
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"
        //mavenRepo "http://m2.neo4j.org/releases"
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

        runtime('org.languagetool:language-all:4.3-SNAPSHOT') {
            exclude "slf4j-nop"
        }
        runtime 'org.languagetool:languagetool-wikipedia:4.3-SNAPSHOT'
        runtime('org.languagetool:languagetool-http-client:4.3-SNAPSHOT')

        runtime 'mysql:mysql-connector-java:6.0.5'
        runtime 'org.springframework:spring-expression:4.2.0.RELEASE'
    }

    plugins {
        compile ":feeds:1.6"
        runtime ":hibernate:3.6.10.14"
        runtime ':database-migration:1.4.0'
        runtime ':jquery:1.11.0.2'
        runtime ":resources:1.2.8"

        // Uncomment these (or add new ones) to enable additional resources capabilities
        //runtime ":zipped-resources:1.0"
        //runtime ":cached-resources:1.0"
        //runtime ":yui-minify-resources:0.1.4"

        build ":tomcat:7.0.54"
    }
}

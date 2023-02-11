// locations to search for config files that get merged into the main config
// config files can either be Java properties files or ConfigSlurper scripts

// grails.config.locations = [ "classpath:${appName}-config.properties",
//                             "classpath:${appName}-config.groovy",
//                             "file:${userHome}/.grails/${appName}-config.properties",
//                             "file:${userHome}/.grails/${appName}-config.groovy"]

// if(System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

grails.serverURL="https://community.languagetool.org"

wikipedia.summary.link = [ en: '[[LanguageTool]]',
                           de: '[[WP:LanguageTool]]' ]

grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
                      xml: ['text/xml', 'application/xml'],
                      text: 'text-plain',
                      js: 'text/javascript',
                      rss: 'application/rss+xml',
                      atom: 'application/atom+xml',
                      css: 'text/css',
                      csv: 'text/csv',
                      all: '*/*',
                      json: ['application/json','text/json'],
                      form: 'application/x-www-form-urlencoded',
                      multipartForm: 'multipart/form-data'
                    ]
// The default codec used to encode data with ${}
grails.views.default.codec="none" // none, html, base64
grails.views.gsp.encoding="UTF-8"

// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true

// Google ngram data for confusion probability rule:
ngramindex = "/home/languagetool/ngram-data"

// Our API server for text checking:
api.server.url = "https://languagetool.org/api"

max.text.length = 10000     // maximum length of texts to check
// languages not visible in the user interface (e.g. because they are
// not properly supported yet):
hide.languages = ["cs", "ml", "be", "sk", "zh", "ast", "km", "en-GB", "en-US", "en-CA", "en-ZA", "en-NZ", "en-AU",
        "de-DE", "de-AT", "de-CH", "pt-BR", "pt-PT", "pt-AO", "pt-MZ", "ca-ES-valencia", "de-DE-x-simple-language", "sr-BA", "sr-RS", "sr-ME", "sr-HR", "nl-BE",
        "ca-ES-balear", "es-AR"]
// show these languages directly in the navigation bar (not in the drop down):
expose.languages = ["en", "fr", "de", "es", "pl", "ca", "nl", "pt", "es", "ru", "uk"]
maxPatternElements = 5
// the feed of user-suggested words is password protected:
suggestion.password = "fixme"

// Lucene index directories for fast rule matching - "LANG" will be replaced with the language code.
// Use SentenceSourceIndexer to create these indexes (including POS tagging):
fastSearchIndex = "/home/languagetool/corpus/LANG"
fastSearchTimeoutMillis = 15000

// path to grammar.xml with 'XX' as placeholders for language code
//grammarPathTemplate = "/home/dnaber/lt/git/languagetool/languagetool-language-modules/XX/src/main/resources/org/languagetool/rules/XX/grammar.xml"
grammarPathTemplate = "/home/languagetool/languagetool/languagetool-language-modules/XX/src/main/resources/org/languagetool/rules/XX/grammar.xml"

// log4j configuration
log4j = {
    appenders {
        console name: 'stdout', layout: pattern(conversionPattern: '%d{MM/dd HH:mm:ss} %-5p %c %x - %m%n')
        //rollingFile name: 'theLog', file: "/<my_catalina_base_path>/logs/myApp.log", maxFileSize: '100KB'
    }

    root {
        info 'stdout'
        additivity = true
    }
    warn 'org.codehaus.groovy.grails.web.servlet',  //  controllers
         'org.codehaus.groovy.grails.web.pages', //  GSP
         'org.codehaus.groovy.grails.web.sitemesh', //  layouts
         'org.codehaus.groovy.grails."web.mapping.filter', // URL mapping
         'org.codehaus.groovy.grails."web.mapping', // URL mapping
         'org.codehaus.groovy.grails.commons', // core / classloading
         'org.codehaus.groovy.grails.plugins', // plugins
         'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
         'org.springframework',
         'org.hibernate',
         'org.apache.http',
         'org.mortbay.log',
         'org.codehaus.groovy.grails.app',
         'groovyx.net.http',
         'org.codehaus.groovy.grails.plugins.logging.Log4jConfig'

    info 'grails.app'

}

// needed so we don't get Grails complaints about ""We can't create resources on the fly unless ...":
grails.resources.modules = {
    core {
        resource url:'/js/ace/src-min-noconflict/ace.js'
        resource url:'/js/ace/src-min-noconflict/mode-xml.js'
        resource url:'/js/ace/src-min-noconflict/theme-dawn.js'
        resource url:'/js/ace/src-min-noconflict/ext-language_tools.js'
        resource url:'/js/ace/src-min-noconflict/xml.js'
    }
}

// What URL patterns should be processed by the resources plugin:
// Had to specify this to avoid the dreaded "Invocation of <r:resource> for a resource that apparently doesn't exist" error:
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*']
// see http://www.gopivotal.com/security/cve-2014-0053:
grails.resources.adhoc.excludes = ['**/WEB-INF/**','**/META-INF/**']

// Uncomment and edit the following lines to start using Grails encoding & escaping improvements

/* remove this line 
// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'html' // escapes values inside null
                scriptlet = 'none' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        filteringCodecForContentType {
            //'text/html' = 'html'
        }
    }
}
remove this line */

import org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsAnnotationConfiguration

dataSource {
    configClass = GrailsAnnotationConfiguration.class
	pooled = false
	driverClassName = "org.hsqldb.jdbcDriver"
	username = "sa"
	password = ""
}
hibernate {
    cache.use_second_level_cache=true
    cache.use_query_cache=true
    cache.provider_class='org.hibernate.cache.EhCacheProvider'
}
// environment specific settings
environments {
	development {
		dataSource {
		    driverClassName = "com.mysql.jdbc.Driver"
			dbCreate = "update" // one of 'create', 'create-drop','update'
			url = "jdbc:mysql://localhost/ltcommunity?useUnicode=true&characterEncoding=UTF-8"
			username = "root"
			password = ""
		}
	}
	test {
		dataSource {
			dbCreate = "update"
			url = "jdbc:hsqldb:mem:testDb"
		}
	}
	production {
		dataSource {
			driverClassName = "com.mysql.jdbc.Driver"
			dbCreate = "update" // one of 'create', 'create-drop','update'
			url = "jdbc:mysql://tools-db/s52131__ltcommunity?useUnicode=true&characterEncoding=UTF-8"
			username = "s52131"
			password = ""
		}
	}
}

class UrlMappings {
    static mappings = {
      "/" {controller="homepage";action="index"} 
      "/$controller/$action?/$id?"{
	      constraints {
			 // apply constraints here
		  }
	  }
	  "500"(view:'/error')
	}
}

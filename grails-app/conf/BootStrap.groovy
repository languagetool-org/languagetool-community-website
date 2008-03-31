import org.languagetool.*

class BootStrap {

     def init = { servletContext ->
       if (!User.findByUsername("admin")) {
         def saved = new User("admin", "admin").save()
         if (!saved) {
           throw new Exception("could not create admin user")
         }
       }
     }
     def destroy = {
     }
} 
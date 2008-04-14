import org.languagetool.*

class BootStrap {

     def init = { servletContext ->
       if (!User.findByUsername("admin")) {
         User admin = new User("admin", PasswordTools.hash("admin"))
         admin.setRegisterDate(new Date())
         def saved = admin.save()
         if (!saved) {
           throw new Exception("could not create admin user: ${admin.errors}")
         }
       }
     }
     
     def destroy = {
     }
     
}

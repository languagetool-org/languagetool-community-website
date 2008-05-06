package org.languagetool

/**
 * Helper methods to protect pages by login. 
 */
abstract class BaseController {

     def auth() {
         if (!session.user) {
           storeParams()
           redirect(controller:'user', action:'login')
           return false
         }
     }

     def adminAuth() {
         boolean isAdmin = false
         if (!session.user) {
           isAdmin = false
         } else {
           if (session.user.isAdmin) {
             isAdmin = true
           }
         }
         if (!isAdmin) {
           storeParams()
           redirect(controller:'user', action:'login')
           return false
         }
     }

     private void storeParams() {
       def origParams = [controller:controllerName,
                         action:actionName]
       origParams.putAll(params)
       origParams.put("requestMethod", request.method)
       session.origParams = origParams
     }
  
}

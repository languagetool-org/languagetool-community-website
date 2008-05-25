/* LanguageTool Community 
 * Copyright (C) 2008 Daniel Naber (http://www.danielnaber.de)
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 * USA
 */

package org.languagetool

/**
 * Helper methods to protect pages by login. 
 */
abstract class BaseController {

     def auth() {
         if (!session.user) {
           storeParams()
           log.info("user login required for page ${request.getRequestURI()}")
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
           log.info("admin login required for page ${request.getRequestURI()}")
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

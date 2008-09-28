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

import de.danielnaber.languagetool.Language
import javax.mail.*
import javax.mail.internet.*

/**
 * User login, logout, settings, and registration.
 */
class UserController extends BaseController {
    
    def beforeInterceptor = [action: this.&adminAuth, except:
      ['login', 'logout', 'register', 'doRegister', 'completeRegistration', 'settings',
       'exportRules']]

    // the delete, save and update actions only accept POST requests
    def allowedMethods = [delete:'POST', save:'POST', update:'POST',
                          doRegister:'POST']

    def index = {
        redirect(action:list,params:params)
    }
    
    def register = {
    }

    /**
     * Export a user's personal rules as XML.
     */
    def exportRules = {
        if (!session.user) {
          throw new Exception("you need to be logged in")
        }
        User user = session.user
        List userRules = UserRule.findAllByUser(user)
        if (userRules.size() == 0) {
          flash.message = "You don't have any personal rules yet"
          redirect(controller:'rule', action:'list')
        }
        StringBuilder sb = new StringBuilder()
        String langCode = userRules.get(0).lang
        sb.append('<?xml version="1.0" encoding="UTF-8"?>\n')
        sb.append("<!-- Personal LanguageTool rules exported " +
            "from http://community.languagetool.org on ${new Date()} -->\n")
        sb.append("<rules lang=\"${langCode}\">\n")
        for (userRule in userRules) {
          sb.append(userRule.toPatternRule(true).toXML())
          sb.append("\n")
        }
        sb.append("</rules>\n")
        String langName = Language.getLanguageForShortName(langCode).getName()
        response.setHeader("Content-Disposition",
            "attachment; filename=rules-${langCode}-${langName}.xml")
        render(text:sb.toString(), contentType: "text/xml")
    }
    
    def doRegister = {
        String toAddress = params.email
        if (!toAddress) {
          flash.message = "No email address set"
          render(view:'register',model:[params:params])
          return
        }
        String passwordErrorMsg = checkNewPassword()
        if (passwordErrorMsg) {
          flash.message = passwordErrorMsg
          render(view:'register', model:[params:params])
          return
        }
        if (User.findByUsername(toAddress)) {
          // TODO: show as a real error message
          flash.message = "That email address is alread in use"
          render(view:'register',model:[params:params])
          return
        }
        User newUser = new User(toAddress, PasswordTools.hash(params.password1))
        // Note: user is not activated until we set registerDate
        boolean saved = newUser.save()
        if (!saved) {
          throw new Exception("Could not save user: ${user.errors}")
        }
        String secret = grailsApplication.config.registration.ticket.secret
        assert(secret && secret != "" && secret != "{}")
        RegistrationTicket ticket = new RegistrationTicket(newUser, secret)
        saved = ticket.save()
        if (!saved) {
          throw new Exception("Could not generate registration ticket: ${ticker.errors}")
        }
        log.info("Created user: ${newUser.username}, id=${newUser.id}")
        sendRegistrationMail(toAddress, ticket)
        flash.message = ""
    }

    private String checkNewPassword() {
        if (!params.password1 || !params.password2) {
          return "No password set"
        }
        if (params.password1 != params.password2) {
          return "Passwords don't match"
        }
        if (params.password1.size() < grailsApplication.config.registration.min.password.length) {
          return "Password is too short, minimum length is " +
            "${grailsApplication.config.registration.min.password.length}"
        }
        return null
    }
    
    private void sendRegistrationMail(String toAddress, RegistrationTicket ticket) {
        Properties props = new Properties()
        log.info("Preparing registration mail to $toAddress")
        String smtpHost = grailsApplication.config.smtp.host
        String smtpUsername = grailsApplication.config.smtp.user
        String smtpPassword = grailsApplication.config.smtp.password
        props.put("mail.from", grailsApplication.config.registration.mail.from)
        props.put("mail.smtp.auth", true)
        Session session = Session.getInstance(props, null)
        MimeMessage msg = new MimeMessage(session)
        msg.setFrom()
        msg.setRecipients(Message.RecipientType.TO, toAddress)
        msg.setSubject(grailsApplication.config.registration.mail.subject)
        msg.setSentDate(new Date())
        msg.setText(grailsApplication.config.registration.mail.text.
            replaceAll("#CODE#", ticket.getTicketCode()).
            replaceAll("#USERID#", ticket.user.id + ""))
        msg.saveChanges()
        Transport tr = session.getTransport("smtp")
        tr.connect(smtpHost, smtpUsername, smtpPassword);
        tr.sendMessage(msg, msg.getAllRecipients())
        tr.close()
        log.info("Mail sent to $toAddress")
    }

    /**
     * This is the controller that the registration email points to
     */
    def completeRegistration = {
        if (!params.code || !params.id) {
          throw new Exception("No ticket code and/or ID is specified")
        }
        User user = User.get(params.id)
        if (!user) {
          throw new Exception("Your user account could not be found: ${params.id.encodeAsHTML()}")
        }
        RegistrationTicket ticket = RegistrationTicket.findByTicketCodeAndUser(params.code, user)
        // TODO: check for age of ticket!
        if (!ticket) {
          throw new Exception("Your registration ticket for id ${params.id.encodeAsHTML()} is not valid")
        }
        user.setRegisterDate(new Date())
    }
    
    def settings = {
        if (!session.user) {
          throw new Exception("You need to be logged in to edit your settings")
        }
        if (request.method == 'GET') {
          [user: session.user]
        } else if (request.method == 'POST') {
          log.info("User ${session.user} changing his/her password")
          String passwordErrorMsg = checkNewPassword()
          if (passwordErrorMsg) {
            flash.message = passwordErrorMsg
            render(view:'settings', model:[params:params])
            return
          }
          def saved = session.user.save()
          session.user.password = PasswordTools.hash(params.password1)
          if (!saved) {
            throw new Exception("Could not save settings: ${session.user.errors}")
          }
          flash.message = "Password changed"
        } else {
          throw new Exception("unsupported method ${request.method}")
        }
    }
    
    def login = {
        if (request.method == 'GET') {
          // show login page
          session.user = null
          if (params.controllerName && params.actionName) {
              session.controllerName = params.controllerName
              session.actionName = params.actionName
          }
          User user = new User()
        } else {
          User user = User.findByUsername(params.email)
          if (user) {
            String hashedPassword = user.password
            if (!PasswordTools.checkPassword(params.password, hashedPassword)) {
              loginFailed("login failed for '${params.email}' (${request.getRemoteAddr()}): password invalid")
              return
            }
            if (!user.registerDate) {
              loginFailed("login failed for '${params.email}' (${request.getRemoteAddr()}): account not activated")
              return
            }
            log.info("login successful for user ${user} (${request.getRemoteAddr()})")
            session.user = user
            user.lastLoginDate = new Date()
            def redirectParams = 
              session.origParams ? session.origParams : [uri:"/"]
            log.info("session.requestMethod="+redirectParams)
            if (params.ids && params.lang) {
                // user wants to vote on an error found by LanguageTool:
                redirect(controller:'homepage', params:[ids:params.ids,lang:params.lang])
            } else if (redirectParams?.controller && redirectParams?.action) {
                redirect(controller:redirectParams?.controller,
                        action: redirectParams?.action, params:redirectParams)
            } else if (session.controllerName && session.actionName) {
                redirect(controller:session.controllerName,
                        action: session.actionName)
            } else {
                redirect(uri:request.getContextPath()+"/")        // got to homepage
            }
          } else {
            loginFailed("login failed for '${params.email}' (${request.getRemoteAddr()}): user not found")
          }
        }
    }
    
    private void loginFailed(String internalMsg) {
      log.warn(internalMsg)
      flash.message = message(code:'ltc.login.invalid')
    }
    
    def logout = {
        log.info("logout of user ${session.user}")
        session.user = null
        session.controllerName = null
        session.actionName = null
        flash.message = "Successfully logged out"
        redirect(uri:"")
    }
    
    def list = {
        if(!params.max) params.max = 10
        [ userList: User.list( params ) ]
    }

    def delete = {
        User user = User.get( params.id )
        if(user) {
            log.info("Deleting user ${user.username}")
            user.delete()
            flash.message = "User ${params.id} deleted"
            redirect(action:list)
        }
        else {
            flash.message = "User not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        User user = User.get( params.id )

        if(!user) {
            flash.message = "User not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ user : user ]
        }
    }

    def update = {
        User user = User.get( params.id )
        if(user) {
            user.properties = params
            if(!user.hasErrors() && user.save()) {
                log.info("Updted user ${user.username}")
                flash.message = "User ${params.id} updated"
                redirect(action:edit,id:user.id)
            }
            else {
                render(view:'edit',model:[user:user])
            }
        }
        else {
            flash.message = "User not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        User user = new User()
        user.properties = params
        return ['user':user]
    }

    def save = {
        User user = new User(params)
        if(!user.hasErrors() && user.save()) {
            flash.message = "User ${user.id} created"
            log.info("User ${user.username} created")
            redirect(action:edit,id:user.id)
        }
        else {
            render(view:'create',model:[user:user])
        }
    }
}
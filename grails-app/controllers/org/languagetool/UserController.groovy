package org.languagetool

import javax.mail.*
import javax.mail.internet.*

class UserController extends BaseController {
    
    def beforeInterceptor = [action: this.&adminAuth, except:
      ['login', 'logout', 'register', 'doRegister', 'completeRegistration']]

    // the delete, save and update actions only accept POST requests
    def allowedMethods = [delete:'POST', save:'POST', update:'POST',
                          doRegister:'POST']

    def index = {
        redirect(action:list,params:params)
    }
    
    def register = {
    }

    def doRegister = {
        String toAddress = params.email
        if (!toAddress) {
          throw new Exception("No email address set")
        }
        if (!params.password1 || !params.password2) {
          throw new Exception("No password set")
        }
        if (params.password1 != params.password2) {
          throw new Exception("Passwords don't match")
        }
        // TODO: config password length
        if (params.password1.size() <= 3) {
          throw new Exception("Password is too short")
        }
        User newUser = new User(toAddress, PasswordTools.hash(params.password1))
        // Note: user is not activated until we set registerDate
        boolean saved = newUser.save()
        if (!saved) {
          throw new Exception("Could not save user: ${user.errors}")
        }
        RegistrationTicket ticket = new RegistrationTicket(newUser)
        saved = ticket.save()
        if (!saved) {
          throw new Exception("Could not generate registration ticket: ${ticker.errors}")
        }
        log.info("Created user: ${newUser.username}, id=${newUser.id}")
        sendRegistrationMail(toAddress, ticket)
    }
    
    private sendRegistrationMail(String toAddress, RegistrationTicket ticket) {
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
              loginFailed()
              return
            }
            log.info("login successful for user ${user}")
            session.user = user
            user.lastLoginDate = new Date()
            def redirectParams = 
              session.origParams ? session.origParams : [uri:"/"]
            log.info("session.requestMethod="+redirectParams)
            if (redirectParams?.controller && redirectParams?.action) {
                redirect(controller:redirectParams?.controller,
                        action: redirectParams?.action, params:redirectParams)
            } else if (session.controllerName && session.actionName) {
                redirect(controller:session.controllerName,
                        action: session.actionName)
            } else {
                redirect(uri:"")        // got to homepage
            }
          } else {
            loginFailed()
          }
        }
    }
    
    private void loginFailed() {
      log.warn("login failed for user '${params.email}' (${request.getRemoteAddr()})")
      flash.message = "Invalid email address and/or password. " +
        "Please also make sure cookies are enabled."
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
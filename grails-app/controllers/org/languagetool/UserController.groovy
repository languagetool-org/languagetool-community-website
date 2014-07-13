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

import javax.servlet.http.Cookie

/**
 * User login, logout, settings, and registration.
 */
class UserController extends BaseController {

    public static final String LOGIN_COOKIE_NAME = "loginCookie"
    
    private static final int LOGIN_COOKIE_AGE = (60*60*24*365)/2   // half a year

    def beforeInterceptor = [action: this.&adminAuth, except:
            ['login', 'logout', 'register', 'doRegister', 'completeRegistration', 'settings',
                    'exportRules']]

    // the delete, save and update actions only accept POST requests
    def static allowedMethods = [delete:'POST', save:'POST', update:'POST',
            doRegister:'POST', settings:['POST', 'GET']]

    /*
    do not allow any new registrations - 2014-07-13
    def register = {
    }*/

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
        sb.append("<category name=\"User Rules from community.languagetool.org\">\n")
        for (userRule in userRules) {
            sb.append(userRule.toPatternRule(true).toXML())
            sb.append("\n")
        }
        sb.append("</category>\n")
        sb.append("</rules>\n")
        String langName = Language.getLanguageForShortName(langCode).getName()
        response.setHeader("Content-Disposition",
                "attachment; filename=rules-${langCode}-${langName}.xml")
        render(text:sb.toString(), contentType: "text/xml")
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
            if (params.controllerName && params.actionName) {
                session.controllerName = params.controllerName
                session.actionName = params.actionName
            }
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
                if (params.logincookie) {
                    addDurationSession(session, response, user)
                }
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
        cleanCookie(response, LOGIN_COOKIE_NAME)
        flash.message = "Successfully logged out"
        redirect(uri:"")
    }

    private void cleanCookie(def response, String cookieName) {
        Cookie[] cookies = request.getCookies()
        for (cookie in cookies) {
            if (cookie.getName() == cookieName) {
                cookie.setMaxAge(0)		// effectively deletes the cookie
                cookie.setPath("/")
                response.addCookie(cookie)
                break
            }
        }
    }

    private void addDurationSession(def session, def response, User user) {
        Cookie loginCookie = new Cookie(LOGIN_COOKIE_NAME, session.id)
        loginCookie.setMaxAge(LOGIN_COOKIE_AGE)
        loginCookie.setPath("/")
        response.addCookie(loginCookie)
        DurationSession dSession = new DurationSession(sessionId:session.id, user:user, insertDate:new Date())
        if (!dSession.save()) {
            throw new Exception("could not save duration session: ${dSession.errors}")
        }
    }
}
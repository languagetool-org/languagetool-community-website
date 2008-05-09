
<%@ page import="org.languagetool.User" %>
<html>
    <head>
        <meta name="layout" content="main" />
        <title>Edit Your User Settings</title>
    </head>
    <body>
        <div class="body">
            <h1>Edit Your User Settings</h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${user}">
            <div class="errors">
                <g:renderErrors bean="${user}" as="list" />
            </div>
            </g:hasErrors>
            <g:form controller="user" method="post" action="settings">
                <input type="hidden" name="id" value="${user?.id}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="description">New password:</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:user,field:'password1','errors')}">
                                    <input type="password" name="password1" id="description" value="${fieldValue(bean:user,field:'password1')}" />
                                </td>
                            </tr> 
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                    <label for="description">New password (repeat):</label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean:user,field:'password2','errors')}">
                                    <input type="password" name="password2" id="description" value="${fieldValue(bean:user,field:'password2')}" />
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <span class="button"><g:actionSubmit class="save" value="Update" /></span>
            </g:form>
        </div>
    </body>
</html>

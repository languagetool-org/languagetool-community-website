<%@page import="org.languagetool.tools.StringTools" %>

<html>
    <head>
        <meta name="layout" content="login" />
        <title><g:message code="ltc.login.title"/></title>         
    </head>
    <body>

        <div class="body">
            
            <h1><g:message code="ltc.login.title"/></h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${user}">
            <div class="errors">
                <g:renderErrors bean="${user}" as="list" />
            </div>
            </g:hasErrors>
            <g:form action="login" method="post" name="loginform">
            
                <g:if test="${params.ids}">
                    <input type="hidden" name="ids" value="${StringTools.escapeHTML(StringTools.listToString(Arrays.asList(params.ids), ','))}"/>
                </g:if>
                <g:if test="${params.lang}">
                    <input type="hidden" name="lang" value="${params.lang?.encodeAsHTML()}"/>
                </g:if>
                
                <div class="dialog">
                
                    <table>
                        <tbody>

                            <!--
                            <tr class='prop'>
                                <td valign='top' colspan="1" class='name'>
                                    <p><g:message code="ltc.login.no.account"/> <g:link action="register"><g:message code="ltc.login.register.here" /></g:link></p>
                                </td>
                            </tr>
                            -->
                                                    
                            <tr class='prop'>
                                <td valign='top' class='name'>
                                    <label for='email'><g:message code="ltc.login.email"/></label>
                                </td>
                                <td valign='top' class='value'>
                                    <input size="40" type="text" id='email' name='email' value="${params.email?.encodeAsHTML()}"/>
                                </td>
                            </tr> 
                        
                            <tr class='prop'>
                                <td valign='top' class='name'>
                                    <label for='password'><g:message code="ltc.login.password"/></label>
                                </td>
                                <td valign='top' class='value'>
                                    <input size="40" type="password" id='password' name='password' value=""/>
                                </td>
                            </tr> 
                        
                            <tr class='prop'>
                                <td></td>
                                <td valign='top' class='value'>
                                    <label><input type="checkbox" name='logincookie' />&nbsp;<g:message code="ltc.login.keep"/></label>
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                
                <g:actionSubmit action="login" value="${message(code:'ltc.login.button')}"/>
                
            </g:form>
        </div>
        
        <script type="text/javascript">
        <!--
            document.loginform.email.focus();
        // -->
        </script>
        
    </body>
</html>

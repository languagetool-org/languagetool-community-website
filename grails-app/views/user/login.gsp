<%@page import="de.danielnaber.languagetool.tools.StringTools" %>

<html>
    <head>
        <meta name="layout" content="login" />
        <title>Login</title>         
    </head>
    <body>

        <div class="body">
            <h1>Login</h1>
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
                <input type="hidden" name="lang" value="${params.lang?.encodeAsHTML()}"/>
                
                <div class="dialog">
                
                    <table>
                        <tbody>

                            <tr class='prop'>
                                <td valign='top' colspan="1" class='name'>
                                    <p>No Account yet? <g:link action="register">Register here</g:link></p>
                                </td>
                            </tr>
                                                    
                            <tr class='prop'>
                                <td valign='top' class='name'>
                                    <label for='email'>Email:</label>
                                </td>
                                <td valign='top' class='value'>
                                    <input size="40" type="text" id='email' name='email' value="${params.email?.encodeAsHTML()}"/>
                                </td>
                            </tr> 
                        
                            <tr class='prop'>
                                <td valign='top' class='name'>
                                    <label for='password'>Password:</label>
                                </td>
                                <td valign='top' class='value'>
                                    <input size="40" type="password" id='password' name='password' value=""/>
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                
                <g:actionSubmit action="login" value="Login"/>
                
            </g:form>
        </div>
        
        <script type="text/javascript">
        <!--
            document.loginform.email.focus();
        // -->
        </script>
        
    </body>
</html>

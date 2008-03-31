  
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="login" />
        <title>Register</title>         
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
            <g:form action="doRegister" method="post" name="loginform">
                <div class="dialog">
                
                    <table>
                        <tbody>
                        
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
                                    <input size="40" type="password" id='password1' name='password1' value=""/>
                                </td>
                            </tr> 

                            <tr class='prop'>
                                <td valign='top' class='name'>
                                    <label for='password'>Password (repeat):</label>
                                </td>
                                <td valign='top' class='value'>
                                    <input size="40" type="password" id='password2' name='password2' value=""/>
                                </td>
                            </tr> 
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><input class="login" type="submit" value="Register"></input></span>
                </div>
            </g:form>
        </div>
        
        <script type="text/javascript">
        <!--
            document.loginform.email.focus();
        // -->
        </script>
        
    </body>
</html>

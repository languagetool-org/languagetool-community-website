  
<html>
    <head>
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
                
                <g:actionSubmit action="login" value="Register"/>
                
            </g:form>
        </div>
        
        <script type="text/javascript">
        <!--
            document.loginform.email.focus();
        // -->
        </script>
        
    </body>
</html>

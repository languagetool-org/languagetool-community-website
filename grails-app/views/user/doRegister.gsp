  
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="login" />
        <title>Registration</title>         
    </head>
    <body>

        <div class="body">
            
            <h1>Registration</h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

                <div class="dialog">
                
	                An email has been sent to your email address. Please follow
	                the link in the email to activate your account.
                
                </div>
        
    </body>
</html>

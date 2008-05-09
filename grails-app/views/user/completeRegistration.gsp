  
<html>
    <head>
        <meta name="layout" content="login" />
        <title>Registration Completed</title>         
    </head>
    <body>

        <div class="body">
            
            <h1>Registration Completed</h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

                <div class="dialog">

                    Thank you, your registration has been completed.<br />
                    You can now <g:link controller="user" action="login">log in</g:link>                
                
                </div>
        
    </body>
</html>

  
<html>
    <head>
        <meta name="layout" content="login" />
        <title><g:message code="ltc.registration.done.title"/></title>         
    </head>
    <body>

        <div class="body">
            
            <h1><g:message code="ltc.registration.done.title"/></h1>
            
            <g:if test="${flash.message}">
                <div class="message">${flash.message}</div>
            </g:if>

                <div class="dialog">
                
                	<g:message code="ltc.registration.done.text1"/><br />
                	<g:link controller="user" action="login"><g:message code="ltc.registration.done.text2"/></g:link>
                
                </div>
        
    </body>
</html>

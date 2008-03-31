<html>
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${createLinkTo(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <g:layoutHead />
        <g:javascript library="application" />				
    </head>
    <body>
    
        <g:if test="${session.user}">
            <div class="login">Logged in as ${session.user.username.encodeAsHTML()} -
            <g:link controller="user" action="logout">Logout</g:link></div>
        </g:if>
        <g:else>
            <div class="login"><g:link controller="user" action="login">Login</g:link></div>
        </g:else>
        
        <div id="spinner" class="spinner" style="display:none;">
            <img src="${createLinkTo(dir:'images',file:'spinner.gif')}" alt="Spinner" />
        </div>	
        <g:layoutBody />		
    </body>	
</html>
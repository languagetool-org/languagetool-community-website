<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link type="text/css" rel="stylesheet" href="${createLinkTo(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${createLinkTo(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <g:layoutHead />
        <g:javascript library="application" />
    </head>
    <body>

        <div class="header">&nbsp;

			<%
			String homeLink = request.getContextPath();
			if (homeLink.equals("")) {
			  homeLink = "/";
			}
			if (params.lang) {
			  homeLink += "?lang=" + params.lang;
			}
			%>
	        <h1 class="logo"><g:link url="${homeLink}">LanguageTool Community <sup>beta</sup></g:link></h1>
	    
	        <g:if test="${session.user}">
	            <div class="login">Logged in as ${session.user.username.encodeAsHTML()} -
	            <g:link controller="user" action="logout">Logout</g:link>
	            -
	            <g:link controller="user" action="settings">My Settings</g:link>
	            </div>
	        </g:if>
	        <g:else>
	            <div class="login"><g:link controller="user" action="login">Login</g:link></div>
	        </g:else>

        </div>
        
        <div id="spinner" class="spinner" style="display:none;">
            <img src="${createLinkTo(dir:'images',file:'spinner.gif')}" alt="Spinner" />
        </div>	
        <g:layoutBody />		
    </body>	
</html>
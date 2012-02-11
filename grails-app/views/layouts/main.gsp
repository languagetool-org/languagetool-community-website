<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><g:layoutTitle default="Grails" /></title>
        <link type="text/css" rel="stylesheet" href="${resource(dir:'css',file:'main.css')}" />
        <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" />
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
            <table style="border: 0px">
            <tr>
                <td valign="top">
                    <h1 class="logo"><g:link url="${homeLink}"><g:message code="ltc.title"/></g:link></h1>

           	        <h3 class="sublogo"><g:message code="ltc.subtitle"/></h3>
                </td>
                <td valign="top">
                    <g:if test="${session.user}">
           	            <div class="login"><g:message code="ltc.logged.in" args="${[session.user.username.encodeAsHTML()]}"/> -
           	            <g:link controller="user" action="logout"><g:message code="ltc.logout"/></g:link>
           	            -
           	            <g:link controller="user" action="settings"><g:message code="ltc.settings"/></g:link>
           	            </div>
           	        </g:if>
           	        <g:else>
           	            <div class="login"><g:link controller="user" action="login"><g:message code="ltc.login"/></g:link></div>
           	        </g:else>
                </td>
            </tr>
            </table>

        </div>
        
        <div id="spinner" class="spinner" style="display:none;">
            <img src="${resource(dir:'images',file:'spinner.gif')}" alt="Spinner" />
        </div>

        <div id="mainContent">
            <g:layoutBody />
        </div>

    </body>	
</html>
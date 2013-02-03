<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>${language} <g:message code="ltc.home.title"/></title>
		<meta name="layout" content="main" />
		<g:javascript library="prototype" />
    </head>
    <body>

        <div class="body">

        <g:render template="/languageSelection"/>

        <div class="dialog">
            
            <p style="margin-bottom: 15px"><g:message code="ltc.home.intro"/></p>

            <h2><g:link controller="wikiCheck"><g:message code="ltc.wiki.check"/></g:link></h2>


            <br />
            <h2><g:message code="ltc.run.languagetool"/></h2>

            <div class="mainPart">

            <g:form method="post">
                <input type="hidden" name="lang" value="${params.lang?.encodeAsHTML()}"/>
            
                <g:textArea name="text" value="${textToCheck}" rows="5" cols="80" />
                <br />
                <g:actionSubmit action="checkText" value="${message(code:'ltc.home.check.text')}"/>
                
            </g:form>
            
            <g:if test="${!session.user}">
            	<g:message code="ltc.login.to.configure"/>
            </g:if>
            
            </div>


            <br />
            <h2><g:link controller="rule" action="list" params="[lang: params.lang?.encodeAsHTML()]"><g:message code="ltc.browse.rules"/></g:link></h2>
            
            <div class="mainPart">
            	<g:message code="ltc.browse.explain"/>
            </div>


            <br />
            <h2><g:message code="ltc.check.results"/></h2>
            
            <div class="mainPart">
            
            <p><g:message code="ltc.check.explain"/></p>
            
            <p><g:message code="ltc.check.random.selection"/></p>
            
            <br/>
            <g:render template="/corpusMatches"/>
            
            </div>

            <br />

            <div class="lthomepage">
            	<g:message code="ltc.home.links"/>
            </div>
                   
        </div>

        </div>
        
    </body>
</html>
<g:form name="text" style="margin-bottom: 10px; margin-top: 8px" action="analyzeText" method="post">
    <g:hiddenField name="lang" value="${language.shortName}"/>
    <g:textArea name="text" rows="5" cols="70" maxlength="1000" autofocus="autofocus" value="${textToCheck}" />
    <br/>
    <g:submitButton name="submit" value="${message(code:'ltc.analysis.submit')}"/>
    <span class="metaInfo"><g:message code="ltc.analysis.submit.hint"/></span>
</g:form>

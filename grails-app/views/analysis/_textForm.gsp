<g:form name="text" style="margin-bottom: 10px; margin-top: 8px" action="analyzeText" method="post">
    <g:hiddenField name="lang" value="${language.shortCode}"/>
    <g:textArea style="width:100%" lang="${language.shortCode}" name="text" rows="5" maxlength="1000" autofocus="autofocus" 
                value="${textToCheck}" placeholder="${message(code:'ltc.analysis.placeholder')}"/>
    <br/>
    <g:submitButton name="submit" value="${message(code:'ltc.analysis.submit')}"/>
    <span class="metaInfo"><g:message code="ltc.analysis.submit.hint"/></span>
</g:form>

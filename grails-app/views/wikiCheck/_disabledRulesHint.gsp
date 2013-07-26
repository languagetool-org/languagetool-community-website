<g:set var="allRulesActive" value="${disabledRuleIds.size() == 1 && 'none'.equals(disabledRuleIds.get(0))}"/>
<g:if test="${!allRulesActive}">
    <div style="color:#555555;">
        <g:message code="ltc.wikicheck.rules.intro"/>
        <a style="color: #555555" href="javascript:toggleId('disabledRuleInfo');"><g:message code="ltc.wikicheck.rules.details"/></a>
        <div id="disabledRuleInfo" style="margin-top: 5px; display: none;color:#444444;">
            <g:message code="ltc.wikicheck.rules.message"/>
            <g:each in="${disabledRuleIds}" var="ruleId" status="i">
                <g:if test="${i > 0}">
                    &middot;
                </g:if>
                <a style="color:#444444;font-weight:normal" href="http://community.languagetool.org/rule/show/${ruleId.encodeAsURL()}?lang=${lang.encodeAsHTML()}">${ruleId.encodeAsHTML()}</a>
            </g:each>
            <div style="margin-top: 5px">
                <g:message code="ltc.wikicheck.rules.activate.all.link" args="${['?url=' + realUrl + '&amp;lang='+ params.lang + '&amp;disabled=none']}"/>
            </div>
        </div>
    </div>
</g:if>

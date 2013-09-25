
<div class="langselection">
    <g:each var="lang" in="${languages}">
        <g:set var="languagesToHide" value="${grailsApplication.config.hide.languages}"/>
        <g:if test="${!languagesToHide.contains(lang.shortNameWithVariant) && !languagesToHide.contains(lang.shortName)}">
            <g:if test="${params.lang == lang.shortName}">
                <span class="languageButton"><span class="activelang">${lang.getName()}</span></span>
            </g:if>
            <g:else>
                <span class="languageButton"><g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link></span>
            </g:else>
        </g:if>
    </g:each>
</div>


<div class="langselection">

    <g:set var="languagesToHide" value="${grailsApplication.config.hide.languages}"/>
    <g:set var="languagesToExpose" value="${grailsApplication.config.expose.languages}"/>
    
    <g:each var="lang" in="${languages}">
        <g:if test="${languagesToExpose.contains(lang.shortCode) && !languagesToHide.contains(lang.getShortCodeWithCountryAndVariant()) && !languagesToHide.contains(lang.shortCode)}">
            <g:if test="${params.lang == lang.shortCode}">
                <span class="languageButton"><span class="activelang">${lang.getName()}</span></span>
            </g:if>
            <g:else>
                <span class="languageButton"><g:link params="[lang:lang.getShortCode()]">${lang.getName()}</g:link></span>
            </g:else>
        </g:if>
    </g:each>
    <select name="lang" style="margin-top: 0; background: #94c324;font-weight: bold" onchange="if (selectedIndex > 0) { window.location.search='lang='+this.options[this.selectedIndex].value }">
        <option><g:message code="ltc.more.languages"/></option>
        <g:each var="lang" in="${languages}">
            <g:if test="${!languagesToExpose.contains(lang.shortCode) && !languagesToHide.contains(lang.getShortCodeWithCountryAndVariant()) && !languagesToHide.contains(lang.shortCode)}">
                <g:set var="selectionSnippet" value="${lang.getShortCode() == params.lang ? '' : ''}"/>
                <g:if test="${lang.getShortCode() == params.lang}">
                    <g:set var="selectionSnippet" value="selected='selected'"/>
                </g:if>
                <g:else>
                    <g:set var="selectionSnippet" value=""/>
                </g:else>
                <option ${selectionSnippet} value="${lang.getShortCode()}">${lang.getName()}</option>
            </g:if>
        </g:each>
    </select>

</div>

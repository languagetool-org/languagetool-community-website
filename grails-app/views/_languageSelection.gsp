
<div class="langselection">

    <g:set var="languagesToHide" value="${grailsApplication.config.hide.languages}"/>
    <g:set var="languagesToExpose" value="${grailsApplication.config.expose.languages}"/>
    
    <table style="border: none">
    <tr>
        <td>
            <g:each var="lang" in="${languages}">
                <g:if test="${languagesToExpose.contains(lang.shortName) && !languagesToHide.contains(lang.getShortNameWithCountryAndVariant()) && !languagesToHide.contains(lang.shortName)}">
                    <g:if test="${params.lang == lang.shortName}">
                        <span class="languageButton"><span class="activelang">${lang.getName()}</span></span>
                    </g:if>
                    <g:else>
                        <span class="languageButton"><g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link></span>
                    </g:else>
                </g:if>
            </g:each>
            <select name="lang" style="margin-top: 0; background: #94c324;font-weight: bold" onchange="if (selectedIndex > 0) { window.location.search='lang='+this.options[this.selectedIndex].value }">
                <option><g:message code="ltc.more.languages"/></option>
                <g:each var="lang" in="${languages}">
                    <g:if test="${!languagesToExpose.contains(lang.shortName) && !languagesToHide.contains(lang.getShortNameWithCountryAndVariant()) && !languagesToHide.contains(lang.shortName)}">
                        <g:set var="selectionSnippet" value="${lang.getShortName() == params.lang ? '' : ''}"/>
                        <g:if test="${lang.getShortName() == params.lang}">
                            <g:set var="selectionSnippet" value="selected='selected'"/>
                        </g:if>
                        <g:else>
                            <g:set var="selectionSnippet" value=""/>
                        </g:else>
                        <option ${selectionSnippet} value="${lang.getShortName()}">${lang.getName()}</option>
                    </g:if>
                </g:each>
            </select>
        </td>
    </tr>
    </table>

</div>

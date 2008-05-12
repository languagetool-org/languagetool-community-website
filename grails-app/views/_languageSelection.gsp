            <br/>
            <g:each var="lang" in="${languages}">
                <g:if test="${!grailsApplication.config.hide.languages.contains(lang.shortName)}">
	                <span class="languageButton">
	                <g:if test="${params.lang == lang.shortName}">
	                    ${lang.getName()}
	                </g:if>
	                <g:else>
	                    <g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link>
	                </g:else>
	                </span>     
                </g:if>
            </g:each>
            <br/><br/>


            <div class="langselection">
            <g:each var="lang" in="${languages}">
                <g:if test="${!grailsApplication.config.hide.languages.contains(lang.shortName)}">
	                <span class="languageButton">
	                <g:if test="${params.lang == lang.shortName}">
	                    <span class="activelang">${lang.getName()}</span>
	                </g:if>
	                <g:else>
	                    <g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link>
	                </g:else>
	                </span>     
                </g:if>
            </g:each>
            </div>

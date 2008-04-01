            <br/>
            <g:each var="lang" in="${languages}">
                <span class="languageButton">
                <g:if test="${params.lang == lang.shortName}">
                    ${lang.getName()}
                </g:if>
                <g:else>
                    <g:link params="[lang:lang.getShortName()]">${lang.getName()}</g:link>
                </g:else>
                </span>     
            </g:each>
            <br/><br/>

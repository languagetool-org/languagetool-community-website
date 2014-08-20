<g:if test="${language && language.getName() == 'Persian'}">
    <link type="text/css" rel="stylesheet" href="${resource(dir:'css',file:'main-rtl.css')}" />
</g:if>
<g:else>
    <link type="text/css" rel="stylesheet" href="${resource(dir:'css',file:'main.css')}" />
</g:else>

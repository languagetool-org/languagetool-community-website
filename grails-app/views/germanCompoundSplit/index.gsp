<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
    <head>
        <title>German Compound Split</title>
        <meta name="layout" content="main" />
    </head>
    <body>

        <div class="body">

        <div class="dialog">

            <h1>German Compound Split</h1>
            
            <form method="post" action="split">
                <textarea autofocus name="input" style="width:300px;height:200px">${input}</textarea>
                <br>
                <input type="submit" value="Komposita trennen">
            </form>
            
        </div>
            
        <g:if test="${splits}">
            <br>
            <h3>Ergebnis</h3>
            <br>
            <g:each in="${splits}" var="split">
                ${split}<br>
            </g:each>
        </g:if>

        </div>
        
    </body>
</html>
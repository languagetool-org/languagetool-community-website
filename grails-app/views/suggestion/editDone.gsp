<%@page import="org.languagetool.*" %>
<%@page import="org.hibernate.*" %>

<html>
<head>
    <title>Admin: Users' spelling suggestions</title>
    <meta name="layout" content="main" />
</head>
<body>

<div class="body">

    <div class="dialog">

        <h1>Admin: Users' spelling suggestions</h1>
        
        <p>Check these and add them to <tt>spelling.txt</tt>:</p>

        <textarea style="width:500px; height:600px">${result}</textarea>
        
    </div>

</div>

</body>
</html>

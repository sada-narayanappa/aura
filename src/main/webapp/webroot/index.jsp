<%@include file="include1.jsp" %>

<%
    debug = false;
    debug (out,"Executing command: " + cmd);

    int pfx = cmd.indexOf(".");
    if (pfx <= 0) {
        out.print("No Command given " + cmd + " see examples/ sub directory");
        return;
    }
    String fwdJSP=cmd.substring(0,pfx+1) + "jsp";
%>
<jsp:forward page="<%=fwdJSP%>" />
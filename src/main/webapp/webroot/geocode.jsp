<%@ page import="java.sql.*" %>
<%@include file="include1.jsp" %>
<%@include file="properties.jsp" %>

<%
    try{
        String q = (String) getParam("q", request, "");
        q = q.replaceAll(" ", "+");

        return;
    }
    catch (Exception ex) {
        out.print("Exception: "+ ex.getMessage() + " " + ex);
    }

%>
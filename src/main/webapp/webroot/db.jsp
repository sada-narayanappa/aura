<%@include file="include1.jsp" %>
<%@include file="dbproperties.jsp" %>

<%!
    public void jspInit() {
        DBInit();
    }
%>
<%
    cmd = (String) getParam("cmd", request, "");
    cmd=cmd.trim().toLowerCase();
    if ( cmd.equals("reload")) {
        readSQLHash();
        out.print( "HASH reloaded" );
        return;
    }
    String type = (String) getParam("type", request, "");

    String qry = "";
    try{
        String  q1 = "SELECT * FROM test LIMIT 100";
        qry = (String) getParam("q", request, q1);
        String  qtemp = qry.toUpperCase();
        if (qtemp.contains("DELETE") ) {
            out.print( "DELETE is not allowed!!" );
            return;
        }
        String qnu = (String) getParam("qn", request, null);

        if (qnu != null) {
            String qry1 = getSQLHash(qnu, request.getParameterMap());
            if (qry1 != null) {
                qry = qry1;
            }
        }
        log( "Executing: " + qnu + " "  + qry );
        StringBuilder sbn = ResultToJson(qry);

        if ( type.equalsIgnoreCase("html")) {
            out.println("<pre> " + " Executing: " + qnu + "\n"  + qry + "\n\n" + sbn);
        } else {
            out.print( sbn );
        }
        return;
    }
    catch (Exception ex) {
        out.print("SQLException: "+ ex.getMessage() + " " + ex.fillInStackTrace() + " " + qry);
        LOG.error(ex);
    }
%>


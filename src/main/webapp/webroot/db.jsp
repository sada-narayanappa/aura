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
        ClearCache();
        out.print("HASH reloaded\n\n");
        log("Reloading SQL text");
        return;
    }
    String type = (String) getParam("type", request, "");

    String qry = "";
    String useCache = "";
    try{
        String  q1 = "SELECT * FROM test LIMIT 100";
        qry   = (String) getParam("q", request, q1);
        useCache = (String) getParam("c", request, null);
        if (useCache != null )  {
            log("NOT USING CACHE AND WILL NOT CACHE THIS RESULT");
        }
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

        StringBuilder sbn = (StringBuilder) GetCache().get(qry);
        if ( sbn == null || useCache != null ) {
            sbn = ResultToJson(qry);
            GetCache().put(qry, sbn);
        }
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


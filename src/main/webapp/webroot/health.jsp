<%@ page import="geospaces.TextFile" %>
<%@ page import="java.nio.file.Files" %>
<%@include file="include1.jsp" %>

<%!
    StringBuilder sb = new StringBuilder(256);
    private static String [] ids = {
       "timeRecorded", "id", "ver","lat", "lon", "veloc", "htype", "hstore"
    };
    TextFile csv = null;
    String   contextPath = "";

    public void jspInit() {
        if (csv != null )
            return;

        csv = new TextFile("HEALTH.txt", ids);

    }

%>
<%
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();
    boolean returnText = (getParam("returnType", request, "").equals("text"));

    if (!returnText) {
        csv.getStringJSONMulti(request, sb);
        out.print(sb);

        if ( apiKey.length() > 0) {
            csv.write(sb);
        }
        //else {
        //    sb.append("\n// NOT LOGGED");
        //}
        //out.println("\n // Headers: " + csv.getHeader() );
    }
%>


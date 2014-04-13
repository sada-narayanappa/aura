<%@ page import="geospaces.TextFile" %>
<%@include file="include1.jsp" %>

<%!
    private static String [] ids = {
      "timeRecorded", "id", "ver","lat", "lon", "veloc", "temperature",
      "humidity", "O3","NO2", "val"
    };
    TextFile csv = null;
    String   contextPath = "";

    public void jspInit() {
        if (csv != null )
            return;

        ServletConfig config = getServletConfig();
        csv = new TextFile("ENV.txt", ids);

    }
%>
<%
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();
    StringBuilder sb = new StringBuilder(256);

    csv.getString(request, sb);

    if ( apiKey.length() > 0) {
        csv.write(sb);
    } else {
        sb.append(" : NOT LOGGED");
    }
    out.println("<pre> " + csv.getHeader() );
    out.print(sb);

%>

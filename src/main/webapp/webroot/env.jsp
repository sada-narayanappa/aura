<%@ page import="geospaces.TextFile" %>
<%@include file="include1.jsp" %>

<%!
    StringBuilder sb = new StringBuilder(512);
    private static String [] ids = {
      "timeRecorded", "id", "ver","lat", "lon", "veloc", "temperature",
      "humidity", "O3","NO2", "hstore"
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
    boolean returnText = (getParam("returnType", request, "").equals("text"));
    String  text =  getParam("text", request, "").toString();

    if ( !text.equals("") ) {
        csv.getStringJSONMulti(request, sb, null);
    } else {
        csv.getStringJSON(request, sb);
    }
    out.print(sb);

    if ( apiKey.length() > 0) {
        csv.write(sb);
    }
    //else {
    //    sb.append("\n// NOT LOGGED");
    //}
    //out.println("\n // Headers: " + csv.getHeader() );

%>



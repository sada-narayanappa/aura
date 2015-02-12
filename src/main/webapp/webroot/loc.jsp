<%@ page import="geospaces.TextFile" %>
<%@include file="include1.jsp" %>
<%@include file="dbproperties.jsp" %>

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
        csv = new TextFile("LOC.txt", ids);
        DBInit();
    }
%>
<%
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();
    boolean returnText = (getParam("returnType", request, "").equals("text"));
    String  text =  getParam("text", request, "").toString();

    if ( !text.equals("") ) {
        csv.getStringJSONMulti(request, sb);
    } else {
        csv.getStringJSON(request, sb);
    }

    StringBuilder sbn = null;
    if ( apiKey.length() > 0) {
        csv.write(sb);
        HashMap map = new HashMap();
        for (Object o : request.getParameterMap().keySet()) {
            map.put(o, ((Object[])request.getParameterMap().get(o))[0]);
        }
        map.put("caller_ip", request.getRemoteAddr());

        String qry1 = getSQLHash("2", map);
        sbn = ResultToJson(qry1);
    }
    out.print("<pre>" + sb + "<br/>" + sbn);
    //else {
    //    sb.append("\n// NOT LOGGED");
    //}
    //out.println("\n // Headers: " + csv.getHeader() );

%>



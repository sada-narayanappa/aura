<%@ page import="geospaces.TextFile" %>
<%@ page import="java.awt.event.*" %>
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

    public void InsertIntoDB(Map map) {
        Object o = map.get("api_key");
        if (  o == null) {
            return;
        }
        String qry1 = getSQLHash("2", map);
        StringBuilder sbn = ResultToJson(qry1);
        log(qry1, sbn);
        log("CLEARING Cache after insert", "now");
        ClearCache();
    }

    ActionListener  insertDB = new ActionListener(){
        public void actionPerformed(ActionEvent e) {
            Map map = (Map)e.getSource();
            InsertIntoDB(map);
        }
    };
%>
<%
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();
    String  text =  getParam("text", request, "").toString();

    try {
        dumpRequest(out, request);
    } catch(Exception e) {
        out.print(e);
    }



    if ( !text.equals("") ) {
        csv.getStringJSONMulti(request, sb, insertDB);
    } else {
        csv.getStringJSON(request, sb);
    }

    StringBuilder sbn = null;
    if ( apiKey.length() > 0) {
        out.print("api_key: " + apiKey);
        csv.write(sb);
        if ( text.equals("") ) {
            HashMap map = new HashMap();
            for (Object o : request.getParameterMap().keySet()) {
                map.put(o, ((Object[]) request.getParameterMap().get(o))[0]);
            }
            InsertIntoDB(map);
        }
    }
    out.print("<pre>" + sb + "<br/>" + sbn);
    //else {
    //    sb.append("\n// NOT LOGGED");
    //}
    //out.println("\n // Headers: " + csv.getHeader() );
%>



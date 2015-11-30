<%@ page import="geospaces.TextFile" %>
<%@ page import="java.awt.event.*" %>
<%@include file="include1.jsp" %>
<%@include file="dbproperties.jsp" %>

<%!

    public void help(JspWriter out) {
        try{
            out.println("Show Help");
        } catch(Exception e) {

        }
    }
%>
<%
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();
    cmd =  getParam("cmd", request, "").toString();

    if ( cmd.equals("help")) {
        //print help
    }

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



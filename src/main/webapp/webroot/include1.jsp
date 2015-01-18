<%@ page import="org.apache.log4j.*" %>
<%@ page import="org.apache.commons.lang.time.StopWatch" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.servlet.jsp.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Path" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.io.IOException" %>
<%@ page import="geospaces.TextFile" %>

<%!
    boolean     debug   = false;

    public void debugln(JspWriter pageOut, Object ... args){
        debug(pageOut, args);
        debug(pageOut, "\n");
    }
    public void debug(JspWriter pageOut, Object ... args){
        if (!debug || null == pageOut)
            return;

        for (Object o :  args) {
            try{
                pageOut.print(o);
            } catch(Exception e) {
                ;
            }
        }

    }
    //Get Cookies
    //Get Session Data
    //Get Authentication
    //Get Authorization
    protected final static Log LOG = LogFactory.getLog("gsws");

    public static void setCache(HttpServletResponse response, int d) {
        response.setHeader("Cache-Control", "public, max-age=" + d);
        response.setDateHeader("Expires", System.currentTimeMillis() + (d * 1000L));
        response.setDateHeader("Last-Modified", System.currentTimeMillis());
    }
    public static void setNoCache(HttpServletResponse response) {
        response.setHeader("Expires", "0");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
    }
    public static char getType(Object o) {
        char ret = 's';

        if (o instanceof String|| o instanceof StringBuffer|| o instanceof StringBuilder) {
            ret = 's';
        } else if (o instanceof Integer|| o instanceof Long || o instanceof Short ||
                o instanceof Byte || o instanceof Character) {
            ret = 'i';
        } else if (o instanceof Double || o instanceof Float || o instanceof Number) {
            ret = 'd';
        }
        return ret;
    }
    public static Object getParam(String n, HttpServletRequest r, Object def) {
        String p = r.getParameter(n);
        if (p == null)
            return def;

        char t = getType(def);
        Object ret = def;

        try {
            switch (t) {
                case 'd':
                    ret = Double.parseDouble(p);
                    break;
                case 'i':
                    ret = Integer.parseInt(p);
                    break;
                default:
                case 's':
                    ret = p.toString();
                    break;
            }
        } catch (NumberFormatException ne) {
            LOG.error("Format Exception: param=" + n + " Value=" + p, ne);
        }  catch (Exception ne) {
            LOG.error("Exception: param=" + n + " Value=" + p, ne);
        }
        return ret;
    }
    public static void dumpRequest(JspWriter pageOut, HttpServletRequest request) throws Exception {
        if (null == pageOut) {
            return;
        }
        String reqUrl = request.getRequestURL().toString();
        String queryString = request.getQueryString();   // d=789
        if (queryString != null) {
            reqUrl += "?"+queryString;
        }

        pageOut.println("<pre>REQUEST Params: size=" + request.getParameterMap().size() + "{");
        StringBuilder sb = new StringBuilder(128);
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            String n = (String) e.nextElement();
            sb.append( n + "=" + request.getParameter(n) + "\n");
        }

        pageOut.println(sb + "\n}" + reqUrl + "<pre>");
    }

    boolean initialized = false;
    protected void globalInit() {
        if ( initialized)
            return;
    }
%>
<%
    String qu = request.getQueryString();
    qu = (qu == null) ? "" : qu;
    if (qu.endsWith("undefined")) {
        qu = qu.substring(0, qu.length() - "undefined".length());
    }
    {
        char dc = ((String) getParam("debug", request, "f")).toLowerCase().charAt(0);
        debug = ( dc == '1' || dc == 'y' || dc =='t');
    }
    String cmd = (String) getParam("cmd", request, "");
    cmd=cmd.trim().toLowerCase();

    boolean isGet = (request.getMethod().toLowerCase().startsWith("post"));
    // **** VERSION NUMBER service *****
    //---- SERVICE: No Parameters: returns Version Number ------------
    //
    if ( isGet && (request.getParameterMap().size() <= 0 || cmd.equals("version")) ) {
        out.println("VERSION 1.0");
        out.println("\n\n\n<BR/><BR><HR/><pre>"+
        "see <a href=http://www.geospaces.org/geodata/Wiki.jsp?page=Aura>Page on geospaces<a> for more info"
        );
        return;
    }
    // **** TEST service *****
    // Returns all the parameters of the service - echos back to user
    //
    if ( cmd.equals("test")) {
        out.println( "Query String: " + qu + " <br/>");
        out.println(request.getRequestURL() + " <br/>");

        String jver = System.getProperty("java.version");
        out.println("Java version: " + jver );
        float jverf = Float.parseFloat(jver.substring(0,3));
        if (jverf < 1.7) {
            out.println("<br/><br/>** STOP ** Java version 1.7 " + jverf +
            "<br/><color=red><b> You are running older version</b></color><br/><br/>"
            );
        }

        dumpRequest(out, request);
        return;
    }

//    String[] tl = TextFile.tail("/tmp/SCH/ENV1.txt");
//    out.print("<br/> GOT " + tl.length + " lines <pre>");
//    for (String p : tl){
//        out.println(p);
//    }
//    out.print("<pre>");

%>
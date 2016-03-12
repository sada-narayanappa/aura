<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.servlet.jsp.*" %>
<%@ page import="java.io.File" %>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="java.nio.file.Path" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.nio.charset.*" %>

<%@ page import="org.apache.commons.logging.*" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory.*" %>
<%@ page import="org.apache.commons.lang.time.StopWatch" %>
<%@ page import="org.apache.commons.logging.Log.*" %>
<%@ page import="org.apache.commons.lang.time.StopWatch.*" %>

<%@ page import="java.sql.*" %>

<%
    System.out.println("RESUTLS BELOW==>\n") ;
    byte[] theByteArray;
    theByteArray = (" HAHS " + "日本語       " ).getBytes("UTF-8");
    System.out.println(new String(theByteArray, Charset.forName("UTF-8")));
    System.out.println(new String(theByteArray, Charset.forName("UTF-8")));
%>

<%
    StringBuffer sb = new StringBuffer();
    sb.append("日本語 أدخل سعر الافتتاح <br/>");
    out.println("日本語  <br/>" );
    out.println(sb );
%>
<%
    String dbuser    = "postgres";
    String dbpasswd  = "postgres";
    String dbDriver  = "org.postgresql.Driver";
    String dburl1    = "jdbc:postgresql://localhost:5432/SCHASDB";
    String dburl2    = "jdbc:postgresql://52.25.152.209:5432/SCHASDB?charSet=UTF-8";
    String dburl     = dburl2;
    String qry      = "SELECT userid, fname FROM users where userid <=2";

    Class.forName(dbDriver).newInstance();
    Connection conn = null;

    conn = DriverManager.getConnection(dburl, dbuser, dbpasswd);

    System.out.println("SQL:" + qry);
    try{
        ResultSet   rs   = null;
        PreparedStatement stmt = conn.prepareStatement(qry);
        boolean rv = stmt.execute();

        if (rv) {
            rs = stmt.getResultSet();
            ResultSetMetaData meta = rs.getMetaData();
            int columnCount = meta.getColumnCount();

            int row = 1;
            while (rs.next()) {
                Object d;
                for (int i = 1; i <= columnCount; i++) {
                    d = rs.getObject(i);
                    out.println(d + "<br/>" );
                }
            }
        }
    }
    catch (Exception ex) {
        System.out.println(ex);
    }
    finally{
        if ( conn !=null) {
            try {
                conn.close();
            } catch(Exception e1) {
                System.out.println(e1);
            }
        }
    }
%>

<br/>This is simple JSP and this 日本語

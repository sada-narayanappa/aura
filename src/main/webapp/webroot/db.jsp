<%@ page import="java.sql.*" %>
<%@include file="include1.jsp" %>
<%@include file="dbproperties.jsp" %>

<%!
    public Connection getConnection() throws Exception {
        Class.forName(dbDriver).newInstance();
        Connection conn = null;
        conn = DriverManager.getConnection(dburl, dbuser, dbpasswd);
        return conn;
    }
    public Object getObject(ResultSet rs, ResultSetMetaData meta, int i ) throws Exception{
        String ret = "";
        String c2 = meta.getColumnTypeName(i).toLowerCase();
        int    rt = meta.getColumnType(i);

        if ( (c2.indexOf("bit") >=0)    || (c2.indexOf("int") >=0)   || (c2.indexOf("float")>=0) ||
             (c2.indexOf("numeric")>=0)  || (c2.indexOf("double")>=0) || (c2.indexOf("real")>=0)  ||
                (c2.indexOf("decimal")>=0)) {
            return rs.getObject(i);
        }
        ret = "\"" + rs.getObject(i) + "\"";
        return ret;
    }

    public StringBuilder ResultMeta(ResultSet rs) throws Exception{
        StringBuilder ret1 = new StringBuilder("colnames: [");
        StringBuilder ret2 = new StringBuilder("coltypes: [");
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();

        for (int i=1; i <= columnCount; i++) {
            String c1 = meta.getColumnName(i);
            String c2 = meta.getColumnTypeName(i);
            ret1.append((i>1 ?",":"") + '"' + c1 + '"' );
            ret2.append((i>1 ?",":"") + '"' + c2 + '"');
        }

        ret1.append("],\n").append(ret2).append("]");
        return ret1;
    }
    public StringBuilder ResultToJson(String qry, Object... args){
        Connection  conn = null;
        try{
            conn = getConnection();
            ResultSet   rs   = null;
            PreparedStatement stmt = conn.prepareStatement(qry);
            rs = stmt.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int columnCount = meta.getColumnCount();
            StringBuilder retM = ResultMeta(rs);

            StringBuilder ret = new StringBuilder("var $rs={rows:[\n");
            int row = 1;
            while(rs.next()) {
                ret.append("[");
                Object d;
                for (int i=1; i <= columnCount; i++) {
                    d =getObject(rs, meta, i);
                    ret.append ( ((i >1) ? ",": "") + d ) ;
                }
                ret.append("],\n");
            }
            ret.append("],\n");
            ret.append(retM);
            ret.append("}");
            return ret;
        }
        catch (Exception ex)
        {
            return new StringBuilder("{SQLException: " + ex.getMessage() +"}");
        }
        finally{
            if ( conn !=null) {
                try {
                    conn.close();
                } catch(Exception e1) {
                    ;
                }
            }
        }
    }
%>

<%
    try{
        String  q1 = "SELECT * FROM test LIMIT 100";
        String qry = (String) getParam("q", request, q1);
        StringBuilder sbn = ResultToJson(qry);
        out.print( sbn );
        return;
    }
    catch (Exception ex) {
        out.print("SQLException: "+ ex.getMessage() + " " + ex);
    }

%>


<%@ page import="java.sql.*" %>
<%@ page import="java.nio.charset.*" %>
<%@ page import="java.util.regex.*" %><%!
    String dbuser   = "postgres";
    String dbpasswd = "postgres";
    String dbDriver = "org.postgresql.Driver";
    String dburl    ="jdbc:postgresql://localhost:5432/SCHASDB";

    static HashMap SQL_HASH     = new HashMap();

    public void readSQLHash() {
        String text = null;
        try{
            String fileName = "/opt/SCHAS/sql/SQL.txt";
            text = new String(Files.readAllBytes(Paths.get(fileName)), StandardCharsets.UTF_8);
        } catch (Exception e) {
            LOG.error("Error: " + e);
        }

        String ntext = text.replaceAll("(?m)^[ \t]*\r?\n", "");
        String[] sqls = ntext.split("#--*\n");

        for (String l: sqls){
            int idx = l.indexOf("\n");
            String id  = l.substring(0, idx );
            String sql = l.substring(idx + 1);
            SQL_HASH.put(id, sql.trim());
        }
        for (Object id: SQL_HASH.keySet()) {
            log(id + " : " + SQL_HASH.get(id));
        }
    }
    public static String getSQLHash(String q, Map map) {
        String qry1 = (String) SQL_HASH.get(q);
        if (qry1 != null) {
            qry1 = getSQL(qry1, map);
        }
        return qry1;
    }
    public static String getSQL(String q, Map map) {
        if ( q.indexOf("$") < 0) {
            return q;
        }
        String nq = q;

        Pattern pat = Pattern.compile("\\$\\w*");
        Matcher m = pat.matcher(q);


        boolean updateStmt = q.toLowerCase().trim().startsWith("update");

        while ( m.find()) {
            String p = m.group();
            String v = (String)map.get(p.substring(1));
            if ( updateStmt ) {
                nq = nq.replace(p, p.substring(1));
            } else {
                String k = (v == null) ? "null" : "'" + v + "'";
                nq = nq.replace(p, k);
            }
        }
        //log(nq);
        return nq;
    }

    public static void log(Object o) { System.out.println(o); }

    // initialization code or something needs to be called before JSP page
    // starts serving the requests.
    public void jspInit() {
        LOG.info("In jspInit of dbproperties");
        if ( SQL_HASH.size() > 0 ) {
            return;
        }
        readSQLHash();
    }

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

    public StringBuilder ResultSetToJson(ResultSet rs) throws Exception{
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();
        StringBuilder retM = ResultMeta(rs);

        StringBuilder ret = new StringBuilder("var $rs={rows:[\n");
        int row = 1;
        while (rs.next()) {
            ret.append("[");
            Object d;
            for (int i = 1; i <= columnCount; i++) {
                d = getObject(rs, meta, i);
                ret.append(((i > 1) ? "," : "") + d);
            }
            ret.append("],\n");
        }
        ret.append("],\n");
        ret.append(retM);
        ret.append("}");
        return ret;
    }

    public StringBuilder ResultToJson(String qry, Object... args){
        Connection  conn = null;
        try{
            StringBuilder ret = null;
            conn = getConnection();
            ResultSet   rs   = null;
            PreparedStatement stmt = conn.prepareStatement(qry);
            boolean rv = stmt.execute();

            if (rv) {
                rs = stmt.getResultSet();
                ret = ResultSetToJson(rs);
            } else {
                ret = new StringBuilder(""+ stmt.getUpdateCount() + "Were affected");
            }
            return ret;
        }
        catch (Exception ex)
        {
            return new StringBuilder("{SQLException: " + ex.getMessage() +"}" + " " +qry);
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
%>
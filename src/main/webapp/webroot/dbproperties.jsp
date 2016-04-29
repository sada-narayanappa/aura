<%@ page import="java.sql.*" %>
<%@ page import="java.nio.charset.*" %>
<%@ page import="java.util.regex.*" %>
<%!
    String dbuser    = "postgres";
    String dbpasswd  = "postgres";
    String dbDriver  = "org.postgresql.Driver";
    String dburl1    = "jdbc:postgresql://localhost:5432/SCHASDB?charSet=UTF-8";
    String dburl2    = "jdbc:postgresql://52.25.152.209:5432/SCHASDB?charSet=UTF-8";
    String dburl21   = "jdbc:postgresql://52.25.152.209:5432/SCHASDB";
    String dburl3    = "jdbc:postgresql://smartconnectedhealth.org:5432/SCHASDB?charSet=UTF-8";
    String dburl     = dburl1;

    HashMap SQL_HASH         = new HashMap();

    public void readSQLHash() {
        SQL_HASH.clear();
        String text = null;
        try{
            String fileName = "/opt/SCHAS/data/sql/SQL.txt";
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
    public String getSQLHash(String q, Map map) {
        String qry1 = (String) SQL_HASH.get(q);
        if (qry1 != null) {
            qry1 = getSQL(qry1, map);
        }
        return qry1;
    }

    static Pattern pat = Pattern.compile("\\$\\w*");
    public static String getSQL(String q, Map map) {
        if ( q.indexOf("$") < 0) {
            return q;
        }
        String nq = q;

        Matcher m = pat.matcher(q);
        boolean insertStmt = q.toLowerCase().trim().startsWith("insert");

        while ( m.find()) {
            String p = m.group();
            Object   k = map.get(p.substring(1));
            String   v = null;
            if ( k != null) {
                v = (k instanceof String) ? (String)k : ((String[])k)[0];
            }
            if ( !insertStmt ) {
                String k1 = ( v== null) ? p.substring(1): "'" + v + "'";
                nq = nq.replace(p, k1);
            } else {
                String k1 = (v == null) ? "null" : "'" + v + "'";
                nq = nq.replace(p, k1);
            }
        }
        //log(nq);
        return nq;
    }

    public static void log(Object o) { System.out.println(o); }

    // initialization code or something needs to be called before JSP page
    // starts serving the requests.
    public void DBInit() {
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
        String str = ""+rs.getObject(i);
        str=str.replaceAll("\"", "\\\\\"");
        ret = "\"" + str  + "\"";
        return ret;
    }

    public StringBuilder ResultMeta(ResultSet rs) throws Exception{
        StringBuilder ret1 = new StringBuilder("\"colnames\": [");
        StringBuilder ret2 = new StringBuilder("\"coltypes\": [");
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

        StringBuilder ret = new StringBuilder("var $rs=\n{\"rows\":[\n");
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
        log("SQL:" + qry);
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
                ret = new StringBuilder(""+ stmt.getUpdateCount() + " row(s) affected");
            }
            return ret;
        }
        catch (Exception ex) {
            log(ex);
            return new StringBuilder("{SQLException: " + ex.getMessage() +"}" + " " +qry);
        }
        finally{
            if ( conn !=null) {
                try {
                    conn.close();
                } catch(Exception e1) {
                    log(e1);
                }
            }
        }
    }
%>

<%
%>
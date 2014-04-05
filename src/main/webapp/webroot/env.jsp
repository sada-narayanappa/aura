<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.File" %>
<%@include file="include1.jsp" %>
<%@include file="future/properties.jsp" %>

<%!
    private static long   MAX_FILE_SIZE = 1024 * 1024 * 10; // 10 Meg

    private static String fileLocation = "/tmp/HEALTH/";
    private static String fileENV = fileLocation + "/ENV.csv";
    private static String fileHLT = fileLocation + "/HEALTH.csv";

    private static String [] idENV = {
      "id", "dtype", "lat", "lon", "alt", "direction", "time", "temperature",
       "humidity", "smoke"
    };
    //
    // htype = {MEDICATION, PEAKFlow, Attack }
    private static String [] idHEALTH = {
        "id", "dtype", "lat", "lon", "alt", "direction", "time", "htype",
    };
    private static String fileENVHeader = "";
    private static String fileHLTHeader = "";


    FileOutputStream ostreamENV = null;
    FileOutputStream ostreamHLT = null;

    private long remainingBytesENV = MAX_FILE_SIZE;
    private long remainingBytesHLT = MAX_FILE_SIZE;

    private FileOutputStream openFile(String fileName, FileOutputStream ostream) {
        try{
            if (ostream != null ) {
                return ostream;
            } else {
                ostream = new FileOutputStream(fileName, true);
            }
        }catch (Exception e) {
            LOG.error("Error during opening file " + e);
        }

        return ostream;
    }

    protected void initFiles() {
        File dir = new File(fileLocation);
        dir.mkdirs();

        ostreamENV = openFile(fileENV, ostreamENV);
        ostreamHLT = openFile(fileHLT, ostreamHLT);
        fileENVHeader = "unix time|\tGMT Time|\t";
        fileHLTHeader = fileENVHeader;
        for (String p: idENV) {
            fileENVHeader += p + "|\t";
        }
        for (String p: idHEALTH) {
            fileHLTHeader += p + "|\t";
        }
    }
    private void closeFiles() {
        try{
            if (ostreamENV != null) {
                ostreamENV.close();
            }
        } catch (Exception e) {
            LOG.error("Error During CLosing ENV File" + e);
        }
        finally {
            ostreamENV = null;
        }
        try{
            if (ostreamHLT != null) {
                ostreamHLT.close();
            }
        } catch (Exception e) {
            LOG.error("Error During CLosing HLT File" + e);
        }
        finally {
            ostreamHLT = null;
        }
    }

    protected void writeToHealth(StringBuilder sb) {
        FileOutputStream os = ostreamHLT;
        try {
            os.write(sb.toString().getBytes(), 0 , sb.length());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    protected void writeToEnv(StringBuilder sb) {
        FileOutputStream os = ostreamENV;
        try {
            os.write(sb.toString().getBytes(), 0 , sb.length());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    //
    // returns local time and String
    protected String getTime() {
        String ret;
        Calendar cal = Calendar.getInstance();
        long time = cal.getTimeInMillis();
        SimpleDateFormat fmt = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss:SS");
        fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

        ret = time/1000 + "\t" + fmt.format(time);
        return ret;
    }
    //
    // return 0 for environmental type (default)
    //        1 for health type
    //       -1 for error
    private int getString(HttpServletRequest request, StringBuilder sb) {
        int ret = 0;

        sb.setLength(0);
        String tmp = (String) getParam("id", request, "");
        if ( tmp.length() <= 0 ){
            sb.append("Error: No ID Found");
            return -1;
        }
        tmp = ((String) getParam("dtype", request, "env")).toLowerCase();
        ret = tmp.startsWith("env") ? 0 : 1;

        String[] ids = (ret == 0) ?  idENV : idHEALTH;

        sb.append(getTime()+"\t");
        for (String p: ids ) {
            sb.append( getParam(p, request, "") + "\t");
        }
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            String n = (String) e.nextElement();
            sb.append( n + ":" + request.getParameter(n) + ",");
        }
        sb.append("\n");
        return ret;
    }

%>
<%
    String tmp = ((String) getParam("cmd", request, "")).toLowerCase();
    if ( tmp.startsWith("close")) {
        closeFiles();
    }
    String apiKey = ((String) getParam("api_key", request, "")).toLowerCase();

    initFiles();
    StringBuilder sb = new StringBuilder(256);

    int type = getString(request, sb);

    if ( type < 0 ) {
        out.println("Error - " + sb);
        return;
    }
    if ( apiKey.length() > 0) {
        if ( type == 0)
            writeToEnv(sb);
        else
            writeToHealth(sb);
    } else {
        sb.append(" : NOT LOGGED");
    }
    out.println("<pre>");
    if (type == 0) {
        out.println(fileENVHeader);
    } else {
        out.println(fileHLTHeader);
    }
    out.print(sb);
//    out.println("<br/> " + ostreamENV.)
%>


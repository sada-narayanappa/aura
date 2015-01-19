<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="geospaces.*" %>

<%@include file="include1.jsp" %>

<%!
    public void jspInit() {
        ServletConfig config = getServletConfig();
    }
%>
<%
    String contentType = request.getContentType();
    if ((contentType.indexOf("multipart/form-data") < 0)) {
        out.println("No Files sent - not a multi part message");
        return;
    }
    File file ;
    int maxFileSize = 5000 * 1024;
    int maxMemSize = 5000 * 1024;
    ServletContext context = pageContext.getServletContext();
    String filePath = "/opt/SCHAS/data/files/";

    out.println("<html><head><title>JSP File upload</title></head><body>Uploading: <pre> \n");

    int count = 0;
    DiskFileItemFactory factory = new DiskFileItemFactory();
    factory.setSizeThreshold(maxMemSize);               // max size stored in memory
    factory.setRepository(new File("/tmp"));        // save data for large files.

    ServletFileUpload upload = new ServletFileUpload(factory);
    //upload.setSizeMax(maxFileSize );
    HashMap formFields = new HashMap();

    try{
        List fileItems = upload.parseRequest(request);
        Iterator i = fileItems.iterator();

        while ( i.hasNext () ) {
            FileItem fi = (FileItem)i.next();
            if ( fi.isFormField () ) {
                String n = fi.getFieldName();
                String v = fi.getString();
                formFields.put(n,v);
                out.println (count + " " + n + " " + v);
            }else {
                String fieldName = fi.getFieldName();
                String fileName = fi.getName();
                boolean isInMemory = fi.isInMemory();
                long sizeInBytes = fi.getSize();

                if ( fileName.length() <= 0 || sizeInBytes <= 0 || sizeInBytes > maxFileSize ) {
                    out.println("No File or valid files given or file too big");
                    continue;
                }
                if( fileName.lastIndexOf("\\") >= 0 ){
                    file = new File( filePath + fileName.substring(fileName.lastIndexOf("\\"))) ;
                }else{
                    file = new File( filePath + fileName);
                }

                if ( file.isDirectory()) {
                    out.println("Cannot upload directory : " + file.getName());
                    continue;
                }
                String newFile = "";
                if ( formFields.get("rename-file") != null) {
                    newFile = TextFile.renameFile(file.getAbsolutePath(), count + "_");
                    out.println("Renaming: " + newFile);
                }
                fi.write( file );

                if (newFile.length() > 0 ) {
                    boolean t = TextFile.deleteSecondFileIfEqual(file.getAbsolutePath(), newFile);
                    if ( t ) {
                        out.println("Files were same");
                    }
                }
                out.println(count +" Uploaded Filename: " + filePath + fileName + "\n");
                count++;
            }
        }
    }catch(Exception ex) {
        System.out.println(ex);
    }
    for ( Object k : formFields.keySet()) {
        out.println(""+ k + ": " + formFields.get(k) );
    }
    out.println("</pre>Uploaded: " + count + " files</body></html>");
%>


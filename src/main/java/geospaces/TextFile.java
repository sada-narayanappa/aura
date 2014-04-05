package geospaces;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.TimeZone;

public class TextFile{

   protected final static Log LOG = LogFactory.getLog("CSVFile");
   static long   MAX_FILE_SIZE = 1024 * 1024 * 10; // 10 Meg

   protected String[]            ids;
   protected String              fileLocation  = "/tmp/SCH/";
   protected String              fileName;
   protected FileOutputStream    ostream = null;
   protected long                remainingBytes = MAX_FILE_SIZE;
   protected String              delimiter = "\t";

   protected String              fileHeader;


   public TextFile(String fName, String[] params) {
      File f = new File(fName);
      if (f.getParent() == null) {
         fileName = fileLocation + fName;
      } else {
         fileName = fName;
      }

      f = new File(fileName);
      if ( f.getParent() != null ) {
         File dir = new File(f.getParent());
         dir.mkdirs();
      } else { // Always call makedirs to make sure we create this directory
         File dir = new File(fileLocation);
         dir.mkdirs();
      }
      remainingBytes = MAX_FILE_SIZE - f.length();

      try {
         ostream = new FileOutputStream(fileName, true);
      } catch (Exception e) {
         e.printStackTrace();
      }
      ids = params;

      fileHeader = "unix time" + delimiter + "yyyy/mm/dd hh:mm:ss" + delimiter;
      for (String p: ids) {
         fileHeader += p + delimiter;
      }
   }
   public String getHeader() {
      return fileHeader;
   }
   private void checkFileSize() {
      File file =new File(fileName);
      if (!file.exists() || file.length() < MAX_FILE_SIZE) {
         return;
      }

      try{
         String ret;
         Calendar cal = Calendar.getInstance();
         long time = cal.getTimeInMillis();
         SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMddHHmmss");
         fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

         String newFileName = fileName.substring(0, fileName.lastIndexOf("."));
         newFileName += "_" + fmt.format(time) + ".csv";

         file.renameTo(new File(newFileName));

      }catch(Exception e) {
      }
   }

   private void close() {
      try{
         if (ostream != null) {
            ostream.close();
         }
      } catch (Exception e) {
         LOG.error("Error During CLosing ENV File" + e);
      }
      finally {
         ostream = null;
      }
   }

   public void write(StringBuilder sb) {
      try {
         ostream.write(sb.toString().getBytes(), 0 , sb.length());
         remainingBytes -= sb.length();

         if ( remainingBytes <= 0) {
            remainingBytes = MAX_FILE_SIZE;
            close();
            checkFileSize();
            ostream = new FileOutputStream(fileName, true);
         }

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
      SimpleDateFormat fmt = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
      fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

      ret = time/1000 + "\t" + fmt.format(time);
      return ret;
   }
   //
   //
   public void getString(HttpServletRequest request, StringBuilder sb) {
      sb.setLength(0);

      sb.append(getTime()+"\t");
      for (String p: ids ) {
         sb.append( getParam(p, request, "") + "\t");
      }
      sb.append("\n");
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
}

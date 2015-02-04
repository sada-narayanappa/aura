package geospaces;


import org.apache.commons.io.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.servlet.http.HttpServletRequest;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class TextFile{

   protected final static Log LOG = LogFactory.getLog("CSVFile");
   static long   MAX_FILE_SIZE = 1024 * 1024 * 10; // 10 Meg

   protected String[]            ids;
   protected String              fileLocation  = "/opt/SCHAS/data/";
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
         if ( !dir.exists())
            dir.mkdirs();
      }
      // Always call makedirs to make sure we create the default directory
      File dir = new File(fileLocation);
      if ( !dir.exists())
         dir.mkdirs();

      remainingBytes = MAX_FILE_SIZE - f.length();

      try {
         ostream = new FileOutputStream(fileName, true);
      } catch (Exception e) {
         e.printStackTrace();
      }
      ids = params;

      fileHeader = "unix_time" + delimiter + "yyyy_MM_dd_HH_mm_ss" + delimiter;
      for (String p: ids) {
         fileHeader += p + delimiter;
      }


      //Write the header
      try {
         String hedFileName = fileName.substring(0, fileName.lastIndexOf("."));
         hedFileName += "_HEADER.txt";
         File hFile = new File(hedFileName);
         String[] lines = tail(hedFileName);
         String lastHeader = lines.length > 0 ? lines[lines.length-1]: "";

         String head = fileHeader + "\n";
         if ( !lastHeader.startsWith(fileHeader)) {
            FileOutputStream os = new FileOutputStream(hedFileName, true);
            os.write(head.getBytes(), 0 , head.length());
            os.close();
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   //
   // This will just return last 2k bytes of a file
   public static String[] tail( String src)  {
      try{
         RandomAccessFile in = new RandomAccessFile(src, "r");
         int bytesCnt = 1024 * 2;
         bytesCnt =  (in.length() < bytesCnt) ? (int)in.length() : (int)in.length() - bytesCnt;
         in.seek(in.length() - bytesCnt);

         byte[] bytes = new byte[bytesCnt];
         in.readFully(bytes);

         String str = new String(bytes);
         String[] lines = str.split("\n");

         in.close();
         return lines;

      } catch(Exception e) {
         e.printStackTrace();
      }
      String[] ret = {};
      return ret;
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
         renameFile(file.getAbsolutePath(),"_");
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
         ostream.flush();
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
      SimpleDateFormat fmt = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
      fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

      ret = time/1000 + "\t" + fmt.format(time);
      return ret;
   }
   // returns local time and String
   protected String[] getTimeArray() {
      Calendar cal = Calendar.getInstance();
      long time = cal.getTimeInMillis();
      SimpleDateFormat fmt = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
      fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

      String[] ret = new String[]{""+time/1000 , fmt.format(time)};
      return ret;
   }
   //
   public void getString(HttpServletRequest request, StringBuilder sb) {
      sb.setLength(0);

      sb.append(getTime()+"\t");
      for (String p: ids ) {
         sb.append( getParam(p, request, "") + "\t");
      }
      sb.append("\n");
   }

   public void getStringJSON(HttpServletRequest request, StringBuilder sb) {
      sb.setLength(0);
      Map map = request.getParameterMap();
      getString(map, sb);
   }

   public void getString(Map map,  StringBuilder sb) {
      String[] ta = getTimeArray();
      sb.append("{ \"unix_time\": " + ta[0] +", \"datetime\": \""+ ta[1] + "\"");

      for (String p: ids ) {
         String val = (String)map.get(p);
         if ( val == null) {
            continue;
         }
         if ( val.length() > 2 && val.startsWith("\"") && val.endsWith("\"")) {
            val = val.substring(1,val.length()-1);
         }
         val = val.replaceAll("\"", "\\\\\"");

         p = p.trim();
         if ( !val.equals(""))
            sb.append( ",\"" + p + "\": \"" + val + "\" ");
         map.remove(p);
      }
      for (Object k : map.keySet()) {
         String val = (String)map.get(k);
         if ( val == null ) {
            continue;
         }
         if ( val.length() > 2 && val.startsWith("\"") && val.endsWith("\"")) {
            val = val.substring(1,val.length()-1);
         }

         val = val.toString().replaceAll("\"", "\\\\\"");
         k = (""+k).trim();
         sb.append(",\"" + k + "\": \"" + val + "\" ");
      }
      sb.append("}\n");
   }

   public static void getMap(String[] st, HashMap map) {
      map.clear();
      for (String s: st ) {
         String[] kv = s.split("=");
         if (kv.length < 2) {
            continue;
         }
         map.put(kv[0], kv[1]);
      }
   }
   public void getStringJSONMulti(HttpServletRequest request, StringBuilder sb) {
      sb.setLength(0);
      String text = ""+ getParam("text", request, "");
      if (text.length() <= 0) {
         getStringJSON(request, sb);
         return;
      }
      text = text.replaceAll("\r\n", "\n");
      String[] lines = text.split("\n");

      //sb.append("[");
      HashMap map = new HashMap();
      for (String s: lines) {
         System.out.println(" " + lines.length + " " + s);

         s = s.trim();
         String[] v = s.split("[&,]");
         getMap(v, map);
         if ( s.startsWith("#") || s.length() <=0 || v.length <=0 || map.isEmpty()) {
            continue;
         }
         getString(map,sb);
      }
      if ( sb.toString().endsWith(",")) {
         sb= sb.deleteCharAt(sb.length()-1);
      }
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

   public static String renameFile(String fileName, Object add) throws IOException{
      File file =new File(fileName);
      if ( !file.exists()) {
         return "";
      }
      Calendar cal = Calendar.getInstance();
      long time = cal.getTimeInMillis();
      SimpleDateFormat fmt = new SimpleDateFormat("yyyyMMddHHmmss");
      fmt.setTimeZone(TimeZone.getTimeZone("GMT"));

      int idx = fileName.lastIndexOf(".");
      if (idx < 0 ) {
         idx = fileName.length();
      }
      String newFileName = fileName.substring(0, idx);
      String ext = fileName.substring(idx);
      newFileName += "_" + add +fmt.format(time)  + ext;

      file.renameTo(new File(newFileName));
      return newFileName;
   }

   public static boolean deleteSecondFileIfEqual(String f1, String f2) throws IOException{
      File file1 = new File(f1);
      File file2 = new File(f2);

      if (FileUtils.contentEquals(file1, file2)) {
         file2.delete();
         return true;
      }
      return false;
   }


}

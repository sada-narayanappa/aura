aura
====
If somethings are not working:

check src/main/webapp/webroot/db.properties file and change the following value:
     String dburl    ="jdbc:postgresql://www.smartconnectedhealth.org:5432/SCHASDB";

Build:
======
run from base dir:
[ ] mvn install -DskipTests=true -Dlicense.skip=true -Dpmd.skip
[ ] cp target/aura*.war   /usr/local/tomcat/webapps

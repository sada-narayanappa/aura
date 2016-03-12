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


To Run and debig locally
========================
Build and test locally.

You must have git repo in /opt/SCHAS/git
[ ] mkdir -p /opt/SCHAS/git
[ ] cd /opt/SCHAS/git
[/opt/SCHAS/data/git] git co https://github.com/sada-narayanappa/aura
[ ] cd /usr/local/tomcat/webapps
[/usr/local/tomcat/webapps] ln -s /opt/SCHAS/git/aura/src/main/webapp/webroot aura1
[ ] mkdir /opt/SCHAS/data
[ ] cd /opt/SCHAS/data
[/opt/SCHAS/data] ln -s /opt/SCHAS/git/SCHASDB/sql

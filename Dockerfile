# Set the base image to Ubuntu
FROM ubuntu

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git -y

RUN git clone --progress --verbose https://github.com/eshohet/com.nimbits.git /root/com.nimbits
RUN cd /root/com.nimbits && git checkout ooma2 

# INSTALLATION PORTION

RUN chmod +x /root/com.nimbits/scripts/install.sh
RUN apt-get install -y expect wget software-properties-common
ADD install.exp /root/com.nimbits
RUN chmod +x /root/com.nimbits/install.exp
RUN /root/com.nimbits/install.exp

RUN rm -f /root/com.nimbits/scripts/tomcat.sh
ADD tomcat.sh /root/com.nimbits/scripts/tomcat.sh
RUN chmod +x /root/com.nimbits/scripts/tomcat.sh && /root/com.nimbits/scripts/tomcat.sh

# BUILD NIMBITS SERVER

ADD compile.sh /root/com.nimbits/compile.sh
RUN /bin/bash /root/com.nimbits/compile.sh
RUN rm -fr /opt/tomcat/webapps/ROOT/
RUN mkdir /opt/tomcat/webapps/ROOT && cp /root/com.nimbits/nimbits_server/target/nimbits_server.war /opt/tomcat/webapps/ROOT/ROOT.war

# PREPARE NIMBITS SERVER
RUN cd /opt/tomcat/webapps/ROOT && jar -xvf ROOT.war && rm -f ROOT.war && rm -f /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
ADD application.properties /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
RUN cd /opt/tomcat/webapps/ROOT && jar -cvf ROOT.war .

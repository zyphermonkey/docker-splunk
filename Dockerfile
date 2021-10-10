### Dockerfile for splunk
FROM phusion/baseimage:0.9.16
LABEL authors="zyphermonkey"

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_VERSION 7.1.2
ENV SPLUNK_BUILD a0c72a66db66
ENV SPLUNK_FILENAME splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-linux-2.6-amd64.deb

ENV HOME /root
ENV SPLUNK_HOME=/opt/splunk
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
RUN usermod -u 99 nobody && \
    usermod -g 100 nobody && \
    usermod -d /home nobody && \
    chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update -q && \
	apt-get install -y wget
	
#RUN wget -O splunk-6.5.3-36937ad027d4-linux-2.6-amd64.deb "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.5.3&product=splunk&filename=splunk-6.5.3-36937ad027d4-linux-2.6-amd64.deb&wget=true"
RUN wget -O ${SPLUNK_FILENAME} https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}

RUN dpkg -i /${SPLUNK_FILENAME}
RUN rm /${SPLUNK_FILENAME}

### Configure Service Startup
COPY rc.local /etc/rc.local
RUN chmod a+x /etc/rc.local && \
    chown -R nobody:users /opt/splunk
    
RUN printf "\nOPTIMISTIC_ABOUT_FILE_LOCKING = 1\n" >> $SPLUNK_HOME/etc/splunk-launch.conf

EXPOSE 8000 8088 8089 9997 514 

VOLUME [ "/opt/splunk/etc", "/opt/splunk/var", "/data", "/license" ]

### END
### To make this a persistent container, you must map /opt/splunk/var of this container
### to a folder on your host machine.
###

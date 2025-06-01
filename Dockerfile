FROM amazonlinux:2
LABEL maintainer="se.estrada@duocuc.cl"
LABEL version="1.0"
LABEL description="Custom Nagios Docker image by Sergio"

ENV NAGIOS_USER=SERGIO_NAGIOS
ENV NAGIOS_GROUP=SERGIO_NAGIOS
ENV NAGIOS_WEB_USER=sergio_nagios
ENV NAGIOS_WEB_PASS=se.nagios

RUN yum update -y && \
    yum install -y \
    httpd \
    php \
    gcc \
    gcc-c++ \
    make \
    gd-devel \
    unzip \
    wget \
    curl \
    openssl-devel \
    httpd-tools \
    tar && \
    yum groupinstall -y "Development Tools" && \
    yum install -y glibc-devel glibc-headers && \
    yum clean all

RUN groupadd ${NAGIOS_GROUP} && \
    useradd -m -s /bin/bash -g ${NAGIOS_GROUP} ${NAGIOS_USER}

WORKDIR /tmp
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.7.tar.gz && \
    tar xzf nagios-4.5.7.tar.gz && \
    cd nagios-4.5.7 && \
    ./configure --with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} && \
    make all && \
    make install && \
    make install-commandmode && \
    make install-init && \
    make install-config && \
    make install-webconf

RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users ${NAGIOS_WEB_USER} ${NAGIOS_WEB_PASS}

RUN echo "LoadModule cgi_module modules/mod_cgi.so" >> /etc/httpd/conf/httpd.conf && \
    echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

EXPOSE 80

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]


# Cómo construir y ejecutar el contenedor Docker Nagios

## Construir la imagen

```bash
sudo docker build -t nagios-core-sergio2 .
docker run -d --name nagios-container-sergio -p 8080:80 nagios-core-sergio2
docker ps
docker exec -it nagios-container-sergio /bin/bash
docker start nagios-container-sergio

Usuario y contraseña para acceder a la interfaz web de Nagios
Usuario: sergio_nagios
Password: se.nagios

🧑‍💻 Acceso a interfaz web
URL: http://ip-publica:8080/nagios

Usuario: sergio_nagios
Contraseña: se.nagios

🔧 Variables utilizadas
Variable	Valor
NAGIOS_USER	SERGIO_NAGIOS
NAGIOS_GROUP	SERGIO_NAGIOS
NAGIOS_WEB_USER	sergio_nagios
NAGIOS_WEB_PASS	se.nagios

✅ Uso de variables: permite cambiar credenciales y configuraciones fácilmente, de forma reutilizable y más segura.

<br>

# 📦 Dockerfile personalizado para Nagios sobre Amazon Linux 2


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

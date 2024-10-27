# Sección 1: Establecer la imagen base y la zona horaria
FROM ubuntu:22.04

# Establecer zona horaria a UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Sección 2: Instalación de Apache, Perl y otros paquetes
RUN apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    perl \
    curl \
    vim \
    libcgi-pm-perl && \
    cpan URI::Escape && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Sección 3: Activar módulos CGI y Perl en Apache
RUN a2enmod cgi && \
    a2enmod perl

# Sección 4: Copiar los archivos del proyecto al directorio adecuado
COPY ./html/index.html /var/www/html/
COPY ./html/styles.css /var/www/html/
COPY ./html/background.gif /var/www/html/
COPY ./cgi-bin/calculadora.pl /usr/lib/cgi-bin/calculadora.pl

# Sección 5: Darle permisos para que ejecute
RUN chmod +x /usr/lib/cgi-bin/calculadora.pl && \
    sed -i 's/\r$//' /usr/lib/cgi-bin/calculadora.pl

# Sección 6: Configuración del directorio CGI
RUN echo "<Directory /usr/lib/cgi-bin>\n\
    AllowOverride None\n\
    Options +ExecCGI\n\
    AddHandler cgi-script .pl\n\
    Require all granted\n\
</Directory>" >> /etc/apache2/apache2.conf

# Sección 7: Exponer el puerto 80 (puerto de Apache)
EXPOSE 80

# Iniciar Apache en el contenedor
CMD ["apachectl", "-D", "FOREGROUND"]
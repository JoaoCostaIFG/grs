FROM ubuntu:20.04

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.4 libgd-dev libmcrypt-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext apache2

RUN cd /tmp && \
  wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz && \
  tar xzf nagioscore.tar.gz

WORKDIR /tmp/nagioscore-nagios-4.4.6/

RUN ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
  make all

RUN make install-groups-users && \
  usermod -a -G nagios www-data

RUN make install

RUN make install-daemoninit

RUN make install-commandmode

RUN make install-config

RUN make install-webconf && \
  a2enmod rewrite && a2enmod cgi

RUN htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# plugins
RUN mkdir /nagios && cd /tmp && \
  wget --no-check-certificate -O /nagios/nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.3.3.tar.gz && \
  tar zxf /nagios/nagios-plugins.tar.gz

WORKDIR /tmp/nagios-plugins-release-2.3.3/

RUN ./tools/setup && \
  ./configure && \
  make && \
  make install

WORKDIR /

RUN apt-get install -y curl

COPY start.sh /start.sh

CMD ["/bin/bash", "/start.sh"]

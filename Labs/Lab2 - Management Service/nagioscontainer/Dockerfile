FROM manios/nagios:latest

# nagios plugins
RUN wget --no-check-certificate -O /nagios/nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
RUN tar zxf /nagios/nagios-plugins.tar.gz

CMD ["/bin/bash", "/nagios/start.sh"]

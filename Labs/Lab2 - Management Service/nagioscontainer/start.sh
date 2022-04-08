#!/bin/bash

/etc/init.d/apache2 restart
/etc/init.d/nagios restart
tail -f /var/log/apache2/access.log /var/log/apache2/error.log

FROM ubuntu:14.04

MAINTAINER Luis Elizondo "lelizondo@gmail.com"
ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Deny restarting applications when installing them
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Update system
RUN apt-get update && apt-get dist-upgrade -y

# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN apt-get -y install apache2 libapache2-mod-php5 php5-xmlrpc php5-Intl php5-mcrypt php5-cli php5-common php5-json php5-imagick php5-imap php5-memcache php5-mysql php5-gd php-pear php5-redis php5-memcache  php5-dev php5-curl curl git supervisor make

RUN apt-get -y install msmtp msmtp-mta 

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install uploadprogress

RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite

RUN php5enmod mcrypt
RUN php5enmod opcache

# PHP
ADD ./config/php/php.ini /etc/php5/apache2/php.ini

ADD ./mail.sh /opt/mail.sh
RUN chmod +x /opt/mail.sh

# We want it empty
RUN touch /etc/msmtprc
RUN chgrp mail /etc/msmtprc
RUN chmod 660 /etc/msmtprc
RUN touch /var/log/supervisor/msmtp.log
RUN chgrp mail /var/log/supervisor/msmtp.log
RUN chmod 660 /var/log/supervisor/msmtp.log
RUN adduser www-data mail

RUN rm /usr/sbin/sendmail
RUN rm /usr/lib/sendmail

RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail
RUN ln -s /usr/bin/msmtp /usr/bin/sendmail
RUN ln -s /usr/bin/msmtp /usr/lib/sendmail

RUN echo "extension=uploadprogress.so" > /etc/php5/mods-available/uploadprogress.ini
RUN php5enmod uploadprogress

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/supervisor
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

ENV SMTP_HOST smtp.gmail.com
ENV SMTP_PORT 587
ENV SMTP_FROMNAME My Name
ENV SMTP_USERNAME username@example.com
ENV SMTP_PASSWORD secret

# Startup script
# This startup script wll configure nginx
ADD ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data
RUN chown -R www-data:www-data /var/www

RUN rm -Rf /var/www/html

EXPOSE 80
WORKDIR /var/www
VOLUME ["/var/www/sites/default/files"]
CMD ["/usr/bin/supervisord", "-n"]

# Add files
ADD ./config/supervisord-apache.conf /etc/supervisor/conf.d/supervisord-apache.conf
ADD ./config/apache2.conf /etc/apache2/apache2.conf
ADD ./config/default.conf /etc/apache2/sites-enabled/000-default.conf
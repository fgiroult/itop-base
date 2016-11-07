# image de base php apache
FROM php:5.6-apache

#installation des packages nécessaires et librairies PHP
## pour installer mysql sur ce conteneur, décommenter la ligne ci dessous
#ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
        php5-mysqlnd \
		php5-imap php-pear \
		php5-ldap php5-gd \
		php5-mcrypt \
		php-pclzip \
		unzip \
		graphviz \
		zlib1g-dev \
		libxml2-dev \
		libvpx-dev \
		libjpeg-dev \
		libpng-dev \
		libldap2-dev \
		libldb-dev \
		libmcrypt-dev \
		mysql-client
RUN docker-php-ext-install -j$(nproc) zip mysqli soap mcrypt
RUN docker-php-ext-configure gd --with-vpx-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
	&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so
RUN docker-php-ext-configure ldap --with-ldap=/usr \
	&& docker-php-ext-install -j$(nproc) ldap
	
# conf PHP : session.save_path = "/var/lib/php5/sessions"
ADD config/docker-php-session.ini /usr/local/etc/php/conf.d
	
#recuperation du zip itop version 2.3.0 et déploiement
RUN mkdir /var/www/html/itop \
	&& cd /var/www/html/itop \
	&& curl -fsSL 'https://sourceforge.net/projects/itop/files/itop/2.3.0/iTop-2.3.0-2827.zip' -o itop.zip \
	&& unzip itop.zip \
	&& rm itop.zip \ 
	&& chown -R www-data:root /var/www/html/itop
		
RUN php5enmod mcrypt
RUN service apache2 restart

#recuperation du zip DataModeltoolkit version 2.2 et déploiement
RUN cd /var/www/html/itop/web \
	&& curl -fsSL 'http://www.combodo.com/documentation/iTopDataModelToolkit-2.2.zip' -o toolkit.zip \
	&& unzip toolkit.zip \
	&& chown -R www-data:root toolkit \
	&& rm toolkit.zip \
	&& mkdir /var/www/html/itop/web/env-toolkit

#installation du modele de donnees arismore
ADD model/DataModel_Extension_v1_1.zip /var/www/html/itop/web/extensions
RUN cd /var/www/html/itop/web/extensions \
	&& chmod 757 /var/www/html/itop/web/extensions \
	&& unzip DataModel_Extension_v1_1.zip \
	&& rm /var/www/html/itop/web/extensions/DataModel_Extension_v1_1.zip
#	&& chmod 644 /var/www/html/itop/web/conf/production/config-itop.php

RUN chown -R www-data:www-data /var/www/html

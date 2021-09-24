#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

export DEBIAN_FRONTEND=noninteractive

AWS_RDS='change this for your rds endpoint'

${SUDO} apt -qq update
${SUDO} apt -qq -y dist-upgrade
${SUDO} apt -qq -y install apt-transport-https lsb-release ca-certificates curl
${SUDO} sh -c 'curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -'
${SUDO} sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt -qq update
${SUDO} apt -qq -y install curl vim net-tools mysql-client
${SUDO} apt-get -qq -y install libapache2-mod-php7.2 php7.2-mysql php7.2 \
	php7.2-bcmath php7.2-bz2 php7.2-cli php7.2-common php7.2-curl \
	php7.2-gd php7.2-interbase php7.2-intl php7.2-json php7.2-mbstring \
	php7.2-opcache php7.2-soap php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip
${SUDO} apt -qq -y autoremove
${SUDO} rm -rf /var/www/html
${SUDO} sh -c 'curl -L http://wordpress.org/latest.tar.gz | tar xz --directory /var/www/'
${SUDO} mv /var/www/wordpress /var/www/html
${SUDO} chown -R www-data:www-data /var/www/html
${SUDO} sh -c 'echo "<?php" > /var/www/html/wp-config.php'
${SUDO} chmod 666  /var/www/html/wp-config.php
cat <<'EOF' >> /var/www/html/wp-config.php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'wordpress');
EOF
echo "define('DB_HOST', '${AWS_RDS}');" >> /var/www/html/wp-config.php
cat <<'EOF' >> /var/www/html/wp-config.php
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
EOF
curl -fsSL http://api.wordpress.org/secret-key/1.1/salt >> /var/www/html/wp-config.php
cat <<'EOF' >> /var/www/html/wp-config.php
$table_prefix  = 'wp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
  define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF
${SUDO} chmod 0644 /var/www/html/wp-config.php
${SUDO} service apache2 restart

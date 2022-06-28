FROM alpine:3.14
EXPOSE 9000/tcp

ENV SCRIPT_ROOT=/opt/tt-rss

RUN apk add --no-cache dcron php8 php8-fpm \
	php8-pdo php8-gd php8-pgsql php8-pdo_pgsql \
	php8-mbstring php8-intl php8-xml php8-curl \
	php8-session php8-tokenizer php8-dom php8-fileinfo \
	php8-json php8-iconv php8-pcntl php8-posix php8-zip php8-exif \
	php8-openssl git postgresql-client sudo php8-pecl-xdebug rsync && \
	sed -i 's/\(memory_limit =\) 128M/\1 256M/' /etc/php8/php.ini && \
	sed -i -e 's/^listen = 127.0.0.1:9000/listen = 9000/' \
		-e 's/;\(clear_env\) = .*/\1 = no/i' \
		-e 's/^\(user\|group\) = .*/\1 = app/i' \
		-e 's/;\(php_admin_value\[error_log\]\) = .*/\1 = \/tmp\/error.log/' \
		-e 's/;\(php_admin_flag\[log_errors\]\) = .*/\1 = on/' \
			/etc/php8/php-fpm.d/www.conf && \
	mkdir -p /var/www ${SCRIPT_ROOT}/config.d

ADD startup.sh ${SCRIPT_ROOT}
ADD updater.sh ${SCRIPT_ROOT}
ADD index.php ${SCRIPT_ROOT}
ADD dcron.sh ${SCRIPT_ROOT}
ADD backup.sh /etc/periodic/weekly/backup
ADD config.docker.php ${SCRIPT_ROOT}

ENV OWNER_UID=1000
ENV OWNER_GID=1000

ENV PHP_WORKER_MAX_CHILDREN=5
ENV PHP_WORKER_MEMORY_LIMIT=256M

# these are applied on every startup, if set
ENV ADMIN_USER_PASS=""
# see classes/UserHelper.php ACCESS_LEVEL_*
# setting this to -2 would effectively disable built-in admin user
# unless single user mode is enabled
ENV ADMIN_USER_ACCESS_LEVEL=""

# these are applied unless user already exists
ENV AUTO_CREATE_USER=""
ENV AUTO_CREATE_USER_PASS=""
ENV AUTO_CREATE_USER_ACCESS_LEVEL="0"

# TODO: remove prefix from container variables not used by tt-rss itself:
#
# - TTRSS_NO_STARTUP_PLUGIN_UPDATES -> NO_STARTUP_PLUGIN_UPDATES
# - TTRSS_XDEBUG_... -> XDEBUG_...

# don't try to update local plugins on startup (except for nginx_xaccel)
ENV TTRSS_NO_STARTUP_PLUGIN_UPDATES=""

# TTRSS_XDEBUG_HOST defaults to host IP if unset
ENV TTRSS_XDEBUG_ENABLED=""
ENV TTRSS_XDEBUG_HOST=""
ENV TTRSS_XDEBUG_PORT="9000"

ENV TTRSS_DB_TYPE="pgsql"
ENV TTRSS_DB_HOST="db"
ENV TTRSS_DB_PORT="5432"

ENV TTRSS_MYSQL_CHARSET="UTF8"
ENV TTRSS_PHP_EXECUTABLE="/usr/bin/php8"
ENV TTRSS_PLUGINS="auth_internal, note, nginx_xaccel"

CMD ${SCRIPT_ROOT}/startup.sh

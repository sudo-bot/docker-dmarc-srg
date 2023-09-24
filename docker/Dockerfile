FROM webdevops/php-nginx:8.2-alpine

ARG VERSION="v1.8"

ARG DIST_URL="https://github.com/liuch/dmarc-srg/archive/refs/tags/v1.8.tar.gz"
ARG BUILD_DATE
ARG VCS_REF
ENV PHP_DISMOD=amqp,apcu,bcmath,bz2,calendar,exif,ffi,gd,gettext,gmp,imagick,intl,ldap,memcached,mongodb,pcntl,mysqli,pdo_pgsql,pgsql,redis,shmop,soap,sockets,sysvmsg,sysvsem,sysvshm,vips,xmlrpc,xsl,yaml,ioncube
ENV WEB_DOCUMENT_ROOT="/var/www/html"
ENV WEB_DOCUMENT_INDEX="index.html"
# See: https://www.php.net/manual/ini.core.php#ini.variables-order
ENV php.variables_order="EGPCS"

# Remove global logging
RUN sed -i '/access_log/d' /etc/nginx/nginx.conf

COPY nginx-host.conf /opt/docker/etc/nginx/vhost.common.d/20-nginx-host.conf
COPY nginx-logs.conf /opt/docker/etc/nginx/conf.d/5-logs.conf
COPY nginx-vhost.conf /opt/docker/etc/nginx/vhost.conf

USER application
WORKDIR $WEB_DOCUMENT_ROOT

RUN curl -# -L -o dmarc-srg.tar.gz ${DIST_URL} && \
    tar -xzf dmarc-srg.tar.gz -C $WEB_DOCUMENT_ROOT --strip-components=1 && \
    rm dmarc-srg.tar.gz && \
    cd $WEB_DOCUMENT_ROOT && \
    curl -# -L -o - https://patch-diff.githubusercontent.com/raw/liuch/dmarc-srg/pull/80.diff | patch -p1 && \
    rm -vr *.md && \
    tree

COPY config.php /var/www/html/config/conf.php

# Metadata
LABEL org.label-schema.vendor="liuch" \
    org.label-schema.url="https://github.com/liuch/dmarc-srg#readme" \
    org.label-schema.name="dmarc-srg" \
    org.label-schema.description="A dmarc-srg image" \
    org.label-schema.version=${VERSION} \
    org.label-schema.vcs-url="https://github.com/liuch/dmarc-srg.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0" \
    \
    com.docker.extension.publisher-url="https://github.com/liuch" \
    \
    org.opencontainers.image.title="Docker dmarc-srg server" \
    org.opencontainers.image.description="A dmarc-srg image" \
    org.opencontainers.image.authors="liuch@mail.ru" \
    org.opencontainers.image.url="https://github.com/liuch/dmarc-srg#readme" \
    org.opencontainers.image.documentation="https://github.com/liuch/dmarc-srg#readme" \
    org.opencontainers.image.source="https://github.com/liuch/dmarc-srg" \
    org.opencontainers.image.vendor="liuch" \
    org.opencontainers.image.licenses="GPL-3.0" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${VERSION} \
    org.opencontainers.image.revision=${VCS_REF} \
    org.opencontainers.image.ref.name="${VERSION}"

EXPOSE 80

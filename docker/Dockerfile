FROM ruby:2.4.5-stretch

ENV RAILS_SERVE_STATIC_FILES=enabled \
    RAILS_ENV=production

WORKDIR /app

COPY Gemfile Gemfile.lock yarn.lock package.json ./

RUN echo "America/La_Paz" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/America/La_Paz /etc/localtime && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs imagemagick libmagickwand-dev cron && \
    wget -O /tmp/wkhtmltopdf.tar.xz -c https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    tar -xf /tmp/wkhtmltopdf.tar.xz -C /opt/ && \
    bundle install --deployment --without development test && \
    gem install passenger -v 6.0.1 && \
    npm install -g yarn@1.14.0 && \
    yarn install && \
    mkdir log && \
    mkdir tmp && \
    apt-get remove -y --purge wget g++ gcc make automake openssh-client mercurial && \
    apt-get autoremove --purge -y && \
    apt-get autoclean && \
    rm -rf /tmp/*

COPY . .

VOLUME /app/public/uploads

EXPOSE 3000

ENTRYPOINT ["/app/docker/entrypoint.sh"]

CMD ["passenger", "start", "-e", "production"]

# Create a production image for Chouette
#
# docker build --build-arg WEEK=`date +%Y%U` -t chouette-core -f Dockerfile .
FROM debian:stable-slim

ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true RAILS_LOG_TO_STDOUT=true SIDEKIQ_REDIS_URL=redis://redis:6379/12
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# To force rebuild every week
ARG WEEK

# Prepare nodejs 6.x and yarn package installation
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg ca-certificates apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_6.x stretch main" > /etc/apt/sources.list.d/nodesource.list

# Install ruby, native dependencies, bundler and yarn
RUN apt-get update && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && \
    apt-get install -y --no-install-recommends ruby2.3 locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get install -y --no-install-recommends libpq5 libxml2 zlib1g imagemagick libproj12 postgresql-client-common postgresql-client-9.6 yarn nodejs cron && \
    gem2.3 install --no-ri --no-rdoc bundler

# Install bundler packages
# Use a Gemfile.docker file to use temporary activerecord-nulldb-adapter
COPY Gemfile Gemfile.lock /app/
RUN apt-get -y install --no-install-recommends build-essential ruby2.3-dev libpq-dev libxml2-dev zlib1g-dev libproj-dev libmagic1 libmagic-dev libmagickwand-dev git-core && \
    cd /app && echo "eval File.read('Gemfile')\ngem 'activerecord-nulldb-adapter'" > Gemfile.docker && BUNDLE_GEMFILE=Gemfile.docker bundle install --without development test --path vendor/bundle

# Install yarn packages
COPY package.json yarn.lock /app/
RUN cd /app && yarn --frozen-lockfile install

# Install application file
COPY . /app/

# Override database.yml and secrets.yml files
COPY config/database.yml.docker app/config/database.yml
COPY config/secrets.yml.docker app/config/secrets.yml

# Run assets:precompile (with nulldb)
# Run whenever to define crontab
# Run bundler with "original" Gemfile
# Create version.json file if VERSION is available
# Remove useless packages & clean apt
# Remove all temporay directories
ARG VERSION
RUN cd /app && BUNDLE_GEMFILE=Gemfile.docker bundle exec rake ci:fix_webpacker assets:precompile i18n:js:export RAILS_DB_ADAPTER=nulldb RAILS_DB_PASSWORD=none RAILS_ENV=production && \
    BUNDLE_GEMFILE=Gemfile.docker bundle exec whenever --output '/proc/1/fd/1' --update-crontab chouette --set 'environment=production&bundle_command=bundle exec' --roles=app,db,web && \
    rm Gemfile.docker && bundle install --deployment --without development test && \
    ([ -n "$VERSION" ] && echo "{'build_name': '$VERSION'}" > version.json) || true && \
    apt-get -y remove build-essential ruby2.3-dev libpq-dev libxml2-dev zlib1g-dev libmagic-dev libmagickwand-dev git-core yarn nodejs && \
    apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* && \
    rm -rf tmp/cache/* node_modules/ /var/lib/gems/2.3.0/cache/ vendor/bundle/ruby/2.3.0/cache /root/.bundle/ /usr/local/share/.cache/

WORKDIR /app
VOLUME /app/public/uploads

EXPOSE 3000

ENTRYPOINT ["./script/docker-entrypoint.sh"]
# Use front by default. async and sync 'modes' are available
CMD ["front"]

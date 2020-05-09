# gets the docker image of ruby 2.5 and lets us build on top of that
FROM ruby:2.6.3-slim

# install rails dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libsqlite3-dev curl imagemagick wget

RUN apt-get install libc6-dev \
  && wget http://www.freetds.org/files/stable/freetds-1.1.24.tar.gz \
  && tar -xzvf freetds-1.1.24.tar.gz \
  && cd freetds-1.1.24 \
  && ./configure --prefix=/usr/local --with-tdsver=7.3 \
  && make \
  && make install

ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV RAILS_ROOT /tanager_app

RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile $RAILS_ROOT/Gemfile
COPY Gemfile.lock $RAILS_ROOT/Gemfile.lock

# Run bundle install to install gems inside the gemfile
RUN gem install bundler --version "2.1.4"
RUN bundle install

# Copy the whole app
COPY . $RAILS_ROOT

CMD ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]

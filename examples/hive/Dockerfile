FROM ruby:2.3.1
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN apt-get install -y --no-install-recommends apt-utils
RUN mkdir /home/hive
ADD . /home/hive
WORKDIR /home/hive
RUN gem unpack hive-io-1.0.0.gem --target vendor/gems/
RUN gem install hive-io-1.0.0.gem
RUN bundle install
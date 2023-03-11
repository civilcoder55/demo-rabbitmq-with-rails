FROM ruby:3.1.2-alpine

WORKDIR /app

RUN apk update && \
    apk add --no-cache \
    build-base tzdata sqlite-dev

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . /app

RUN chmod +x rails.sh

EXPOSE 3000
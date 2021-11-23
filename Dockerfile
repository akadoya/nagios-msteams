FROM manios/nagios:4.4.6

RUN apk update
RUN apk add --no-cache perl perl-libwww perl-json

RUN mkdir /app
WORKDIR /app

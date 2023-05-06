FROM manios/nagios:4.4.10

RUN apk update
RUN apk add --no-cache perl perl-libwww perl-json perl-lwp-protocol-https

RUN mkdir /app
WORKDIR /app

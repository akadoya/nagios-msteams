# Test kit

### Build

```
docker-compose up -d
```

- Nagios UI: http://localhost:8080 (nagiosadmin/nagios)

### Test

```
docker-compose exec -it nagios bash

bash-5.0# cd /opt/Custom-Nagios-Plugins/
bash-5.0# export NAGIOS_HOSTALIAS="hoge101" NAGIOS_SERVICEDESC="http" NAGIOS_SERVICESTATE="WARNING" NAGIOS_SERVICEOUTPUT="test output"
bash-5.0# ./nagios-msteams.pl --webhook 'https://your incoming webhook url'

// if you want to test a behavior through a proxy
bash-5.0# export https_proxy="http://proxy:8333"  ## or set your own
bash-5.0# ./nagios-msteams.pl --webhook 'https://your incoming webhook url'
```
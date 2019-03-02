# nagios-msteams
A Nagios plugin to send notifications to MS teams

## prerequisites

These perl modules need to be installed.

 - HTTP::Request
 - LWP::UserAgent
 - JSON

## usage

`--webhook` is required option. 
`--nagios_url` to add a link in the notification.

```
export NAGIOS_HOSTALIAS="hoge101" NAGIOS_SERVICEDESC="http" NAGIOS_SERVICESTATE="WARNING" NAGIOS_SERVICEOUTPUT="test output"
./nagios-msteams.pl --webhook 'https://your incoming webhook url'
```

## installation

1. place the script in nagios plugin directory
2. `chmod +x <path to Nagios plugin>/nagios-msteams.pl`
3. configure commands, contacts


# Reference

https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference?ranMID=24542&ranEAID=je6NUbpObpQ&ranSiteID=je6NUbpObpQ-M2yBpYvoiCsKiucg39ve7Q
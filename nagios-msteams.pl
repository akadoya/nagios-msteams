#!/usr/bin/perl

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use warnings;
use strict;

use Getopt::Long;
use HTTP::Request::Common qw(POST);
use HTTP::Status qw(is_client_error);
use LWP::UserAgent;
use JSON;

my %event;
my %nagios;
my @sections;
my @actions;
my @targets;
my $webhook = "https://outlook.office365.com/webhook/MISSING";
my $nagios_url = "";
my %color = ( 'OK' => '008000', 'WARNING' => 'ffff00', 'UNKNOWN' => '808080','CRITICAL' => 'ff0000',
              'UP' => '008000', 'DOWN' => 'ff0000', 'UNREACHABLE' => 'ff8700');
$event{'title'} = "Nagios Notification";
$event{'@type'} = "MessageCard";
$event{'@context'} = "https://schema.org/extensions";
$nagios{'HOSTNOTES'} = "not defined";


#
# Get command-line options
#
GetOptions ("webhook=s" => \$webhook, "nagios_url=s" => \$nagios_url )
or die("Error in command line arguments\n");

#
# Read Nagios events
#
while ((my $k, my $v) = each %ENV) {
    next unless $k =~ /^(?:NAGIOS|ICINGA)_(.*)$/;
    $nagios{$1} = $v;
    print STDERR "$1 is $nagios{$1}\n";
}

#
# Format message card
#
if (not length($nagios{'SERVICESTATE'})) {
    # if service state env is not defnined or empty, event is host notification.
    $nagios{'SERVICEDESC'} = "host status";
    $nagios{'SERVICESTATE'} = $nagios{'HOSTSTATE'};
    $nagios{'SERVICEOUTPUT'} = $nagios{'HOSTOUTPUT'};
}
if (not length($nagios{'HOSTALIAS'})) {
    $nagios{'HOSTALIAS'} = $nagios{'HOSTNAME'};
}
$event{'themeColor'} = $color{"$nagios{'SERVICESTATE'}"};
$event{'title'} = "$nagios{'HOSTALIAS'}/$nagios{'SERVICEDESC'} is $nagios{'SERVICESTATE'}";
$event{'summary'} = $event{'title'};
my @facts = ({
    'name' => "Host:",
    'value' => "$nagios{'HOSTALIAS'}"
   },{
    'name' => "Details:",
    'value' => "$nagios{'SERVICEOUTPUT'}"
});
my %section = ( 'facts' => \@facts, 'text' => "Host Notes: $nagios{'HOSTNOTES'}" );
push(@sections, \%section);
$event{'sections'} = \@sections;

if ($nagios_url ne '') {
  my %target = (
        'os' => 'default',
        'uri' => "$nagios_url/cgi-bin/status.cgi?host=$nagios{'HOSTNAME'}"
  );
  push(@targets, \%target);
  my %link = (
      '@type' => 'OpenUri',
      'name' => 'View in Nagios',
      'targets' => \@targets
  );
  push(@actions, \%link);
  $event{'potentialAction'} = \@actions;
}
my $json = encode_json \%event;


#
# Make the request
#

my $ua = LWP::UserAgent->new;
$ua->timeout(15);
$ua->env_proxy;

my $req = HTTP::Request->new('POST', $webhook);
$req->header('Content-Type' => 'application/json');
$req->content($json);

my $s = $req->as_string;
print STDERR "Request:\n$s\n";

my $resp = $ua->request($req);
$s = $resp->as_string;
print STDERR "Response:\n$s\n";

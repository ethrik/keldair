#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);

my $bits;
$bits = $ARGV[0] if $ARGV[0];
$bits ||= 1024;

system "openssl genrsa -des3 -out keldair.key $bits";
system 'openssl req -new -key keldair.key -out keldair.csr';
system 'openssl x509 -req -days 365 -in keldair.csr -signkey keldair.key -out keldair.cert';
system 'cat keldair.cert keldair.key > keldair.pem';
system "mv ./keldair.pem $Bin/../etc"; 

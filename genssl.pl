#!/usr/bin/env perl
use strict;
use warnings;

system 'openssl genrsa -des3 -out keldair.key 1024';
system 'openssl req -new -key keldair.key -out keldair.csr';
system 'openssl x509 -req -days 365 -in keldair.csr -signkey keldair.key -out keldair.cert';


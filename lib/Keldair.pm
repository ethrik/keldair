# Keldair.pm - IRC client library
# Copyright 2011 Alexandria M. Wolcott <alyx@woomoo.org>
# Licensed under the 3-clause BSD.
package Keldair;
use strict;
use warnings;
use Class::Keldair;
use Sys::Hostname;
use base 'Exporter';
our @EXPORT = qw($keldair *HOOK_DENY *HOOK_PASS *HOOK_DENY_EAT *HOOK_PASS_EAT);

our (%V) = (
    'MAJOR' => 0,
    'MINOR' => 0,
    'PATCH' => 0
);

our $VERSION = "$V{MAJOR}.$V{MINOR}.$V{PATCH}";
our $keldair = Class::Keldair->new();

$keldair->hook_add(OnPreConnect => sub {
	$keldair->raw("PASS ".$keldair->config('server/password')) if $keldair->config('server/password');
	$keldair->raw("NICK ".$keldair->nick);
	$keldair->raw("USER ".$keldair->ident.' '.hostname.' '.$keldair->config('server/address')." :".$keldair->realname);
});

$keldair->hook_add(OnConnect => sub {
	$keldair->joinChannel($keldair->home);
});

*HOOK_PASS = 1; 		# Allow action to proceed.
*HOOK_DENY = 2; 		# Do not allow action to proceed.
*HOOK_DENY_EAT = -2;	# Do not allow action to proceed, and eat event.
*HOOK_PASS_EAT = -1;	# Allow action to proceed, and eat event.

# DENY = 1/-1
# PASS = 2/-1

1;

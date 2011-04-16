# Keldair.pm - IRC client library
# Copyright 2011 Alexandria M. Wolcott <alyx@woomoo.org>
# Licensed under the 3-clause BSD.
package Keldair;
use strict;
use warnings;
use FindBin qw($Bin);
use Class::Keldair;
use Sys::Hostname;
use base 'Exporter';
our @EXPORT = qw($keldair &HOOK_DENY &HOOK_PASS &HOOK_DENY_EAT &HOOK_PASS_EAT &TIMER_ONCE &TIMER_REPEAT);

our (%V) = (
    'MAJOR' => 3,
    'MINOR' => 8,
    'PATCH' => 2,
);

our $VERSION = "$V{MAJOR}.$V{MINOR}.$V{PATCH}";
our $keldair = Class::Keldair->new();

#my $db = $keldair->conf->get('database');
#if (!$db || -w $db) {
#    $db = "$Bin/../etc/keldair.db";
#}
#Config::JSON->create($db) if (-w $db);
#our $database = Config::JSON->new($db);

$keldair->hook_add(OnPreConnect => sub {
	my $network = shift;
	$keldair->raw($network, "PASS ".$keldair->config("networks/$network/server/password")) if $keldair->config("networks/$network/server/password");
	$keldair->raw($network, "USER ".$keldair->config("networks/$network/keldair/ident").' '.hostname.' '.$keldair->config("networks/$network/server/host")." :".$keldair->config("networks/$network/keldair/name"));
	$keldair->raw($network, "NICK ".$keldair->config("networks/$network/keldair/nick"));
});

$keldair->hook_add(OnConnect => sub {
	my $network = shift;
    #$keldair->joinChannel($network, $keldair->config("networks/$network/channels/home);
    my $channels = $keldair->config("networks/$network/channels");
    $keldair->joinChannel($network,$_) foreach @{ $channels };
});

local $SIG{__WARN__} = sub {
	for my $warn (@_)
	{
		$keldair->log(ERROR => $warn);
		print $warn;
	}
};

local $SIG{__DIE__} = sub {
	for my $die (@_)
	{
		$keldair->log(ERROR => $die);
		print $die;
	}
};

# Define constants for hooks.
sub HOOK_PASS () { 1; } # Allow action to proceed.
sub HOOK_DENY () { 2; } # Do not allow action to proceed.
sub HOOK_DENY_EAT () { -2; } # Do not allow action to proceed, and eat event.
sub HOOK_PASS_EAT () { -1; } # Allow action to proceed, and eat event.


# DENY = 1/-1
# PASS = 2/-1

1;

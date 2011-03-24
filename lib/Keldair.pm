# Keldair.pm - IRC client library
# Copyright 2011 Alexandria M. Wolcott <alyx@woomoo.org>
# Licensed under the 3-clause BSD.
package Keldair;
use strict;
use warnings;
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

sub HOOK_PASS () { 1; } # Allow action to proceed.
sub HOOK_DENY () { 2; } # Do not allow action to proceed.
sub HOOK_DENY_EAT () { -2; } # Do not allow action to proceed, and eat event.
sub HOOK_PASS_EAT () { -1; } # Allow action to proceed, and eat event.


# Timer constant magics.
sub TIMER_ONCE () { 1; } # Have the timer only run once.
sub TIMER_REPEAT () { 2; } # Have the timer repeat continuously.

# DENY = 1/-1
# PASS = 2/-1

1;

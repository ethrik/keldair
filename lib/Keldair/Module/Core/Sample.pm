# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::Module::Core::Sample;
use Keldair;
use strict;
use warnings;

$keldair->hook_add(OnJoin => sub {
	my ($network, $chan, $nick) = @_;
	$keldair->msg($network, $chan, "Hi, $nick!") unless $nick eq $keldair->nick;
});

$keldair->hook_add(OnBotPreJoin => sub {
	my ($network, $chan) = @_;
	return HOOK_DENY if $chan eq '#dev';
});

1;

# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Keldair::Module::Sample;
use Keldair;
use strict;
use warnings;

$keldair->hook_add(OnJoin => sub {
	my ($chan, $nick) = @_;
	#$keldair->msg($chan, "Hi, $nick!") unless $nick eq $keldair->nick;
});

$keldair->hook_add(OnBotPreJoin => sub {
	my ($chan) = @_;
	return *HOOK_DENY if $chan eq '#dev';
});

$keldair->schedule(sub {
	for my $chan ($keldair->channel_pairs())
	{
		$keldair->msg($chan->[1], 'Yay, 60s timer works!');
		return 1;
	}
});

1;

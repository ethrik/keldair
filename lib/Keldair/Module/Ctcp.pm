# Ctcp.pm - CTCP handler for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::Module::Ctcp;
use Keldair;
use Keldair::State;
use strict;
use warnings;

$keldair->hook_add(OnMessage => sub {
	my ($network, $chan, $nick, @msg) = @_;
	
	if ($msg[0] =~ /\001(.*)\001/) {
		my (@content) = split(/ /,$1);
		$keldair->msg($network,$nick, "\001$Keldair::State::ctcp{$content[0]}\001")
		  if ($Keldair::State::ctcp{$content[0]};
	}
}

1;

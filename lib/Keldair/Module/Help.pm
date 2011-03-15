# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Keldair::Module::Help;
use Keldair;
use strict;
use warnings;
use Data::Dumper;

$keldair->command_bind(HELP => sub {
	my ($chan, $nick, $cmd) = @_;
	
	my @list;
	for my $cmd ($keldair->command_pairs)
	{
		push @list, $cmd->[0];
	}
	$keldair->msg($chan, "@list");
});

1;

# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011
package Keldair::CoreCommands;
use strict;
use warnings;
use Keldair;

$keldair->command_bind(DIE => sub {
	my ($chan, $nick, @reason) = @_;

	$keldair->quit((join ' ', @reason));
	$keldair->log(INFO => "Shutting down by request of $nick from $chan.", 1);
});

$keldair->command_bind(RESTART => sub {
	my ($chan, $nick, $reason) = @_;

	system 'perl keldair';
	$keldair->quit($reason);
	$keldair->log(INFO => "Restarting by request of $nick from $chan.", 1);
});

$keldair->command_bind(EVAL => sub {
	my ($chan, $nick, @expr) = @_;
	if(!defined $expr[0])
	{
		$keldair->msg($chan, "Syntax: \002EVAL\002 <expression>");
		return;
	}
	
	my $expr = join ' ', @expr;
	my $result = eval $expr;

	$keldair->msg($chan, $result) if defined $result;
	$keldair->msg($chan, $@) if $@;
	$keldair->msg($chan, 'Done.');
});

$keldair->command_bind(REHASH => sub {
	my ($chan, $nick) = @_;

	$keldair->hook_run(OnRehash => $chan, $nick);
	$keldair->log(INFO => "$nick is rehashing keldair.conf.")
});

1;

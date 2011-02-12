# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011
package Keldair::CoreCommands;
use strict;
use warnings;
use Keldair;

$keldair->command_bind(DIE => sub {
	my ($chan_p, $dst, @reason) = @_;

	my $nick = $dst->nick;
	my $chan = $chan_p->name;

	$keldair->quit((join ' ', @reason));
	$keldair->log(INFO => "Shutting down by request of $nick from $chan.", 1);
});

$keldair->command_bind(RESTART => sub {
	my ($chan_p, $dst, $reason) = @_;

	my $nick = $dst->nick;
	my $chan = $chan_p->name;

	system 'perl keldair';
	$keldair->quit($reason);
	$keldair->log(INFO => "Restarting by request of $nick from $chan.", 1);
});

$keldair->command_bind(EVAL => sub {
	my ($chan, $dst, @expr) = @_;
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
	my ($chan, $dst) = @_;

	$keldair->hook_run(OnRehash => $chan, $dst);
	$keldair->msg($chan, 'Rehashing keldair.conf.');
	$keldair->log(INFO => $dst->nick.' is rehashing keldair.conf.')
});

$keldair->command_bind(PING => sub {
	my ($chan, $dst) = @_;
	$keldair->msg($chan, '%s: Pong!', $dst->nick);
});

1;

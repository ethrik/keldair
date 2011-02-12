# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Keldair::Module::Help;
use Keldair;
use strict;
use warnings;

$keldair->hook_add(OnMessage => sub {
	my ($chan, $nick, @msg) = @_;
	
	my $trigger = $keldair->config('keldair/trigger');
	my $msg = join ' ', @msg;

	my $cmd = substr $msg, length $trigger;
	$cmd = (split ' ', $cmd)[0];
	return 0 if !defined $cmd;
	
	my $_trigger = substr $msg, 0, (length $trigger);

	return 0 unless $trigger eq $_trigger;

	my $trig_and_cmd = length($cmd) + length($trigger);
	my $args = substr $msg, $trig_and_cmd;
	my @args = split ' ', $args;

	my $exec_cmd = $keldair->command_get(uc $cmd);
	if($exec_cmd)
	{
		$exec_cmd->($chan, $nick, @args);
	}
	else
	{
		$keldair->msg($chan, (uc $cmd).": No such command.");
	}
});

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

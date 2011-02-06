package Keldair::CoreCommands;
use strict;
use warnings;
use Keldair;

$keldair->command_bind(DIE => sub {
	my ($chan, $nick, $reason) = @_;

	$keldair->quit($reason);
	$keldair->log(INFO => "Shutting down by request of $nick from $chan.", 1);
});

$keldair->command_bind(RESTART => sub {
	my ($chan, $nick, $reason) = @_;

	system 'perl keldair';
	$keldair->quit($reason);
	$keldair->log(INFO => "Restarting by request of $nick from $chan.", 1);
});

1;

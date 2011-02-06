package Keldair::Module::Help;
use Keldair;

$keldair->hook_add(PRIVMSG => cmd => sub {
	my ($chan, $nick, @msg) = @_;
	my $trigger = $keldair->config('keldair/trigger');
	my $msg = join ' ', @msg;
	
	return if length $msg < length $trigger;

	my $cmd = substr $msg, (length $trigger);
	
	my $_trigger = substr($msg,-(length($msg)), (length $trigger));	
	return if $_trigger ne $trigger;
	
	my @args = split ' ', $msg, 2;
	
	if(!$keldair->command_run(lc $cmd, $chan, $nick, @msg))
	{
		$keldair->msg($chan, "$cmd No such command");
	}
});

$keldair->command_bind(HELP => sub {
	my ($chan, $nick, $cmd) = @_;
	
	my @list;
	for my $cmd ($keldair->command_pairs)
	{
		push @list, $cmd->[0];
		$keldair->msg($chan, "@list");
	}
});

1;

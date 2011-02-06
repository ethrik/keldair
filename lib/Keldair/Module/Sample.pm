package Keldair::Module::Sample;
use Keldair;

$keldair->hook_add(JOIN => greet => sub {
	my ($chan, $nick) = @_;
	$keldair->msg($chan, "Hi, $nick!") unless $nick eq $keldair->nick;
});

$keldair->command_bind(DIE => sub {
	my ($chan, $nick, @reason) = @_;
	$keldair->shutdown("($nick) @reason");
});

1;

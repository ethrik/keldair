package Test;
use Keldair;

$keldair->hook_add(JOIN => greet => sub {
	my ($chan, $nick) = @_;
	$keldair->msg($chan, "Hi, $nick!") unless $nick eq $keldair->nick;
});

1;

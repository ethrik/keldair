package Keldair::State;
use strict;
use warnings;
use Keldair;
use Class::Channel;
use Class::User;

$keldair->hook_add(OnJoin => sub {
	my ($nick, $chan) = @_;
	$keldair->raw("WHO $chan");
	
	my $_chan = Class::Channel->new(name => $chan);
	
	$keldair->add_chan($chan, $_chan);
});

$keldair->hook_add(OnRaw352 => sub {
		my ($chan, $ident, $host, $server, $nick, $flags, $real) = @_;
		my $user = Class::User->new(
			nick => $nick,
			ident => $ident,
			realname => $ident,
			host => $host,
			server => $server
		);

		$keldair->add_user($nick, $user); # will be over-written if it already exists so no reason to check before adding
		$keldair->find_chan($chan)->add_user($nick, $user);
	}
);

1;

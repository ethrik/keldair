# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::State;
use strict;
use warnings;
use Keldair;
use Class::Keldair::Channel;
use Class::Keldair::User;

my (%isupport, %ctcp);

our %STATS;

sub ctcp { 
	my ( $self, $method, $type, $response ) = @_;
	if ( $method eq 'add' ) {
		$ctcp{$type} = @_;
	}
	elsif ( $method eq 'del' ) {
		delete $ctcp{$type};
	}
}

$keldair->hook_add(OnJoin => sub {
	my ($network, $nick, $chan) = @_;
	$chan =~ s/:// if $chan =~ /^:(#|&|!).*/;
	$keldair->raw($network, "WHO $chan");
	
	my $_chan = Class::Keldair::Channel->new(name => $chan, network => $network);
	
	$keldair->add_chan($chan, $_chan);
});

$keldair->hook_add(OnRaw352 => sub {
		my ($network, $chan, $ident, $host, $server, $nick, $flags, $real) = @_;
		my $user = Class::Keldair::User->new(
			nick => $nick,
			ident => $ident,
			realname => $ident,
			host => $host,
			network => $network,
			server => $server
		);
		$keldair->log(STATE => "Adding $nick!$ident\@$host to $chan:Users - Adding $chan to $nick:Channels.");
		$keldair->add_user($nick, $user); # will be over-written if it already exists so no reason to check before adding
		$user->add_chan($chan, $keldair->find_chan($chan));
		$keldair->find_chan($chan)->add_user($nick, $user);
	}
);

$keldair->hook_add(OnKick => sub {
	my ($network, $nick, $chan, $target, $reason) = @_;
	$keldair->find_chan($chan)->del_user($target);
	$keldair->find_user($target)->del_chan($chan);
	$keldair->log(STATE => "$target KICKed from $chan\@$network - removed $target from $chan:Users - removed $chan from $target:Channels.");	
});

$keldair->hook_add(OnPart => sub {
	my ($network, $nick, $chan) = @_;
	$keldair->log(STATE => "$nick PARTed from $chan\@$network - removed $chan from $nick:Channels - removed $nick from $chan:Users.");	
});

$keldair->hook_add(OnMode => sub {
	
});

$keldair->hook_add(OnRaw005 => sub {
	my $network = shift;
	my $support = shift;

	my @info = split ' ', $support;

	foreach (@info)
	{
		if($_ =~ m/=/)
		{
			my ($key, $value) = split '=', $_;
			$isupport{$key} = $value;
			$keldair->log(ISUPPORT => "$key => $value");
		}
		elsif($_ =~ m/^[A-Z]+$/)
		{
			$isupport{$_} = 'ON';
			$keldair->log(ISUPPORT => "$_ is on.");
		}
	}
});

$keldair->hook_add(OnNick => sub {
    my ($net, $user, $nick) = @_;
    $keldair->logf(INFO => '%s changed nick to %s, updating in State.pm.', $user->nick, $nick);
    $user->nick($nick);
    return 0;
});

1;

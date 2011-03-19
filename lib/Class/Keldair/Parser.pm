# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair::Parser;
use Mouse::Role;
use strict;
use warnings;

my (%commands, %_commands);

%commands = (
	NOTICE => sub {
		my ($this, $network, $origin, $cmd, $target, @msg) = @_;
		
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin, 1)[0]; # just in case the server allowed the origin to have more than 1 '!' in the hostmask
		$nick = substr $nick, 1;

        my $message = join(' ', @msg );
		if($nick)
		{
			$this->hook_run(OnNotice => $network, $nick, $target, $message);
		}
		## Potential Bug
		# If the bot cannot find the nick by the '!', it will assume server notice
		# This will only cause problems on servers in huge violation of RFC
		else
		{
			my $servname = substr $origin, 1;
			$this->hook_run(OnServerNotice => $network, $servname, $target, $message);
		}
	},
	PRIVMSG => sub {
        my ($this, $network, $origin, $cmd, $target, @msg) = @_;
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin)[0];
		$nick = substr $nick, 1;
        my $message = join(' ', @msg);
        $this->hook_run(OnMessage => $network, $target, $nick, $message);
	},
	JOIN => sub {
		my ($this, $network, $origin, $cmd, $chan) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnJoin => $network, $nick, $chan);
	},
	PART => sub {
		my ($this, $network, $origin, $cmd, $chan) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnPart => $network, $nick, $chan);
	},
	KICK => sub {
		my ($this, $network, $origin, $cmd, $chan, $target, @reason) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnKick => $network, $nick, $chan, $target, (join ' ', @reason));
	},
	MODE => sub {
		my ($this, $network, $origin, $cmd, $target, $modemask, @args) = @_;
		my $nick = nick_from_host($origin);

		my (@chars, @adding, @removing, $set);

		@chars = split //, $modemask;

		foreach (@chars)
		{
			if($_ eq '+')
			{
				$set = '+';
				next;
			}
			elsif($_ eq '-')
			{
				$set = '-';
				next;
			}
			else
			{
				return if !defined $set;
				push @adding, $_ if $set eq '+';
				push @removing, $_ if $set eq '-';
			}
		}

		if($target =~ m/^\#/)
		{
			$this->find_chan($target)->add_mode($_, 'TODO') foreach (@adding);
			$this->find_chan($target)->del_mode($_, 'TODO') foreach (@removing);
		}
		else
		{
			my $user = $this->find_user($target);
			if($user)
			{
				$user->add_mode($_, 'TODO') foreach (@adding);
				$user->del_mode($_, 'TODO') foreach (@removing);
			}
			else
			{
				$this->log(PARSER => "Could not find user $target - not an object!");
			}
		}
		$this->hook_run(OnMode => $network, $nick, $target, $modemask, @args);
	},
	'001' => sub {
		my ($this, $network, $server, @welcome) = @_;
		$this->hook_run(OnConnect => $network, $server, @welcome);
	},
	'352' => sub {
		# :slipknot.woomoo.org 352 Keldair #dev sam usr-bin-perl.use-strict.use-warnings slipknot.woomoo.org miniCruzer H*! :0 Only One
		my ($this, $network, $origin, $numeric, $me, $chan, $ident, $host, $server, $nick, $flags, @real) = @_;
		my $r = shift @real;
		$r = substr $r, 1;
		unshift @real, $r;
		my $real = join ' ', @real;	
		
		$this->hook_run(OnRaw352 => $network, $chan, $ident, $host, $server, $nick, $flags, $real);
	},
	'005' => sub {
		my ($this, $network, $origin, $num, $me, @support) = @_;
		my $support = join ' ', @support;
		
		$this->hook_run(OnRaw005 => $network, $support);
	}
);

%_commands = (
	PING => sub {
		my ($this, $network, $cmd, $str) = @_;
		$this->raw($network, "PONG $str");
	}
);

## parse(str)
# Start parsing an IRC line.
# @line \n-Terminated line from the server
sub parse {
	my ($this, $network, $line) = @_;
	$this->log(WARN => 'parse(): Did not get an IRC line when called!', 1) if !$line;
	my @s = split / /, $line;
	
	if(exists $commands{uc($s[1])})
	{
		$commands{uc($s[1])}->($this, $network, @s);
	}
	if(exists $_commands{uc($s[0])})
	{
		$_commands{uc($s[0])}->($this, $network, @s);
	}
}

sub nick_from_host {
	my ($host) = @_;
	my $nick = (split /!/, $host)[0];
	$nick = substr $nick, 1;
	return $nick if $nick;
}

1;

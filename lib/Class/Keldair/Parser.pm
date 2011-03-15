# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011
package Class::Keldair::Parser;
use Mouse::Role;
use strict;
use warnings;

my (%commands, %_commands);

%commands = (
	NOTICE => sub {
		my ($this, $origin, $cmd, $target, @msg) = @_;
		
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin, 1)[0]; # just in case the server allowed the origin to have more than 1 '!' in the hostmask
		$nick = substr $nick, 1;

		if($nick)
		{
			$this->hook_run(OnNotice => $nick, $target, @msg);
		}
		## Potential Bug
		# If the bot cannot find the nick by the '!', it will assume server notice
		# This will only cause problems on servers in huge violation of RFC
		else
		{
			my $servname = substr $origin, 1;
			$this->hook_run(OnServerNotice => $servname, $target, @msg);
		}
	},
	PRIVMSG => sub {
		# R: :miniCruzer!sam@usr-bin-perl.use-strict.use-warnings PRIVMSG #dev :hot
		my ($this, $origin, $cmd, $target, @msg) = @_;
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin)[0];
		$nick = substr $nick, 1;
		
		$this->hook_run(OnMessage => $target, $nick, @msg);
	},
	JOIN => sub {
		my ($this, $origin, $cmd, $chan) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnJoin => $nick, $chan);
	},
	PART => sub {
		my ($this, $origin, $cmd, $chan) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnPart => $nick, $chan);
	},
	KICK => sub {
		my ($this, $origin, $cmd, $chan, $target, @reason) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnKick => $nick, $chan, $target, (join ' ', @reason));
	},
	MODE => sub {
		my ($this, $origin, $cmd, $target, $modemask, @args) = @_;
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
		$this->hook_run(OnMode => $nick, $target, $modemask, @args);
	},
	'001' => sub {
		my ($this, $server, @welcome) = @_;
		$this->hook_run(OnConnect => $server, @welcome);
	},
	'352' => sub {
		# :slipknot.woomoo.org 352 Keldair #dev sam usr-bin-perl.use-strict.use-warnings slipknot.woomoo.org miniCruzer H*! :0 Only One
		my ($this, $origin, $numeric, $me, $chan, $ident, $host, $server, $nick, $flags, @real) = @_;
		my $r = shift @real;
		$r = substr $r, 1;
		unshift @real, $r;
		my $real = join ' ', @real;	
		
		$this->hook_run(OnRaw352 => $chan, $ident, $host, $server, $nick, $flags, $real);
	},
	'005' => sub {
		my ($this, $origin, $num, $me, @support) = @_;
		my $support = join ' ', @support;
		
		$this->hook_run(OnRaw005 => $support);
	}
);

%_commands = (
	PING => sub {
		my ($this, $cmd, $str) = @_;
		$this->raw("PONG $str");
	}
);

## parse(str)
# Start parsing an IRC line.
# @line \n-Terminated line from the server
sub parse {
	my ($this, $line) = @_;
	$this->log(WARN => 'parse(): Did not get an IRC line when called!', 1) if !$line;
	my @s = split / /, $line;
	
	if(exists $commands{uc($s[1])})
	{
		$commands{uc($s[1])}->($this, @s);
	}
	if(exists $_commands{uc($s[0])})
	{
		$_commands{uc($s[0])}->($this, @s);
	}
}

sub nick_from_host {
	my ($host) = @_;
	my $nick = (split /!/, $host)[0];
	$nick = substr $nick, 1;
	return $nick if $nick;
}

1;

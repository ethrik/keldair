# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair;
use Mouse;
use Config::JSON;
use IO::Socket::IP;
use Module::Load;
use Keldair;
use FindBin qw($Bin);

with 'Class::Keldair::Parser', 'Class::Keldair::Interface', 'Class::Keldair::Commands';

# soemone will probably want to move this to a different location later...
my $conf = "$Bin/../etc/keldair.conf";
$conf = $ENV{HOME}."/.keldair/keldair.conf" if $Bin eq "/usr/bin";
my $config = Config::JSON->new($conf);
our $socket;

## nick(str)
# Nickname to register with - this may be truncated depending on length limit on server.
# @default Nick as found in keldair.conf
has 'nick' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
	default => $config->get('keldair/nick')
);

## ident(str)
# "Username" to register connection with. May NOT have spaces
# @default Ident found in keldair.conf
has 'ident' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
	default => $config->get('keldair/ident')
);

## realname(str)
# GECOS for the bot client
# @default Find the realname string from keldair.conf
has 'realname' => (
	isa => 'Str',
	required => 1,
	is => 'rw',
	default => $config->get('keldair/realname')
);

## server(str)
# Server address to connect to
# @default Finds the server address from keldair.conf
has 'server' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
	default => $config->get('server/address')
);

## port(int)
# Connect to the server over this numeric port
# @defualt Uses port value in keldair.conf
has 'port' => (
	isa => 'Int',
	is => 'rw',
	required => 1,
	default => $config->get('server/port')
);

## usessl(int)
# Connect over Secure Socket Layers to the server
# @default Retrieves value from the config in 1/0 - True/False format
has 'usessl' => (
	isa => 'Int',
	is => 'rw',
	default => $config->get('server/usessl')
);

## debug(int)
# Print IRC Input / Output between client and server
# @default Configuration value
has 'debug' => (
	isa => 'Int',
	is => 'rw',
	default => $config->get('keldair/debug')
);

## home(str)
# Home channel to join when bot gets connected to the server
# @default Configuration value
has 'home' => (
	isa => 'Str',
	is => 'rw',
	default => $config->get('keldair/home')
);

## hooks { }
# Hash-Ref of event hooks on IRC
# Hook-Type => Anon. Subroutine
has 'hooks' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[CodeRef]',
	default => sub { {} },
	handles => {
		hook_set => 'set',
		hook_get => 'get',
		no_hooks => 'is_empty',
		hook_count => 'count',
		hook_del => 'delete',
		hook_list => 'kv'
	}
);

## users { }
# Internal user state for the bot, with users as objects
# Nick => Object
has 'users' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[Object]',
	default => sub { {} },
	handles => {
		add_user => 'set',
		find_user => 'get',
		no_users => 'is_empty',
		del_user => 'delete',
		user_pairs => 'kv'
	}
);

## channels { }
# Internal channel state for the bot
# Channel => Object
has 'channels' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[Object]',
	default => sub { {} },
	handles => {
		add_chan => 'set',
		find_chan => 'get',
		no_chans => 'is_empty',
		del_chan => 'delete',
		chan_pairs => 'kv'
	}
);

## hook_add(str, str, coderef)
# Hook to an IRC event
# @event IRC-Name of event (JOIN, PART, KICK, etc)
# @title Unique-Name:Signed-Integer, ex: act:1, act:-3 - determines which will be called first
# @sub Anonymous Subroutine reference for acting on the hook
sub hook_add {
	my ($this, $event, $sub) = @_;
	my $name = $event.'/'.caller;
	$this->log(HOOK => "Adding new hook: $name");
	$this->hook_set($name, $sub);
}

## hook_run(str, str, ...)
# Run all hooks of a particular event with a list of arguments
# @event IRC Event to run hooks with (JOIN, PART, KICK, etc)
# @args A list of args to run with the hook - you can send as many arguments as needed after the event str
sub hook_run {
	my ($this, $event, @args) = @_;
	$this->log(HOOK => "Running hooks for $event.");
	for my $hook ($this->hook_list)
	{
		my $_event = (split '/', $hook->[0])[0];

		if($_event eq $event)
		{
			my $res = $hook->[1]->(@args);
		
			if(defined $res)
			{
				if($res == -2)
				{
					$this->log(HOOK_EATEN => $hook->[0]." has eaten event $event (return -2).");
					return $res;
				}
				elsif($res == -1)
				{
					$this->log(HOOK_EATEN => $hook->[0]." has eaten event $event (return 1).");
					return $res;
				}
				return $res;
			}
			$this->log(HOOK => "Ran hook ".$hook->[0].".");
		}
	}
}

## config(str)
# Retrieve a config value from keldair.conf
# @directive JSON Directive where to find the value
# @return If Config::JSON can find the directive, the value is returned
#
# TODO: Turn this into the actual Config::JSON package (ie: $keldair->config->get(...), and $keldair->config->set(...)
sub config {
	my ($this, $directive) = @_;
	return $config->get($directive);
}

## log(str, str, int)
# Print to the logfile
# @level Type of log notice, usually DEBUG, WARN, or INFO
# @msg Simply the message to write to the logfile
# @exit 1/0 Should the bot exit after logging?
sub log {
	# this can be expanded to be more intense later
	my ($this, $level, $msg, $exit) = @_;
	open my $fh, '>>', $this->config('keldair/log') || die "Could not open ".$this->config('keldair/log')." for logging. $!\n";
	my $logtime = localtime;
	print {$fh} "[$logtime] $level: $msg\n";
	close $fh;
	if($exit)
	{
		die "$level: $msg\n";
	}
}

## logf(str, str, ...)
# Print to the logfile in an sprintf-style
# @level Type of log notice - can be anything
# @msg Message to print to the log - can contain %s/%u/%d/etc.
# @... Values to fill for any % variables used in $msg 
sub logf {
	my $this = shift;
	my $level = shift;

	my $msg = sprintf shift @_, @_;

	open my $fh, '>>', $this->config('keldair/log') || die "Could not open ".$this->config('keldair/log')." for logging. $!\n";
	my $logtime = localtime;
	print {$fh} "[$logtime] $level: $msg\n";
	close $fh;
}

## connect()
# Connect Keldair to the IRC server. Program will close if there an error after logging.
# @return Returns socket object indicating that the connection was successful.
# TODO: Bind to a host
sub connect {
	my ($this) = @_;
	
	if($this->usessl)
	{
		require IO::Socket::SSL;
		$socket = IO::Socket::SSL->new(
			PeerAddr => $this->server,
			PeerPort => $this->port,
			Proto => 'tcp',
			Timeout => 30,
			SSL_use_cert => 1,
			SSL_key_file => $config->get('keldair/key'),
			SSL_cert_file => $config->get('keldair/cert'),
			SSL_passwd_cb =>  sub { return $config->get('keldair/key_passwd') }
		) || $this->log(WARN => "Could not connect to IRC! $!", 1);
	}
	else
	{
		$socket = IO::Socket::IP->new(
			PeerAddr => $this->server,
			PeerPort => $this->port,
			Proto => 'tcp',
			Timeout => 30
		) || $this->log(WARN => "Could not connect to IRC! $!", 1);	
	}

	$this->log(INFO => 'Connected to IRC successfully.');
	return $socket;
}

sub modload {
	my ($this, $module) = @_;
	my $class = caller;
	
	my $res = $this->hook_run(OnPreModLoad => $module);
	
	if($res < 0)
	{
		$this->log(HOOK_EATEN => "OnPreModLoad: Not loading $module; stopped by $class.");
		return 0;
	}

	my $modr = $module;
	$modr =~ s#::#/#g;
	$modr .= '.pm';	

	if(-e "Keldair/Module/$modr")
	{
				
		if(eval{
			load 'Keldair::Module::'.$module;
			1;
		}) {
			$this->log(MODLOAD => "Successfully loaded $module.");
		} else {
			$this->log(WARN => "Could not load $module! $@");
			return 0;
		}
	} else {
		$this->logf(MODLOAD => 'Cannot find "%s" in Keldair::Module, searching in @INC.', $module);
		if(-e $modr)
		{
			if(eval{
				load $module;
				1;
			}) {
				$this->log(MODLOAD => "Successfully loaded $module, but it was found outside of Keldair::Module. Consider moving it...");
			} else {
				$this->log(WARN => "Could not load $module! $!");
				return 0;
			}
		} else {
			$this->log(WARN => "Could not load $module! Not found in Keldair::Module or in \@INC.");
			return 0;
		}
	}
	return 1;
}

# TODO: Turn CTCP into a hashref trait like hooks, etc., unless its not possible
sub ctcp_add {
	my ($this, $type, $response) = @_;
	Keldair::State->ctcp('add', $type,$response);
	return 1;
}

sub ctcp_del {
	my ($this, $type, $response) = @_;
	Keldair::State->ctcp('del', $type,$response);
}

1;
# vim: set number tabstop=4 shiftwidth=4 autoindent smartindent:

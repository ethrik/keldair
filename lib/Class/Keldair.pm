# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair;
use Mouse;
use Config::JSON;
use IO::Socket::IP;
use Module::Load;
use Keldair;
use FindBin qw($Bin);
use Class::Keldair::Connections;

with 'Class::Keldair::Parser', 'Class::Keldair::Interface', 'Class::Keldair::Commands';

# someone will probably want to move this to a different location later...
my $conf = "$Bin/../etc/keldair.conf";
$conf = $ENV{HOME}."/.keldair/keldair.conf" if $Bin eq "/usr/bin";

## conf
# Object to Config::JSON - uses all methods from this package,
# and is already pointed to default config.
has 'conf' => (
	is => 'rw',
	isa => 'Object',
	default => sub { new Config::JSON($conf) },
	required => 1
);

has 'manager' => (
    isa => 'Object',
    is => 'ro',
    default => sub { new Class::Keldair::Connections },
    required => 1
);

## debug(int)
# Print IRC Input / Output between client and server
# @default Configuration value
has 'debug' => (
	isa => 'Int',
	is => 'rw',
	default => sub {
		my $this = shift;
		$this->conf->get('debug');
	}
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
			my $res = eval { $hook->[1]->(@args) }
                or $this->log(ERROR => $hook->[0]." has errored: $@") and 
                return;
		
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
	return $this->conf->get($directive);
}

## log(str, str, int)
# Print to the logfile
# @level Type of log notice, usually DEBUG, WARN, or INFO
# @msg Simply the message to write to the logfile
# @exit 1/0 Should the bot exit after logging?
sub log {
	# this can be expanded to be more intense later
	my ($this, $level, $msg, $exit) = @_;
	open my $fh, '>>', $this->config('log') || die "Could not open ".$this->config('log')." for logging. $!\n";
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

	open my $fh, '>>', $this->config('log') || die "Could not open ".$this->conf->get('log')." for logging. $!\n";
	my $logtime = localtime;
	print {$fh} "[$logtime] $level: $msg\n";
	close $fh;
}

sub connect {
	my ($this, $network) = @_;
	if ($this->conf->get("networks/$network")) {
		$this->manager->add(name => $network, addr => $this->conf->get("networks/$network/server/host"), port => $this->conf->get("networks/$network/server/port"),
            bind => (defined $this->conf->get("networks/$network/server/vhost") ? $this->conf->get("networks/$network/server/vhost") : '0.0.0.0'),
            ssl => ($this->conf->get("networks/$network/server/ssl") ? 1 : 0) ) 
            and return 1 or return 0;
	}
	return;
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

    my $modres = eval {
        my ( $folder, $mod ) = split('/', $module);
        load("Keldair::Module::".ucfirst($folder)."::$mod");
        return 1;
        0;
    };
    if ($modres) {
        $this->logf(MODLOAD => 'Successfully loaded %s from Keldair::Module.', $module);
        return 1;
    }
    else {
        warn "Failed to load $module. Error: $@";
        $this->logf(MODLOAD => 'Failed to load %s. Error: %s', $module, $@);
    }
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

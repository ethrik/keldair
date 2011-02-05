# <Copyright Notice Here>
use Moose;
use Config::JSON;
package Class::Keldair;

# soemone will probably want to move this to a different location later...
my $config = Config::JSON->new('keldair.conf');
open my $logfile, '<', $config->get('keldair/log');

## nick(str)
# Nickname to register with - this may be truncated depending on length limit on server.
# @default Nick as found in keldair.conf
has 'nick' => (
	isa => 'Str',
	is => 'rw',
	default => $config->get('keldair/nick')
);

## ident(str)
# "Username" to register connection with. May NOT have spaces
# @default Ident found in keldair.conf
has 'ident' => (
	isa => 'Str',
	is => 'rw',
	default => $config->get('keldair/ident')
);

## realname(str)
# GECOS for the bot client
# @default Find the realname string from keldair.conf
has 'realname' => (
	isa => 'Str',
	is => 'rw',
	default => $config->get('keldair/realname')
);

## server(str)
# Server address to connect to
# @default Finds the server address from keldair.conf
has 'server' => (
	isa => 'Str',
	is => 'rw',
	default => $config->get('server/address')
);

## port(int)
# Connect to the server over this numeric port
# @defualt Uses port value in keldair.conf
has 'port' => (
	isa => 'Int',
	is => 'rw',
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

## config(str)
# Retrieve a config value from keldair.conf
# @directive JSON Directive where to find the value
# @return If Config::JSON can find the directive, the value is returned
sub config {
	my ($this, $directive) = @_;
	return $config->get($directive);
}

## log(str, str)
# Print to the logfile
# @level Type of log notice, usually DEBUG, WARN, or INFO
# @msg Simply the message to write to the logfile
sub log {
	# this can be expanded to be more intense later
	my ($this, $level, $msg) = @_;
	my $logtime = localtime;
	print $logfile "[$logtime] $level: $msg\n";
}

1;
# vim: set number tabstop=4 shiftwidth=4 autoindent smartindent:

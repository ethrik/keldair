# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair;
use Mouse;
use Config::JSON;
use IO::Socket::IP;
use Keldair::Protocol::Client;

# soemone will probably want to move this to a different location later...
my $config = Config::JSON->new("$Keldair::Bin/etc/keldair.conf");
my $socket;

## nick(str)
# Nickname to register with - this may be truncated depending on length limit on server.
# @default Nick as found in keldair.conf
has 'nick' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => $config->get('keldair/nick')
);

## ident(str)
# "Username" to register connection with. May NOT have spaces
# @default Ident found in keldair.conf
has 'ident' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => $config->get('keldair/ident')
);

## realname(str)
# GECOS for the bot client
# @default Find the realname string from keldair.conf
has 'realname' => (
    isa      => 'Str',
    required => 1,
    is       => 'rw',
    default  => $config->get('keldair/realname')
);

## server(str)
# Server address to connect to
# @default Finds the server address from keldair.conf
has 'server' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => $config->get('server/address')
);

## port(int)
# Connect to the server over this numeric port
# @defualt Uses port value in keldair.conf
has 'port' => (
    isa      => 'Int',
    is       => 'rw',
    required => 1,
    default  => $config->get('server/port')
);

## usessl(int)
# Connect over Secure Socket Layers to the server
# @default Retrieves value from the config in 1/0 - True/False format
has 'usessl' => (
    isa     => 'Int',
    is      => 'rw',
    default => $config->get('server/usessl')
);

## debug(int)
# Print IRC Input / Output between client and server
# @default Configuration value
has 'debug' => (
    isa     => 'Int',
    is      => 'rw',
    default => $config->get('keldair/debug')
);

## home(str)
# Home channel to join when bot gets connected to the server
# @default Configuration value
has 'home' => (
    isa     => 'Str',
    is      => 'rw',
    default => $config->get('keldair/home')
);

## hooks { }
# Hash-Ref of event hooks on IRC
# Hook-Type => Anon. Subroutine
has 'hooks' => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef[CodeRef]',
    default => sub { {} },
    handles => {
        hook_set   => 'set',
        hook_get   => 'get',
        no_hooks   => 'is_empty',
        hook_count => 'count',
        hook_del   => 'delete',
        hook_list  => 'kv'
    }
);

## hook_add(str, str, coderef)
# Hook to an IRC event
# @event IRC-Name of event (JOIN, PART, KICK, etc)
# @title Unique-Name:Signed-Integer, ex: act:1, act:-3 - determines which will be called first
# @sub Anonymous Subroutine reference for acting on the hook
sub hook_add {
    my ( $this, $event, $title, $sub ) = @_;
    my $name = $event . '/' . $title;
    $this->log( HOOK => "Adding new hook: $name" );
    $this->hook_set( $name, $sub );
}

## hook_run(str, str, ...)
# Run all hooks of a particular event with a list of arguments
# @event IRC Event to run hooks with (JOIN, PART, KICK, etc)
# @args A list of args to run with the hook - you can send as many arguments as needed after the event str
sub hook_run {
    my ( $this, $event, @args ) = @_;

    for my $hook ( $this->hook_list ) {
        my $_event = ( split '/', $hook->[0] )[0];

        if ( $_event eq $event ) {
            $hook->[1]->(@args);
        }
    }
}

## config(str)
# Retrieve a config value from keldair.conf
# @directive JSON Directive where to find the value
# @return If Config::JSON can find the directive, the value is returned
sub config {
    my ( $this, $directive ) = @_;
    return $config->get($directive);
}

## log(str, str, int)
# Print to the logfile
# @level Type of log notice, usually DEBUG, WARN, or INFO
# @msg Simply the message to write to the logfile
# @exit 1/0 Should the bot exit after logging?
sub log {

    # this can be expanded to be more intense later
    my ( $this, $level, $msg, $exit ) = @_;
    open (my $fh, '>>',
      $this->config('keldair/log'))
      || die "Could not open "
      . $this->config('keldair/log')
      . " for logging. $!\n";
    my $logtime = localtime;
    print {$fh} "[$logtime] $level: $msg\n";
    close $fh;
    if ($exit) {
        die "$level: $msg\n";
    }
}

## connect()
# Connect Keldair to the IRC server. Program will close if there an error after logging.
# @return Returns socket object indicating that the connection was successful.
sub connect {
    my ($this) = @_;
    if ( $this->usessl ) {
        require IO::Socket::SSL;
        $socket = IO::Socket::SSL->new(
            PeerAddr => $this->server,
            PeerPort => $this->port,
            Proto    => 'tcp',
            Timeout  => 30
        ) || $this->log( WARN => "Could not connect to IRC! $!", 1 );
    }
    else {
        $socket = IO::Socket::IP->new(
            PeerAddr => $this->server,
            PeerPort => $this->port,
            Proto    => 'tcp',
            Timeout  => 30
        ) || $this->log( WARN => "Could not connect to IRC! $!", 1 );
    }

    $this->log( INFO => 'Connected to IRC successfully.' );
    return $socket;
}

## raw(str)
# Print a raw line to the socket, ending in a newline (\n)
# @dat Data to send to the socket - don't end it with \n
sub raw {
    my ( $this, $dat ) = @_;
    print $socket "$dat\n";
    print "S: $dat\n" if $this->debug;
}

## joinChannel(str)
# Attempt to join a channel
# @chan Channel to join
sub joinChannel {
    my ( $this, $chan ) = @_;
    $this->raw("JOIN $chan");
}

## parse(str)
# Start parsing an IRC line.
# @line \n-Terminated line from the server
my $registered = 0;

sub parse {
    my ( $this, $line ) = @_;

  # This will simply register connection, handle ping, and join channel for now.

    $this->log( WARN => 'parse(): Did not get an IRC line when called!', 1 )
      if !$line;

    my @s = split / /, $line;

    if ( $s[1] eq 'NOTICE' ) {
        return unless $s[2] eq '*';
        return if $registered;
        $this->raw( 'NICK ' . $this->nick );
        $this->raw( 'USER ' . $this->ident . ' 8 * :' . $this->realname );
        $this->log( INFO => 'Registered connection to server.' );
        $registered = 1;
    }
    if ( $s[1] eq '001' ) {
        $this->log( INFO =>
              'Server has accepted my connection, joining the home channel.' );
        $this->joinChannel( $this->home );
    }
    if ( $s[1] eq 'JOIN' ) {
        my $nick = ( split '!', $s[0] )[0];
        $nick = substr $nick, 1;
        my $chan = $s[2];
        $this->hook_run( JOIN => $chan, $nick );
    }
    if ( $s[0] eq 'PING' ) {
        $this->raw("PONG $s[1]");
    }
}

1;

# vim: set number tabstop=4 shiftwidth=4 autoindent smartindent:

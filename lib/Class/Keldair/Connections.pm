# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
#
# CONVERT THIS TO MOOSE/MOUSE...

package Class::Keldair::Connections;
use feature qw(say);
use IO qw(Socket Select);
use IO::Socket::IP

our %sockets = ();

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	$self->{selector} = IO::Select->new;
	return $self;
}

sub add {
	my ($self, %params) = @_;
	return 0 if (!defined $params{name} or !defined $params{addr} or !defined $params{port});
	return 0 if defined $self->{sockets}->{$params{name}};
	$self->{sockets}->{$params{name}} = IO::Socket::IP->new(Proto => 'tcp', PeerAddr => $params{addr}, PeerPort => $params{port}, Timeout => (defined $params{timeout} ? $params{timeout} : 30), LocalHost => (defined $params{bind} ? $params{bind} : '0.0.0.0' ) ) or say("ERROR: $@") and return 0;	
	binmode( $self->{sockets}->{$params{name}}, ':encoding(UTF-8)' );
    $self->{selector}->add($self->{sockets}->{$params{name}}) and return $self->{sockets}->{$params{name}} or say("ERROR: $!") and return 0;
	return;
}

sub del {
	my ($self, %params) = @_;
	return 0 if !$params{name};
	return 0 if !$self->{selector}->exists($self->{sockets}->{$params{name}}) and !defined $self->{sockets}->{$params{name}};
	delete $self->{sockets}->{$params{name}};
	$self->{selector}->remove($self->{sockets}->{params{'name'}}) and return 1;
	return;
}

sub write {
	my ($self, $sock, $data) = @_;
	# XXX: We should be deleting the selector if the socket is dead or vice versa. Same for above sub.
	return 0 if !$self->{selector}->exists($self->{sockets}->{$sock}) or !defined $self->{sockets}->{$sock};
	$self->{sockets}->{$sock}->send("$data\r\n");
	return;
}

1;

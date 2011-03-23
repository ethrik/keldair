# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair::Net;
use Mouse;

has 'nick' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'ident' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'host' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'realname' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'server' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'network' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'modes' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[Str]',
	default => sub { {} },
	handles => {
		add_mode => 'set',
		has_mode => 'get',
		del_mode => 'delete',
		no_modes => 'is_empty',
		mode_pairs => 'kv'
	}
);

has 'socket' => (
	is => 'ro',
	isa => 'Object',
	default => sub {
		my $this = shift; # The entire bot scope (config included)
		# CREATE NORMAL SOCKET HEE!!!
		IO::Socket::INET->new(...);
	}
);

1;

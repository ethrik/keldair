# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair::User;
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

has 'channels' => (
        traits => ['Hash'],
        is => 'ro',
        isa => 'HashRef[Object]',
        default => sub { {} },
        handles => {
                add_chan => 'set',
                is_in => 'get',
                no_chans => 'is_empty',
                del_chan => 'delete',
                chan_pairs => 'kv'
        }
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

## isa(str)
# @isa If this equals 'user', it will return 1
sub isa {
	my ($this, $isa) = @_;
	return 1 if $isa eq 'user';
}


sub name {
	my $this = shift;
	return $this->nick;
}

1;

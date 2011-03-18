# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Class::Keldair::Channel;
use Mouse;

has 'name' => (
	isa => 'Str',
	is => 'rw',
	required => 1
);

has 'topic' => (
	isa => 'Str',
	is => 'rw'
);

has 'users' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[Object]',
	default => sub { {} },
	handles => {
		add_user => 'set',
		has_user => 'get',
		no_users => 'is_empty',
		del_user => 'delete',
		user_pairs => 'kv'
	}
);

### modes(modechar, RPL)
## add_mode(char, RPL)
# Add's the mode to the channel, and its RPL description
## has_mode(char)
# @return RPL for the char if it is set
## del_mode(char)
# Delete the mode character from the channel
has 'modes' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[Str]',
	default => sub { {} },
	handles => {
		add_mode => 'set',
		has_mode => 'get',
		no_modes => 'is_empty',
		del_mode => 'delete',
		mode_pairs => 'kv'
	}
);

## isa(str)
# @isa If this variable equals 'channel', it will return 1
sub isa {
	my ($this, $isa) = @_;
	return 1 if(lc($isa) eq 'channel');
}

1;

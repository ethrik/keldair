package Class::User;
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


1;

package Class::Channel;
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
	is => 'rw',
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

1;

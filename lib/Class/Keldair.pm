# <Copyright Notice Here>
use Moose;
package Class::Keldair;

has 'nick' => (
	isa => 'Str',
	is => 'rw',
	default => 'Keldair'
);

has 'ident' => (
	isa => 'Str',
	is => 'rw',
	default => 'keldair'
);

has 'realname' => (
	isa => 'Str',
	is => 'rw',
	default => 'Keldair IRC Bot'
);

has 'server' => (
	isa => 'Str',
	is => 'rw',
	default => 'irc.sporksmoo.net'
);

has 'port' => (
	isa => 'Int',
	is => 'rw',
	default => 6667
);

has 'usessl' => (
	isa => 'Int',
	is => 'rw',
	default => 0
);

1;
# vim: set number tabstop=4 shiftwidth=4 autoindent smartindent:

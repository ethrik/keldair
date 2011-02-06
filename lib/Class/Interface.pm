package Class::Interface;
use Mouse::Role;
use strict;
use warnings;

has 'commands' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[CodeRef]',
	default => sub { {} },
	handles => {
		command_bind => 'set',
		command_get => 'get',
		command_empty => 'is_empty',
		command_count => 'count',
		command_unbind => 'delete',
		command_pairs => 'kv'
	}
);

## command_bind(str, code)
# Bind a command to the interface
# @cmd Command name as accessed by a user
# @sub Anonymous subroutine or a reference to a named one - please use anonymous!

## command_unbind(str)
# Unbind a command from the interface
# @cmd Command name to unbind

## command_run(str, ...)
# Run a command with a list of arguments
# @cmd Command name to run - casing does not matter
# @args List of arguments to pass to the command
sub command_run {
	my ($this, $cmd, @args) = @_;
	if($this->command_get(lc($cmd)))
	{
		$this->command_get(lc($cmd))->(@args);
		return 1;
	}

	return 0;
}

1;
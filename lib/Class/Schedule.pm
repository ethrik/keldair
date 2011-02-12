# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Class::Schedule;
use Mouse::Role;
use threads;
use threads::shared;

my $thread;

has 'events' => (
	traits => ['Hash'],
	is => 'ro',
	isa => 'HashRef[CodeRef]',
	default => sub { {} },
	handles => {
		event_add => 'set',
		event_get => 'get',
		event_del => 'delete',
		event_empty => 'is_empty',
		event_num => 'count',
		event_pairs => 'kv'
	}
);

## schedule(int, code)
# @delay Seconds that will pass before executing.
# @sub CodeRef to the subroutine to execute.
sub schedule {
	my ($this, $delay, $sub) = @_;
	my $mod = caller;	
	if($delay !~ m/^[0-9]+/)
	{
		$this->log(WARN => "$mod attempted to add a time event with a non-numerical delay of '$delay'.");
		return;
	}

	$this->event_add("$mod/$delay" => $sub);
	$this->log(INFO => "Added time event from $mod and a delay of $delay seconds.");
}

$thread = threads->create(sub {
	
});
1;

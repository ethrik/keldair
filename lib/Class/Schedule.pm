# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Class::Schedule;
use Mouse::Role;
use Time::HiRes qw(setitimer ITIMER_VIRTUAL time);

my %events;

setitimer(ITIMER_VIRTUAL, 60, 60);

$SIG{VTALRM} = sub {
	$_->() foreach (keys %events);
};

sub schedule {
	my ($this, $sub) = @_;
	my $class = caller;
	$events{$class} = $sub;
	$this->log(SCHEDULE => "Added a new event from $class.");
}

1;

# Timer.pm - Timers for the Keldair IRC framework.
# Copyright 2011 Ethrik Project, et al.
# Licensed under the BSD license.

use warnings;
use strict;
package Keldair::Timer;

use Scalar::Util;

our (%timers, %repeatable, %waiting);

# Timer constant magics.
sub TIMER_ONCE () { 1; } # Have the timer only run once.
sub TIMER_REPEAT () { -1; } # Have the timer repeat continuously.

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

#
# $timer->after( 5, \&coderef );
#
sub after {
    my ( $self, $wait, $code ) = @_;
    return if ( !$wait || !$code );
    $self->create(TIMER_ONCE, $wait, $code) or return;
    return 1;
}

#
# $timer->every( 5, \&codref );
# 
sub every {
    my ( $self, $wait, $code ) = @_;
    return if ( !$wait || !$code );
    $self->create(TIMER_REPEAT, $wait, $code ) or return;
    return 1;
}

#
# $timer->create( <number of repeats>, <time to wait>, \&coderef );
# 
sub create {
    my ( $self, $repeat, $wait, $code ) = @_;
    return if ( !$repeat || !$wait || !$code );
    return unless Scalar::Util::looks_like_number($repeat);
    if ($repeat != 0) {
        $repeatable{$code} = $repeat;
        $waiting{$code} = $wait;
    }
    push $timers{ time + $wait }, $code;
    return 1;
}

sub run {
    printf("TIMER WAS RAN BY %s!\n", caller());
    my $time = time;
    foreach my $key (keys %timers) {
        if ($time == $key) {
            foreach my $code ( @{ $timers{$time} } ) {
                $code->();
                if (--$repeatable{$code}) {
                    push $timers{time + $waiting{$code}}, $code;
                } else {
                  delete $repeatable{$code};
                }
            }
            delete $timers{$time};
        }
    }
}

1;

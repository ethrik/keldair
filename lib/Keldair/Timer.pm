# Timer.pm - Timers for the Keldair IRC framework.
# Copyright 2011 Ethrik Project, et al.
# Licensed under the BSD license.

use warnings;
use strict;
package Keldair::Timer;

use Scalar::Util;
use Glib;

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
    return $code;
}

#
# $timer->every( 5, \&codref );
# 
sub every {
    my ( $self, $wait, $code ) = @_;
    return if ( !$wait || !$code );
    $self->create(TIMER_REPEAT, $wait, $code ) or return;
    return $code;
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
    $timers{ time + $wait } ||= [];
    push @{ $timers{ time + $wait } }, $code;
    return 1;
}

sub delete {
  my ( $self, $code ) = @_;
  return if ( !$code );

  OUTER: foreach my $time (keys %timers) {
    INNER: for (my $x = 0; $timers{$time}[$x]; $x++) {
      if ($timers{$time}[$x] == $code) {
        delete $timers{$time}[$x];
        delete $timers{$time} unless (scalar(@{ $timers{$time} }));
        last OUTER;
      }
    }
  }

  delete $repeatable{$code};
  delete $waiting{$code};
  return 1;
}

sub run {
    my $time = time;
    foreach my $key (keys %timers) {
        if ($time == $key) {
            while (@{ $timers{$time} }) {
                my ($code) = shift @{ $timers{$time} };                
                $code->();
                if (--$repeatable{$code}) {
                    $timers{ time + $waiting{$code} } ||= [];
                    push @{ $timers{time + $waiting{$code}} }, $code;
                } else {
                  delete $repeatable{$code};
                  delete $waiting{$code};
                }
            }
            delete $timers{$time};
        }
    }
    return 1;
}

1;

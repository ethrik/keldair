# Ping.pm - Basic ping/pong for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the same terms as Keldair itself.

package Keldair::Module::Ping;
use strict;
use warnings;
use Keldair;

$keldair->help_add(PING => 'Throws a pong at the sender.');

$keldair->command_bind(PING => sub {
    my ($network, $chan, $dst) = @_;
    $keldair->msg($network, $chan, '%s: Pong!', $dst->nick);
});


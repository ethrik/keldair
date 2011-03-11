# Ping.pm - Basic ping/pong for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the same terms as Keldair itself.

use strict;
use warnings;
use Keldair;

$keldair->command_bind(PING => sub {
    my ($chan, $dst) = @_;
    $keldair->msg($chan, '%s: Pong!', $dst->nick);
});


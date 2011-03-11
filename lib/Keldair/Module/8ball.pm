# 8ball.pm - 8ball module for Keldair
# Copyright 2011 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the same terms as Perl itself.

package Keldair::Module::8ball;

use strict;
use warnings;
use Keldair;

my @responses = (
    'Absolutely yes!',
    'Answer hazy.',
    'Prospect looks bleak.',
    'No.',
    "That's a question you should ask yourself.",
    'I like to think so.',
    'Not even on a GOOD day.',
    'It would take a disturbed person to even ask.',
    'Maybe -- give me more money and ask again.',
    'Yes, yes, yes, and yes again.',
    'You wish.',
    'Not bloody likely.',
    "I'm busy.",
    'Concentrate and ask again.',
    'Most likely.',
    "I wouldn't know anything about that.",
    'No way.',
    'All signs point to yes.',
    'Never.',
);

$keldair->command_bind('8BALL' => sub {
        my ( $chan, $nick, @msg) = @_;
        $keldair->msg( $chan, $responses[int(rand($#responses))] );
    }
);

1;


# Love.pm - Keldair module for calculating love.
# Copyright 2011 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the Artistic License

# modreq: Love::Match::Calc

package Keldair::Module::Love;

use strict;
use warnings;
use Keldair;
use Love::Match::Calc;

$keldair->command_bind(
    LOVE => sub {
        my ( $chan, $nick, @names ) = @_;
        my $m = lovematch( $names[0], $names[1] );
        $keldair->msg( $chan, "Lovematch for $names[0] and $names[1] is $m%" );
    }
);

1;

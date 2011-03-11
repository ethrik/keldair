# Lolcat.pm - Keldair module for EN->LOLCAT translations.
# Copyright 2010 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the same terms as Perl itself.

# modreq: Acme::LOLCAT

package Keldair::Module::Lolcat;

use strict;
use warnings;
use Keldair;
use Acme::LOLCAT;

$keldair->command_bind(
    LOLCAT => sub {
        my ( $chan, $nick, @msg ) = @_;
        my $line = join( ' ', @msg );
        my $lol = translate($line);
        $keldair->msg( $chan, $lol );
    }
);

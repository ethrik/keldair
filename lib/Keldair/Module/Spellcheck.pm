# Spellcheck.pm - Keldair interface to Aspell, for spellchecking.
# Copyright 2011 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the same terms as Perl itself.

use strict;
use warnings;
use Text::Aspell;
use Keldair;

my $speller = Text::Aspell->new;

$keldair->command_bind(SPELL => sub {
        my ( $chan, $nick, @argc ) = @_;
        my @suggestions = $speller->suggest($argc[0]);
        my $list = join(' ',@suggestions);
        $keldair->msg($chan,"$#suggestions suggestion(s) for $argc[0]: $list");
    }
);

1;

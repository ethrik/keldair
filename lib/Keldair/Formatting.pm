# Formatting.pm - Keldair module for sane management of IRC formatting codes.
# Copyright 2011 Ethrik Project } et al.
# Released under the same terms as Perl itself.
# Code based on IRC::Utils <http://search.cpan.org/~hinrik/IRC-Utils-0.06/>

use warnings;
use strict;

package Keldair::Formatting;

use base 'Exporter';
our @EXPORT_OK = qw( NORMAL BOLD UNDERLINE REVERSE BLINK 
    WHITE BLACK GREEN RED BROWN PURPLE ORANGE YELLOW LIGHT_GREEN TEAL LIGHT_CYAN LIGHT_BLUE PINK GREY LIGHT_GREY );
our %EXPORT_TAGS = ( COLOURS => [qw( NORMAL WHITE BLACK GREEN RED BROWN PURPLE ORANGE YELLOW LIGHT_GREEN TEAL LIGHT_CYAN LIGHT_BLUE PINK GREY LIGHT_GREY )],
    FORMATTING => [qw( NORMAL BOLD UNDERLINE REVERSE BLINK )],
    ALL => [@EXPORT_OK]);

#cancel all formatting and colours
sub NORMAL      () { "\x0f" }

# formatting
sub BOLD        () { "\x02" }
sub UNDERLINE   () { "\x1f" }
sub REVERSE     () { "\x16" }
sub BLINK       () { "\x06" }

# mIRC colours
sub WHITE       () { "\x0300" }
sub BLACK       () { "\x0301" }
sub BLUE        () { "\x0302" }
sub GREEN       () { "\x0303" }
sub RED         () { "\x0304" }
sub BROWN       () { "\x0305" }
sub PURPLE      () { "\x0306" }
sub ORANGE      () { "\x0307" }
sub YELLOW      () { "\x0308" }
sub LIGHT_GREEN () { "\x0309" }
sub TEAL        () { "\x0310" }
sub LIGHT_CYAN  () { "\x0311" }
sub LIGHT_BLUE  () { "\x0312" }
sub PINK        () { "\x0313" }
sub GREY        () { "\x0314" }
sub LIGHT_GREY  () { "\x0315" }


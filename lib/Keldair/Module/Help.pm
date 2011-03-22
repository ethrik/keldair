# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::Module::Help;
use Keldair;
use strict;
use warnings;

$keldair->help_add(HELP => 'Shows help for the command.');
$keldair->syntax_add(HELP => 'HELP <command>');

$keldair->command_bind(HELP =>
    sub {
        my ($network, $chan, $nick, @parv) = @_;
        if ($parv[0]) { 
            if ($keldair->help_get(uc($parv[0]))) {
                $keldair->msg($network,$chan,'Help for %s: %s', uc($parv[0]), $keldair->help_get(uc($parv[0]))); 
                if ($keldair->syntax_get(uc($parv[0]))) {
                    $keldair->msg($network,$chan,'Syntax: %s', $keldair->syntax_get(uc($parv[0])));
                }
            }
            else {
                $keldair->msg($network, $chan, 'No help for %s.', uc($parv[0]));
            }
        }
        else {
            my @list;
            for my $cmd ($keldair->command_pairs)
            {
                push @list, $cmd->[0];
            }
            $keldair->msg($network, $chan, "@list");
        }
    }
);

1;

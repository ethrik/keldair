# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Keldair::Module::Help;
use Keldair;
use strict;
use warnings;

$keldair->help_add(HELP => 'Shows help for the command.');

$keldair->command_bind(HELP =>
    sub {
        my ($chan, $nick, @parv) = @_;
        if ($parv[0]) { 
            if ($keldair->help_get(uc($parv[0]))) {
                $keldair->msg($chan,'Help for %s: %s', uc($parv[0]), $keldair->help_get(uc($parv[0]))); 
            }
            else {
                $keldair->msg($chan, 'No help for %s.', uc($parv[0]));
            }
        }
        else {
            my @list;
            for my $cmd ($keldair->command_pairs)
            {
                push @list, $cmd->[0];
            }
            $keldair->msg($chan, "@list");
        }
    }
);

1;

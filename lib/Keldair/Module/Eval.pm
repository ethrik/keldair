# Eval.pm - Eval module for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the same terms as Keldair itself.

use strict;
use warnings;
use Keldair;

$keldair->command_bind(EVAL => sub {
        my ($chan, $dst, @expr) = @_;
        if(!defined $expr[0])
        {
            $keldair->msg($chan, "Syntax: \002EVAL\002 <expression>");
            return;
        }

        my $expr = join ' ', @expr;
        my $result = eval $expr;

        $keldair->msg($chan, $result) if defined $result;
        $keldair->msg($chan, $@) if $@;
        $keldair->msg($chan, 'Done.');
    }
);


# Eval.pm - Eval module for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the same terms as Keldair itself.

package Keldair::Module::Eval;
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
        my $error = $@ if $@;
        $result =~ s/(\n|\r|\0)/ /g if (defined $result and $result =~ /(\n|\r|\0)/);
        $keldair->msg($chan, $result) if defined $result;
        $error =~ s/(\n|\r|\0)/ /g if (defined $error and $error =~ /(\n|\r|\0)/);
        $keldair->msg($chan,$error) if $error;
        $keldair->msg($chan, 'Done.');
    }
);


# Eval.pm - Eval module for Keldair
# Copyright 2011 Ethrik Project, et al.
# Licensed under the same terms as Keldair itself.

package Keldair::Module::Eval;
use strict;
use warnings;
use Keldair;

$keldair->help_add(EVAL => 'Evaluates a Perl expression.');
$keldair->syntax_add(EVAL => 'EVAL <expression>');

$keldair->command_bind(EVAL => sub {
        my ($network, $chan, $dst, $expr) = @_;
        if(!defined $expr)
        {
            $keldair->msg($network,$chan, "Syntax: \002EVAL\002 <expression>");
            return;
        }

        my $result = eval $expr;
        my $error = $@ if $@;
        $result =~ s/(\n|\r|\0)/ /g if (defined $result and $result =~ /(\n|\r|\0)/);
        $keldair->msg($network,$chan, $result) if defined $result;
        $error =~ s/(\n|\r|\0)/ /g if (defined $error and $error =~ /(\n|\r|\0)/);
        $keldair->msg($network,$chan,$error) if $error;
        $keldair->msg($network,$chan, 'Done.');
    }
);

1;

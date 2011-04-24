# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Keldair::CoreCommands;
use strict;
use warnings;
use FindBin qw($Bin);
use Keldair;

our $trigger = $keldair->conf->get('trigger');

$keldair->help_add(DIE => 'Causes the Keldair instance to shut down.');
$keldair->help_add(RESTART => 'Restarts the Keldair instance.');
$keldair->help_add(REHASH => 'Rehashes the config file.');
$keldair->help_add(MODLOAD => 'Load a module in lib/Keldair/Modules/');

$keldair->hook_add(OnRehash => sub {
        my $network = shift;
        my $chan = shift;
        $trigger = $keldair->config('trigger');
        $keldair->msg($network, $chan => 'Updating trigger to %s', $trigger) unless !$chan;
        return 0;
    }); 

$keldair->hook_add(OnMessage => sub {
        my ($network, $chan, $nick, $msg) = @_;
        my $trig = quotemeta($trigger);
        if ($msg =~ /^$trig/) {
            my $cmd = substr $msg, length $trigger;
            $cmd = (split ' ', $cmd)[0];

            my $_trigger = substr $msg, 0, (length $trigger);

            my $trig_and_cmd = length($cmd) + length($trigger);
            my $args = substr $msg, $trig_and_cmd;
            $args =~ s/^ // if $args =~ /^ /;
            my @args = split ' ', $args;

            my $exec_cmd = $keldair->command_get(uc $cmd);

            if($exec_cmd) {
                if ($chan =~ /^(!|#|&)/) {
                    $exec_cmd->($network, $keldair->find_chan($chan), $keldair->find_user($nick), $args);
                }
                else {
                    $exec_cmd->($network, $keldair->find_user($chan), $keldair->find_user($nick), $args);
                }
            }
        }
        else {
            return;
        }
    });

$keldair->command_bind(DIE => sub {
        my ($network, $chan, $dst, @reason) = @_;

        $keldair->quit($network, (join ' ', @reason));
        $keldair->logf(INFO => 'Shutting down by request of %s from %s@%s.', $dst->nick, $chan->name, $network);
        exit 0;
    });

1;

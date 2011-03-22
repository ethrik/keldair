# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
package Keldair::CoreCommands;
use strict;
use warnings;
use FindBin qw($Bin);
use Keldair;

my $trigger;

$keldair->help_add(DIE => 'Causes the Keldair instance to shut down.');
$keldair->help_add(RESTART => 'Restarts the Keldair instance.');
$keldair->help_add(REHASH => 'Rehashes the config file.');

$keldair->hook_add(OnRehash => sub {
	my $network = shift;
        my $chan = shift;
        $trigger = $keldair->config('keldair/trigger');
        $keldair->msg($network, $chan => 'Updating trigger to %s', $trigger) unless !$chan;
        return 0;
    }); 

$keldair->hook_add(OnMessage => sub {
        my ($network, $chan, $nick, @msg) = @_;

        my $msg = join ' ', @msg;

        my $cmd = substr $msg, length $trigger;
        $cmd = (split ' ', $cmd)[0];
        return 0 if !defined $cmd;

        my $_trigger = substr $msg, 0, (length $trigger);

        return 0 unless $trigger eq $_trigger;

        my $trig_and_cmd = length($cmd) + length($trigger);
        my $args = substr $msg, $trig_and_cmd;
        my @args = split ' ', $args;

        my $exec_cmd = $keldair->command_get(uc $cmd);

        if($exec_cmd) {
            if ($chan =~ /^(!|#|&)/) {
                print "CHANNEL: $chan\n";
                $exec_cmd->($network, $keldair->find_chan($chan), $keldair->find_user($nick), @args);
            }
            else {
                print "USER: $chan\n";
                $exec_cmd->($network, $keldair->find_user($chan), $keldair->find_user($nick), @args);
            }
        }
    });

    $keldair->command_bind(DIE => sub {
            my ($network, $chan, $dst, @reason) = @_;

            $keldair->quit($network, (join ' ', @reason));
            $keldair->logf(INFO => 'Shutting down by request of %s from %s@%s.', $dst->nick, $chan->name, $network);
            exit 0;
        });

    $keldair->command_bind(RESTART => sub {
            my ($network, $chan, $dst, $reason) = @_;

            system "$Bin/keldair";

            $keldair->quit($network, $reason);
            $keldair->logf(INFO => 'Restarting by request of %s from %s@%s.', $dst->nick, $chan->name, $network);

            exit 0;
        });

    $keldair->command_bind(REHASH => sub {
            my ($network, $chan, $dst) = @_;

            $keldair->hook_run(OnRehash => $network, $chan, $dst);
            $keldair->msg($chan, 'Rehashing keldair.conf.');
            $keldair->logf(INFO => '%s is rehashing keldair.conf.', $dst->nick);
        });

    1;

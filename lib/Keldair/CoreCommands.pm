# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011
package Keldair::CoreCommands;
use strict;
use warnings;
use FindBin qw($Bin);
use Keldair;

my $trigger;

$keldair->hook_add(OnRehash => sub {
        my $chan = shift;
        $trigger = $keldair->config('keldair/trigger');
        $keldair->msg($chan => 'Updating trigger to %s', $trigger) unless !$chan;
        return 0;
    }); 

$keldair->hook_add(OnMessage => sub {
        my ($chan, $nick, @msg) = @_;
        
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
        if($exec_cmd)
        {
            $exec_cmd->($keldair->find_chan($chan), $keldair->find_user($nick), @args);
        }
    });

$keldair->command_bind(DIE => sub {
        my ($chan, $dst, @reason) = @_;

        $keldair->quit((join ' ', @reason));
        $keldair->logf(INFO => 'Shutting down by request of %s from %s.', $dst->nick, $chan->name);
        exit 0;
    });

$keldair->command_bind(RESTART => sub {
        my ($chan, $dst, $reason) = @_;

        system "$Bin/keldair";

        $keldair->quit($reason);
        $keldair->logf(INFO => 'Restarting by request of %s from %s.', $dst->nick, $chan->name);

        exit 0;
    });

$keldair->command_bind(REHASH => sub {
        my ($chan, $dst) = @_;

        $keldair->hook_run(OnRehash => $chan, $dst);
        $keldair->msg($chan, 'Rehashing keldair.conf.');
        $keldair->logf(INFO => '%s is rehashing keldair.conf.', $dst->nick);
    });

1;

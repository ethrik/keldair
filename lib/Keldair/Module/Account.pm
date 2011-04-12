# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::Module::Account;
use strict;
use warnings;
use Keldair;
use Module::Load;

my $authmod = ucfirst( $keldair->conf->get('authen/module') );
print "Keldair::Module::Authen::$authmod\n";
load("Keldair::Module::Authen::$authmod", 'check');
my %account;


foreach my $cmd ( qw/ IDENTIFY LOGIN / ) {
    $keldair->command_bind( $cmd => \&cmd_identify );
    $keldair->help_add( $cmd => 'Identify to Keldair.' );
    $keldair->syntax_add( $cmd => "$cmd <username> <password>" );
}

sub cmd_identify {
    my ( $network, $channel, $origin, $message ) = @_;
    my @parv = split( ' ', $message );
    my ( $username, $password );
    if ( $#parv == 1 ) {
        $username = lc $parv[0];
        $password = $parv[1];
    }
    else {
        $username = lc $origin->nick;
        $password = $parv[0];
    }
    if ( ($origin->account) && ($origin->account eq $username ) ) {
        $keldair->notice( $network, $origin,
            'You are already identified to account %s', $username );
        return;
    }

    if ( check( $username, $password ) ) { 

        $origin->account($username);
        my @notify = split /\,/, $account{ lc $username }{identified};

        $account{ lc($username) }{identified} .= ',' . $network.'/'.$origin->nick;

        $keldair->logf(
            ACCOUNT => '%s!%s@%s (%s) successfully identifed to account %s.',
            $origin->nick, $origin->ident, $origin->host, $network, $username
        );

        $keldair->notice( $network, $origin, 'Successfully identified to account %s.', $username );

        foreach my $logged_in (@notify) {
            next if $logged_in eq '';    # This is for the first value that is always blank
            $keldair->logf(
                DEBUG =>
                'Notifying %s that %s identified to the same account as them.',
                $logged_in, $origin->name
            );
            next if $logged_in eq ( $network.'/'.$origin->nick );
            my ( $net, $user ) = split('/', $logged_in );
            $keldair->notice( $net, $keldair->find_user($user),
                '%s!%s@%s identified to your account (%s) on %s.',
                $origin->name, $origin->ident, $origin->host, $username, $network
            );
        }
    }
    else {
        $keldair->notice( $network, $origin, 'Authentication to %s failed.', $username );
        return;
    }
    return 1;
}

1;


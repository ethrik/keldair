# Hailo.pm - Hailo AI interface for Keldair
# Copyright 2011 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the same terms as Perl itself.

# modreq: Hailo,Acme::Llama
# modconf: "ai" : { "wait" : 5, },

package Keldair::Module::Hailo;

use strict;
use warnings;
use Keldair;
use Hailo;

my $lines = 0;
my $hailo = Hailo->new;

$keldair->hook_add(OnMessage => sub {
		my ($chan, $nick, @msg) = @_;
		my $msg = join(' ',@msg);
		$lines++;
		$hailo->learn($msg);
		if ($lines >= $keldair->config('ai/wait')) {
			$keldair->msg($chan,$hailo->reply);
		}
	}
);

$keldair->command_bind(CHAT => sub {
		my ($chan, $nick, @msg) = @_;
		if (!@msg) {
			$keldair->msg($chan,$hailo->reply);
		}
		else {
			my $msg = split(' ',@msg);
			$keldair->msg($chan,$hailo->reply($msg));
		}
	}
);

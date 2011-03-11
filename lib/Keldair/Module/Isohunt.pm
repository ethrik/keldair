# Isohunt.pm - Keldair module for searching IsoHunt
# Copyright 2011 Alexandria M. Wolcott <alyx@sporksmoo.net>
# Licensed under the same terms as Perl itself.

# modreq: Net::isoHunt

package Keldair::Module::Isohunt;

use strict;
use warnings;
use Keldair;
use Net::isoHunt;

$keldair->command_bind(
	ISOHUNT => sub {
		my ( $chan, $nick, @query ) = @_;
		my $query = join(' ', @query);
		my $ih = Net::isoHunt->new;
		my $request = $ih->prepare_request( ihq => $query );
		$request->start(21);
		$request->rows(20);
		$request->sort('seeds');
		my $response = $request->execute;
		$keldair->msg($chan,"\002Title:\002 ".$response->title." \002URL:\002 ".$response->link);
	}
);


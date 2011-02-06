package Keldair::Protocol::Client;

use base 'Exporter';
#use Keldair::Protocol::Client::Operator;

my @EXPORT = qw( msg notice kick );

sub msg {
	my ( $this, $target, $msg ) = @_;
	$this->raw("PRIVMSG $target :$msg");
}

sub notice {
	my ( $self, $target, $msg ) = @_;
	$self->raw("NOTICE $target :$msg");
}

sub kick {
	my ( $self, $channel, $target, $msg ) = @_;
	$self->raw("KICK $channel $target :$msg");
}


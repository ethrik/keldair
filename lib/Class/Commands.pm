# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD
# You are prohibited by law to run this file by perltidy or I will prosecute you -- Samuel Hoffman 2011

package Class::Commands;
use Mouse::Role;

## joinChannel(str)
# Attempt to join a channel
# @chan Channel to join
sub joinChannel {
	my ($this, $chan) = @_;
	$this->raw("JOIN $chan");
}

## raw(str)
# Send a raw line to the server
# @dat Data to send to the server
sub raw {
    my ($this, $dat) = @_; 
    print $Class::Keldair::socket "$dat\n";
    print "S: $dat\n" if $this->debug;
}

## msg(str, str)
# PRIVMSG a target (channel/user) with a message
# @target Channel or User to message
# @msg Text to send
sub msg {
    my ($this, $target, $msg) = @_; 
    $this->raw("PRIVMSG $target :$msg");
}

1;

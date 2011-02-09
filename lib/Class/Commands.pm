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
	if($this->hook_run(OnBotPreJoin => $chan) < 0)
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from joining $chan.");
		return 0;
	}
	$this->raw("JOIN $chan");
	$this->hook_run(OnBotJoin => $chan);
	return 1;
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
	if($this->hook_run(OnBotPreMessage => $target, $msg))
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from sending PRIVMSG to $target with '$msg'.");
		return 0;
	}
    $this->raw("PRIVMSG $target :$msg");
	$this->hook_run(OnBotMessage => $target, $msg);
	return 1;
}

## quit(str)
# Quit from IRC with a reason
# @reason Quit-Reason to use. If not defined, it will default to "leaving"
sub quit {
	my ($this, $reason) = @_;
	$reason ||= "leaving";
	if($this->hook_run(OnBotPreQuit => $reason))
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from QUIT with '$reason'.");
		return 0;
	}
	$this->raw("QUIT :$reason");
	$this->hook_run(OnBotQuit => $reason);
	return 1;
}

1;

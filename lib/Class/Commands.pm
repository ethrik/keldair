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
	if($this->hook_run(OnBotPreJoin => $this->find_chan($chan)) < 0)
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from joining $chan.");
		return 0;
	}
	$this->poe->yield(join => $chan);
	$this->hook_run(OnBotJoin => $this->find_chan($chan));
	return 1;
}

## raw(str, ...)
# Send a raw line to the server
# @dat Data to send to the server
# @... Variables to fill in %s in $dat

## msg(object, msg)
# PRIVMSG a target (channel/user) with a message
# @target Channel or User to message
# @msg Text to send
sub msg {
	my $this = shift;
	my $target = shift;
	my $msg = sprintf(shift @_, @_);
	
	my $res = $this->hook_run(OnBotPreMessage => $target, $msg);
	
	if($res)
	{
		if($res == 2 || $res == -2)
		{
			$this->log(HOOK_DENY => "Stopped ".caller." from sending PRIVMSG to $target with '$msg'.");
			return $res;
		}
	}
	if($target->isa('channel'))
	{
  	 	$this->raw("PRIVMSG ".$target->name." :$msg");
	}
	elsif($this->isa('user'))
	{
		$this->raw("PRIVMSG ".$target->nick." :$msg");
	}
	else
	{
		$this->log(ERROR => "msg(): Recieved invalid target ($target) - neither channel or user.");
		return $res;
	}
	$this->hook_run(OnBotMessage => $target, $msg);
	return $res if $res;
}

## notice(object, str, ...)
# Send a NOTICE to a channel/nick
# @target Nick/Channel object
# @msg Message to send - may contain %s/%u/%d/etc
# @... Variables to fill % in $msg.
sub notice {
	my $this = shift;
	my $target = shift;
	my $msg = sprintf(shift @_, @_);

	my $res = $this->hook_run(OnBotPreNotice => $target, $msg);
	
	if($res)
	{
		if($res == 2 || $res == -2)
		{
			my $class = caller;
			$this->log(HOOK_DENY => "Stopped $class from sending NOTICE to $target with '$msg'.");
			return $res;
		}
	}
	if($target->isa('channel'))
	{
		$this->raw('NOTICE '.$target->name." :$msg");
	}
	elsif($target->isa('user'))
	{
		$this->raw('NOTICE '.$target->nick." :$msg");
	}
	else
	{
		$this->log(ERROR => "notice(): Recieved invalid target ($target) - neither channel or user.");
		return $res;
	}
	$this->hook_run(OnBotNotice => $target, $msg);
	return $res if $res
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

## setMode(object, char, ...)
# SET (+) a mode on a channel/nick
# @target Channel/Nick object to add modes to
# @char Mode letter - ONLY ONE!!!
# @args Any arguments $char may take
sub setMode {
	my ($this, $target, $char, @args) = @_;

	if($char !~ m/^[A-Z]$/i)
	{
		$this->logf(WARN => 'setMode(): Invalid modechar %s - set one at a time!', $char);
		return;
	}

	my $res = $this->hook_run(OnBotPreMode => $target, $char);
	if($res)
	{
		if($res == 2 || $res == -2)
		{
			$this->logf(HOOK_DENY => '%s denied OnBotPreMode.', caller);
			return $res;
		}
	}
	if($target->isa('user'))
	{
		$this->raw('MODE '.$target->nick." +$char @args");
		$this->logf(MODE => 'Set +%s on %s.', $char, $target->nick);
	}
	elsif($target->isa('channel'))
	{
		$this->raw('MODE '.$target->name." +$char @args");
		$this->logf(MODE => 'Set +%s on %s.', $char, $target->name);
	}
	$target->add_mode($char);
	return $res if $res;
}

## kick(object, object, str)
# Kick a client from a channel
# @chan Channel object to kick on
# @user User object to kick
# @reason Reason to supply
sub kick {
	my ($this, $chan, $user, $reason) = @_;
	if(!$user->isa('user'))
	{
		$this->logf(WARN => 'kick(): Invalid target "%s" - can only kick users.', $user);
		return;
	}
	if(!$chan->isa('channel'))
	{
		$this->logf(WARN => 'kick(): Invalid parameter for channel "%s" - can only kick on channels.', $chan);
		return;
	}
	$reason ||= 'no reason';
	my $res = $this->hook_run(OnBotPreKick => $chan, $user, $reason);
	
	if($res)
	{
		if($res == 2 || -2)
		{
			$this->logf(HOOK_DENY => '%s denied OnBotPreKick.', caller);
			return $res;
		}
	}
	$this->raw('KICK '.$chan->name.' '.$user->nick." :$reason");
	$this->hook_run(OnBotKick => $chan, $user, $reason);
	return $res if $res;
}

1;

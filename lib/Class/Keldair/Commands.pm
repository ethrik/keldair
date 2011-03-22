# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD

package Class::Keldair::Commands;
use Mouse::Role;

## joinChannel(str)
# Attempt to join a channel
# @chan Channel to join
sub joinChannel {
	my ($this, $network, $chan) = @_;
	if($this->hook_run(OnBotPreJoin => $this->find_chan($chan)) < 0)
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from joining $chan\@\$network.");
		return 0;
	}
	$this->raw($network, "JOIN $chan");
	$this->hook_run(OnBotJoin => $this->find_chan($chan));
	return 1;
}

## raw(str, ...)
# Send a raw line to the server
# @dat Data to send to the server
# @... Variables to fill in %s in $dat
sub raw {
	my $this = shift;
	my $network = shift;
	my $dat = sprintf shift @_, @_;
	my $res = $this->hook_run(OnBotPreRaw => $Class::Keldair::socket, $dat);
	if ($res)
	{
		if($res == 2 || $res == -2)
		{
			$this->log(HOOK_DENY => caller.' denied OnBotPreRaw.');
			return $res;
		}
	}
       $this->manager->write($network, $dat);
       print "<$network> S: $dat\n" if $this->debug;
}

## msg(object, msg)
# PRIVMSG a target (channel/user) with a message
# @network Network
# @target Channel or User to message
# @msg Text to send
sub msg {
	my $this = shift;
	my $network = shift;
	my $target = shift;
	my $msg = sprintf(shift @_, @_);
	
	my $res = $this->hook_run(OnBotPreMessage => $network, $target, $msg);
	
	if($res)
	{
		if($res == 2 || $res == -2)
		{
			$this->log(HOOK_DENY => "Stopped ".caller." from sending PRIVMSG to $target\@$network with '$msg'.");
			return $res;
		}
	}
	if($target->isa('channel'))
	{
  	 	$this->raw($network, "PRIVMSG ".$target->name." :$msg");
	}
	elsif($target->isa('user'))
	{
		$this->raw($network, "PRIVMSG ".$target->nick." :$msg");
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
# @network Network
# @target Nick/Channel object
# @msg Message to send - may contain %s/%u/%d/etc
# @... Variables to fill % in $msg.
sub notice {
	my $this = shift;
	my $network = shift;
	my $target = shift;
	my $msg = sprintf(shift @_, @_);

	my $res = $this->hook_run(OnBotPreNotice => $network, $target, $msg);
	
	if($res)
	{
		if($res == 2 || $res == -2)
		{
			my $class = caller;
			$this->log(HOOK_DENY => "Stopped $class from sending NOTICE to $target\@$network with '$msg'.");
			return $res;
		}
	}
	if($target->isa('channel'))
	{
		$this->raw($network, 'NOTICE '.$target->name." :$msg");
	}
	elsif($target->isa('user'))
	{
		$this->raw($network, 'NOTICE '.$target->nick." :$msg");
	}
	else
	{
		$this->log(ERROR => "notice(): Recieved invalid target ($target) - neither channel or user.");
		return $res;
	}
	$this->hook_run(OnBotNotice => $network, $target, $msg);
	return $res if $res
}

## quit(str)
# Quit from IRC with a reason
# @network Network
# @reason Quit-Reason to use. If not defined, it will default to "leaving"
sub quit {
	my ($this, $network, $reason) = @_;
	$reason ||= "leaving";
	if($this->hook_run(OnBotPreQuit => $reason))
	{
		$this->log(HOOK_DENY => "Stopped ".caller." from QUIT on $network with '$reason'.");
		return 0;
	}
	$this->raw($network, "QUIT :$reason");
	$this->hook_run(OnBotQuit => $network, $reason);
	return 1;
}

## setMode(object, char, ...)
# SET (+) a mode on a channel/nick
# @target Channel/Nick object to add modes to
# @char Mode letter - ONLY ONE!!!
# @args Any arguments $char may take
sub setMode {
	my ($this, $network, $target, $char, @args) = @_;

	if($char !~ m/^[A-Z]$/i)
	{
		$this->logf(WARN => 'setMode(): Invalid modechar %s - set one at a time!', $char);
		return;
	}

	my $res = $this->hook_run(OnBotPreMode => $network, $target, $char);
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
		$this->raw($network, 'MODE '.$target->nick." +$char @args");
		$this->logf(MODE => 'Set +%s on %s@%s.', $char, $target->nick, $network);
	}
	elsif($target->isa('channel'))
	{
		$this->raw($network, 'MODE '.$target->name." +$char @args");
		$this->logf(MODE => 'Set +%s on %s@%s.', $char, $target->name, $network);
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
	my ($this, $network, $chan, $user, $reason) = @_;
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
	my $res = $this->hook_run(OnBotPreKick => $network, $chan, $user, $reason);
	
	if($res)
	{
		if($res == 2 || -2)
		{
			$this->logf(HOOK_DENY => '%s denied OnBotPreKick.', caller);
			return $res;
		}
	}
	$this->raw($network, 'KICK '.$chan->name.' '.$user->nick." :$reason");
	$this->hook_run(OnBotKick => $network, $chan, $user, $reason);
	return $res if $res;
}

1;

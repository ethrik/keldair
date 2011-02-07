package Class::Parser;
use Mouse::Role;

my (%commands, %_commands);

%commands = (
	NOTICE => sub {
		my ($this, $origin, $cmd, $target, @msg) = @_;
		
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin, 1)[0]; # just in case the server allowed the origin to have more than 1 '!' in the hostmask
		$nick = substr $nick, 1;

		if($nick)
		{
			$this->hook_run(OnNotice => $nick, $target, @msg);
		}
		## Potential Bug
		# If the bot cannot find the nick by the '!', it will assume server notice
		# This will only cause problems on servers in huge violation of RFC
		else
		{
			my $servname = substr $origin, 1;
			$this->hook_run(OnServerNotice => $servname, $target, @msg);
		}
	},
	PRIVMSG => sub {
		# R: :miniCruzer!sam@usr-bin-perl.use-strict.use-warnings PRIVMSG #dev :hot
		my ($this, $origin, $cmd, $target, @msg) = @_;
		my $m = shift @msg;
		$m = substr $m, 1;
		unshift @msg, $m;

		my $nick = (split /!/, $origin)[0];
		$nick = substr $nick, 1;
		
		$this->hook_run(OnMessage => $target, $nick, @msg);
	},
	JOIN => sub {
		my ($this, $origin, $cmd, $chan) = @_;
		my $nick = nick_from_host($origin);
		$this->hook_run(OnJoin => $nick, $chan);
	},
	'001' => sub {
		my ($this, $server, @welcome) = @_;
		$this->hook_run(OnConnect => $server, @welcome);
	}
);

%_commands = (
	PING => sub {
		my ($this, $cmd, $str) = @_;
		$this->raw("PONG $str");
	}
);

## parse(str)
# Start parsing an IRC line.
# @line \n-Terminated line from the server
sub parse {
	my ($this, $line) = @_;
	$this->log(WARN => 'parse(): Did not get an IRC line when called!', 1) if !$line;
	my @s = split / /, $line;
	
	if(exists $commands{uc($s[1])})
	{
		$commands{uc($s[1])}->($this, @s);
	}
	if(exists $_commands{uc($s[0])})
	{
		$_commands{uc($s[0])}->($this, @s);
	}
}

sub nick_from_host {
	my ($host) = @_;
	my $nick = (split /!/, $host, 1)[0];
	return $nick if $nick;
}

1;

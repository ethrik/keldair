package Class::Commands;
use Mouse::Role;

sub joinChannel {
	my ($this, $chan) = @_;
	$this->raw("JOIN $chan");
}

sub raw {
    my ($this, $dat) = @_; 
    print $Class::Keldair::socket "$dat\n";
    print "S: $dat\n" if $this->debug;
}

sub msg {
    my ($this, $target, $msg) = @_; 
    $this->raw("PRIVMSG $target :$msg");
}

1;

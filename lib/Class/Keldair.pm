# alyx can add the copyright notices...
# NOTICE: It is recommended that you do not modify this file if you do not understand what is going on here.
package Class::Keldair;
use Mouse;

## networks
# This is a hash of networks that points to a network object, which contains multifarious info, such as channels, users, the bot's info itself...
# In order to make it an attribute, this is how its done:
# NOTICE --- There is no Network object as of this release.
has networks => (
    traits  =>  ['Hash'],
    is      =>  'ro',
    isa     =>  'HashRef[Object]',
    default =>  sub { {} },
    handles =>  {
        add_network     =>  'set',
        find_network    =>  'get',
        no_networks     =>  'is_empty',
        network_count   =>  'count',
        del_network     =>  'delete',
        network_list    =>  'kv'
    }
);

## commands
# Commands are stored in this way:
has commands => (
    traits  =>  ['Hash'],
    is      =>  'ro',
    isa     =>  'HashRef[Code]',
    default =>  sub { {} },
    handles =>  {
        add_command     =>  'set',
        command_find    =>  'get',
        no_commands     =>  'is_empty',
        command_count   =>  'count',
        command_del     =>  'delete',
        command_list    =>  'kv',
    }
);

## command_add(): This is confusing! This must be used to add commands directly.
# Old API: $keldair->command_add(PING => sub { ... });
# New API: $keldair->command_add({ cmd => 'ping', help => 'Check connectivity of bot or user.', code => sub { ... }, ...}[, ...]);
## this method is trained to search for both! It checks the first element to see if it is a HASH. If so, the rest of the elemnts are treated as such. Otherwise, it assumes the rest are using the old API, and there only be two elements (arguments) passed.
## confused?
sub command_add {
    my $self = shift;
    
    my $first = shift;
    if(ref($first) eq 'HASH')
    {
        print "Using new command API for $first->{name} and all commands added in this instance.\n";
        $self->add_command(uc($first->{name}), $first);
        for (@_)
        {
            $self->add_command(uc($_->{name}), $first);
        }
    }
    else
    {
        print "Using old command API for $first\n";
        if(ref($_[1]) ne 'CODE')
        {
            print "command_add(): second argument must be a CODE reference, not ".ref($_[1])."\n";
            return;
        }
        $self->add_command(uc($first), $_[1]);
    }
}


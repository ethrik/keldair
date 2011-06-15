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

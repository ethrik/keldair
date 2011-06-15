# alyx can handle copyright notices.
# NOTICE: Do not modify this module unless you understand it.
package Class::Keldair::Network;
use Mouse;

# Each network has its own set of channels and users right? So thats how we'll do this.

has channels => (
    traits  =>  ['Hash'],
    is      =>  'ro',
    isa     =>  'HashRef[Object]',
    default =>  sub { {} },
    handles =>  {
        add_channel     =>  'set',
        del_channel     =>  'delete',
        find_channel    =>  'get',
        no_channels     =>  'is_empty',
        list_channels   =>  'kv',
        channel_count   =>  'count'
    }
);

# ditto

has users => (
    traits  =>  ['Hash'],
    is      =>  'ro',
    isa     =>  'HashRef[Object]',
    default =>  sub { {} },
    handles =>  {
        add_user     =>  'set',
        del_user     =>  'delete',
        find_user    =>  'get',
        no_users     =>  'is_empty',
        list_users   =>  'kv',
        user_count   =>  'count'
    }
);

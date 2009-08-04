package Blosxom::Entry;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/title body time path name/);

1;
__END__




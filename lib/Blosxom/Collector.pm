package Blosxom::Collector;

use strict;
use warnings;
use base qw(Blosxom::Plugin);

__PACKAGE__->mk_accessors(qw(config));

sub collect {
	die "must implement by subclass";
}

1;
__END__




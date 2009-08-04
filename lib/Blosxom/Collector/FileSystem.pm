package Blosxom::Collector::FileSystem;

use strict;
use warnings;
use base qw(Blosxom::Collector);

use Blosxom::Entry;

use Path::Class;

sub collect {
	my ($self) = @_;
	my $ret = [];

	my $ext = $self->config->{ext};
	my $dir = $self->config->{dir};
	dir($dir)->recurse(callback => sub {
		my $path = shift;
		return if $path->is_dir;
		return unless "$path" =~ /\.$ext$/;

		my ($title, $body) = split /\n/, $path->slurp, 2;
		chomp $title;

		my $name = $path->relative($dir);

		push @$ret, Blosxom::Entry->new({
			title => "$title",
			body  => "$body",
			time  => $path->stat->mtime,
			path  => "$path",
			name  => "$name",
		});
	});
	$ret;
}



1;
__END__




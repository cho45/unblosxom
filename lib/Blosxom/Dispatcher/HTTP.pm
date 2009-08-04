package Blosxom::Dispatcher::HTTP;

use strict;
use warnings;
use base qw(Blosxom::Dispatcher);

use Blosxom;

sub dispatch {
	my ($self, $req, $res) = @_;
	my $blosxom = Blosxom->new({ config => $self->config });

	$blosxom->{req} = $req;

	$req->path =~ /(.+?)(?:\.([^.]+))?$/;
	my ($path, $flavour) = ($1, $2);
	$path =~ s/index$//;

	$blosxom->path($path);
	$blosxom->flavour($flavour || $self->config->{flavour});

	$blosxom->collect_entries;
	$blosxom->sort_entries;
	$blosxom->filter_entries;

	my ($content_type, $content) = $blosxom->render_entries;
	$res->header("Content-Type" => $content_type);
	$res->content($content);
	$res;
}


1;
__END__




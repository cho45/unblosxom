package Blosxom::Dispatcher;

use strict;
use warnings;
use UNIVERSAL::require;
use Blosxom::Config;

sub dispatch {
	my ($class, $req, $res) = @_;
	my $path = $req->path;

	my ($name, $method) = _translate($path);
	
	my $root = $class;
	$root =~ s/::.+?$//;

	my $controller = "$root\::Controller::$name";
	Blosxom::Config->logger->debug("Requested: $path\n");
	Blosxom::Config->logger->debug("Dispatch: $controller - $method\n");
	$controller->use;
	my $instance = $controller->new;
	$instance->$method($req, $res);
	$res;
}

sub _translate {
	my ($path) = @_;
	my $action = "default";
	if ($path =~ s{\.([^/]+)}{}) {
		$action = $1;
	}

	$path =~ s{/([a-z])([a-z]+)}{"::".uc($1).$2}eg;
	$path =~ s{/$}{::Index};
	$path =~ s{^::}{};
	($path, $action);
}


1;
__END__




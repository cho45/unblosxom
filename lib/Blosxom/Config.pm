package Blosxom::Config;

use strict;
use warnings;

use Log::Dispatch;
use Log::Dispatch::Screen;

my $logger = Log::Dispatch->new;
$logger->add(Log::Dispatch::Screen->new(name => "screen", min_level => "debug", stderr => 1));

my $config = {
	Collector => [
		{
			name   => "FileSystem",
			config => {
				data_dir => "data",
			},
		}
	],
	Filter => [
		{ name => "Date" },
		{ name => "Path" },
	],
#	flavors => {
#		html => MicroTemplate => {},
#		rss  => RSS => {},
#	},
};

sub param {
	my ($class, $name) = @_;
	$config->{$name};
}

sub logger {
	$logger;
}


1;
__END__




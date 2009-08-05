package Blosxom;

use strict;
use warnings;
use Path::Class;
use POSIX 'strftime';
use Text::MicroTemplate;
use Blosxom::Collector::FileSystem;
use List::MoreUtils qw(firstval all);
use UNIVERSAL::require;

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/config path flavour plugins/);

sub new {
	my ($class, $config) = @_;
	my $self = $class->SUPER::new($config);
	$self->plugins([]);
	$self->load_plugins;
	$self;
}

sub collect_entries {
	my ($self) = @_;
	my $results = $self->call_plugins("collect");
	$self->{entries} = [ map { @$_ } @$results ];
}

sub sort_entries {
	my ($self) = @_;
	$self->{entries} = [
		sort {
			$b->time <=> $a->time
		}
		@{ $self->{entries} }
	];
}

sub filter_entries {
	my ($self) = @_;
	my $path = $self->{path};

	if ($path =~ m{^/(\d{4})(?:/(\d\d)(?:/(\d\d))?)?}) {
		my ($year, $month, $day) = ($1, $2, $3);
		$self->{entries} = [
			grep {
				my $e = $_;
				all {
					my ($f, $k) = @$_;
					!$k || strftime($f, localtime($e->time)) eq $k
				} ["%Y", $year], ["%m", $month], ["%d", $day];
			}
			@{ $self->{entries} }
		];
	} else {
		my $only = firstval { $_->name eq $self->path } @{ $self->{entries} };
		if ($only) {
			$self->{entries} = [ $only ];
		} else {
			$self->{entries} = [
				grep {
					my $name = $_->name;
					"/$name" =~ /^$path/;
				}
				@{ $self->{entries} }
			];
		}
	}
}

sub render_entries {
	my ($self) = @_;
	my $flavour = $self->flavour;
	my $template = dir($self->config->{template_dir})->file("template.$flavour")->slurp;

	my $code = Text::MicroTemplate->new( template => $template )->code;
	my $renderer = eval << "	..." or die $@;
		sub {
			my \$blosxom = shift;
			$code->();
		}
	...

	my $output = $renderer->($self);
	split /\n\n/, $output, 2;
}

sub load_plugins {
	my ($self) = @_;
	my $plugins = [];
	for (@{ $self->config->{plugins} }) {
		my ($name, $config) = @$_;
		my $class = sprintf("Blosxom::%s", $name);
		$class->use or die sprintf("unknown plugin: %s", $name);
		push @$plugins, $class->new({ config => $config });
	}
	$self->plugins($plugins);
}

sub call_plugins {
	my ($self, $method, @args) = @_;
	my $results = [];
	for my $plugin (@{ $self->plugins }) {
		if ($plugin->can($method)) {
			push @$results, $plugin->$method(@args);
		}
	}
	$results;
}

1;
__END__




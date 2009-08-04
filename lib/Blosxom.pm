package Blosxom;

use strict;
use warnings;
use Path::Class;
use POSIX 'strftime';
use Text::MicroTemplate;
use Blosxom::Collector::FileSystem;
use List::MoreUtils qw(firstval all);

use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw/config path flavour/);

sub dispatch {
	my ($self, $req, $res) = @_;
	$self->{req} = $req;

	$req->path =~ /(.+)(?:\.([^.]+))?$/;
	my ($path, $flavour) = ($1, $2);
	$path =~ /index$/;

	$self->path($path);
	$self->flavour($flavour || $self->config->{flavour});

	$self->collect_entries;
	$self->sort_entries;
	$self->filter_entries;

	my ($content_type, $content) = $self->render_entries;
	$res->header("Content-Type" => $content_type);
	$res->content($content);
	$res;
}

sub collect_entries {
	my ($self) = @_;
	$self->{entries} = Blosxom::Collector::FileSystem->new({ config => $self->config->{FileSystem} })->collect;
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
			use Data::Dumper;
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

sub plugins {
	my ($self, $name) = @_;
	my $ret = [];
	for my $plugin (@{ $self->config->{$name} }) {
		my $class = sprintf("Blosxom::%s::%s", $name, $plugin->{name});
		$class->use or die sprintf("unknown %s: %s", $name, $plugin->{name});
		push @$ret, $class->new($plugin->{config});
	}
	$ret;
}

1;
__END__




#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp qw/ tempdir /;
use Path::Class;
use DateTime;

my $dir = tempdir( CLEANUP => 1 );
sub mkfile ($$;$) {
	my ($path, $time, $content) = @_;

	my $file = dir($dir)->file($path);
	$file->parent->mkpath;
	my $io = $file->open("w");
	$io->write($content);
	$io->close;
	utime $time, $time, "$file";
}

mkfile "test1.txt", DateTime->new( year => 2009, month => 01, day => 01 )->epoch,
	"Title1\nBody\nBody";
mkfile "test2.txt", DateTime->new( year => 2009, month => 01, day => 02 )->epoch,
	"Title2\nBody\nBody";
mkfile "test3.txt", DateTime->new( year => 2009, month => 01, day => 03 )->epoch,
	"Title3\nBody\nBody";
mkfile "foobar/baz1.txt", DateTime->new( year => 2009, month => 01, day => 03 )->epoch,
	"Title Baz1\nBody\nBody";
mkfile "foobar/baz1.unknown", 0,
	"unknown";


use Test::More tests => 2;
use Blosxom::Collector::FileSystem;

my $collector = Blosxom::Collector::FileSystem->new({
	config => {
		dir => $dir,
		ext => ".txt",
	}
});

isa_ok $collector, "Blosxom::Collector";

my $entries = $collector->collect;

is scalar @$entries, 4;

#use Data::Dumper;
#warn Dumper $entries;


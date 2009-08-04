#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp qw/ tempdir /;
use Path::Class;
use DateTime;
use FindBin;

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
mkfile "test4.txt", DateTime->new( year => 2008, month => 01, day => 03 )->epoch,
	"Title4\nBody\nBody";
mkfile "test5.txt", DateTime->new( year => 2009, month => 02, day => 03 )->epoch,
	"Title5\nBody\nBody";
mkfile "foobar/baz1.txt", DateTime->new( year => 2009, month => 01, day => 03 )->epoch,
	"Title Baz1\nBody\nBody";
mkfile "foobar/baz2.txt", DateTime->new( year => 2009, month => 01, day => 03 )->epoch,
	"Title Baz1\nBody\nBody";

mkfile "foobar/baz1.unknown", 0,
	"unknown";

use Test::More tests => 30;

use HTTP::Engine;
use HTTP::Request;

use Blosxom;

my $engine = HTTP::Engine->new(
	interface => {
		module => "Test",
		request_handler => sub {
			my $req = shift;
			my $res = HTTP::Engine::Response->new;

			my $blosxom = Blosxom->new({
				config => {
					flavour      => "json",
					template_dir => "$FindBin::Bin/fixtures/template",
					FileSystem   => {
						ext => "txt",
						dir => "$dir"
					},
				}
			});
			
			$blosxom->dispatch($req, $res);
		}
	}
);


use JSON;
my $res;

$res = $engine->run( HTTP::Request->new( 'GET', '/' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 7;

$res = $engine->run( HTTP::Request->new( 'GET', '/index' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 7;

$res = $engine->run( HTTP::Request->new( 'GET', '/index.test' ) );
is $res->code, 200;
is $res->header("Content-Type"), "application/x-test";
is $res->content, "test\n";

$res = $engine->run( HTTP::Request->new( 'GET', '/2008' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 1;

$res = $engine->run( HTTP::Request->new( 'GET', '/2008.test' ) );
is $res->code, 200;
is $res->header("Content-Type"), "application/x-test";
is $res->content, "test\n";

$res = $engine->run( HTTP::Request->new( 'GET', '/2009' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 6;

$res = $engine->run( HTTP::Request->new( 'GET', '/2009/01' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 5;

$res = $engine->run( HTTP::Request->new( 'GET', '/2009/01/01' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 1;

$res = $engine->run( HTTP::Request->new( 'GET', '/2009/01/02' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 1;

$res = $engine->run( HTTP::Request->new( 'GET', '/2009/01/03' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 3;

$res = $engine->run( HTTP::Request->new( 'GET', '/2009/02' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 1;

$res = $engine->run( HTTP::Request->new( 'GET', '/test1' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 1;

$res = $engine->run( HTTP::Request->new( 'GET', '/foobar' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 2;

$res = $engine->run( HTTP::Request->new( 'GET', '/1900' ) );
is $res->code, 200;
$res = decode_json($res->content);
is scalar @$res, 0;



#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use HTTP::Engine;
use HTTP::Request;

use Blosxom::Dispatcher;

my $engine = HTTP::Engine->new(
	interface => {
		module => "Test",
		request_handler => sub {
			my $req = shift;
			my $res = HTTP::Engine::Response->new;
			Blosxom::Dispatcher->dispatch($req, $res);
		}
	}
);


#my $res =  $engine->run( HTTP::Request->new( 'GET', '/' ) );
#
#is $res->code, 200;
#is $res->content, "foobar";
#
#my $res =  $engine->run( HTTP::Request->new( 'GET', '/.hello?name=foobar' ) );
#
#is $res->code, 200;
#is $res->content, "Hello! foobar";
#

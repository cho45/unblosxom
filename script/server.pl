#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
sub p ($) { warn Dumper shift }

use Perl6::Say;

use HTTP::Engine;

use Blosxom::Dispatcher::HTTP;

HTTP::Engine->new(
	interface => {
		module => "ServerSimple",
		args   => {
			port => "3005"
		},
		request_handler => sub {
			my $req = shift;
			my $res = HTTP::Engine::Response->new;

			Blosxom::Dispatcher::HTTP->new({
				config => {
					flavour => "html",
					template_dir => "template",
					FileSystem => {
						ext => "txt",
						dir => "data"
					},
				}
			})->dispatch($req, $res);
		}
	}
)->run;



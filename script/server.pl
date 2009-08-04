#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
sub p ($) { warn Dumper shift }

use Perl6::Say;

use HTTP::Engine;

use Blosxom;
use Blosxom::Dispatcher;

HTTP::Engine->new(
	interface => {
		module => "ServerSimple",
		args   => {
			port => "3005"
		},
		request_handler => sub {
			my $req = shift;
			my $res = HTTP::Engine::Response->new;

			my $blosxom = Blosxom->new({
				config => {
					flavour => "html",
					template_dir => "template",
					FileSystem => {
						ext => "txt",
						dir => "data"
					},
				}
			});
			
			$blosxom->dispatch($req, $res);
		}
	}
)->run;



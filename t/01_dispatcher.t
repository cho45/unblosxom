
use strict;
use warnings;

use Test::More qw/no_plan/;

use Blosxom::Dispatcher;


is_deeply [ Blosxom::Dispatcher::_translate("/") ], ["Index", "default"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo") ], ["Foo", "default"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/") ], ["Foo::Index", "default"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/bar") ], ["Foo::Bar", "default"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/bar/") ], ["Foo::Bar::Index", "default"];

is_deeply [ Blosxom::Dispatcher::_translate("/.hello") ], ["Index", "hello"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo.hello") ], ["Foo", "hello"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/.hello") ], ["Foo::Index", "hello"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/bar.hello") ], ["Foo::Bar", "hello"];
is_deeply [ Blosxom::Dispatcher::_translate("/foo/bar/.hello") ], ["Foo::Bar::Index", "hello"];


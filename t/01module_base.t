package Bot::BasicBot::Pluggable::Module::Nil;
use parent 'Bot::BasicBot::Pluggable::Module';
1;

package main;

use warnings;
use strict;
use Test::More tests => 11;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();

ok(my $base = $bot->load('Nil'), "created base module");
ok($base->var('test', 'value'), "set variable");
ok($base->var('test') eq 'value', 'got variable');

ok($base->unset('test'), 'unset variable');
ok(!defined($base->var('test')), "it's gone");

# very hard to do anything but check existence of these methods
ok($base->can($_), "'$_' exists")
  for (qw(said connected tick emoted init));

ok($base->help, "help returns something");

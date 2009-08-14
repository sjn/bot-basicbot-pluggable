use strict;
use warnings;
use Test::More tests => 10;
use App::Bot::BasicBot::Pluggable;

## Testing defaults

our @ARGV = ();

my $app = App::Bot::BasicBot::Pluggable->new_with_options();

is($app->server,'localhost','checking default for server');
is($app->port,6667,'checking default for port');
is($app->nick,'basicbot','checking default for basicbot');
is($app->charset,'utf8','checking default for charset');
is($app->store,'Memory','checking default for store');
ok(!$app->list_modules,'checking default for list_modules');
ok(!$app->list_stores,'checking default for list_stores');
is_deeply($app->settings,{},'checking default for settings');
is_deeply($app->module,['Auth','Loader'],'checking default for modules');
is_deeply($app->channel,[],'checking default for channel');

__END__
@ARGV = (qw( 
	--server ems 
	--port 7776
));

$app = App::Bot::BasicBot::Pluggable->new_with_options();

is ($app->server,'ems','setting server via commandline');
is ($app->port,7776,'setting port via commandline');

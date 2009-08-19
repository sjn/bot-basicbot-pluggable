use strict;
use warnings;
use Test::More tests => 21;

BEGIN {
    use_ok('Bot::BasicBot::Pluggable::Message');
}

ok(
    my $message = Bot::BasicBot::Pluggable::Message->new(
        who     => 'user',
        address => 'basicbot',
        body    => '!auth admin julia',
        channel => 'msg',
    ),
    'create new message'
);
is( $message->{who},     'user',              'accessing user attribute - old style' );
is( $message->{address}, 'basicbot',          'accessing address attribute - old style' );
is( $message->{body},    '!auth admin julia', 'accessing body attribute - old style' );
is( $message->{channel}, 'msg',               'accessing channel attribute - old style' );

is( $message->who,     'user',              'accessing user attribute' );
is( $message->address, 'basicbot',          'accessing address attribute' );
is( $message->body,    '!auth admin julia', 'accessing body attribute' );
is( $message->channel, 'msg',               'accessing channel attribute' );
ok( $message->is_prefixed(), 'message is prefixed' );
is_deeply( [ $message->args() ], [ 'admin', 'julia' ], 'message command is auth' );
is( $message->command(), 'auth', 'message command is auth' );

ok( $message->is_privmsg(),   'message is privmsg' );
ok( $message->is_private(),   'message is private' );
ok( $message->is_addressed(), 'message is addressed' );

ok(
    $message = Bot::BasicBot::Pluggable::Message->new(
        {
            who     => 'user',
            address => 'basicbot',
            body    => '!auth admin julia',
            channel => '#foo',
        }
    ),
    'create new message from hashref'
);

ok( $message->is_addressed(), 'message is addressed in channel' );
ok( ! $message->is_privmsg(),   '... but not as privmsg' );
ok( ! $message->is_private(),   '... and therefor not private' );

$message->body('foo " foo bar " quux');

is_deeply( [ $message->args() ], [ ' foo bar ', 'quux' ], 'quotelike operaters are splitted as one' );


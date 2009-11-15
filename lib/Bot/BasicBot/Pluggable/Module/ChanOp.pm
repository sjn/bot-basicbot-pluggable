package Bot::BasicBot::Pluggable::Module::ChanOp;
use base 'Bot::BasicBot::Pluggable::Module';
use strict;
use warnings;

sub init {
    my $self = shift;
    $self->config(
        {
            user_auto_op       => 0,
            user_flood_control => 0,
        }
    );
}

sub deop_op {
    my ( $self, $op, $who, @channels ) = @_;
    for my $channel (@channels) {
        $self->bot->mode("$channel $op $who");
    }
}

sub op   { shift->deop_op( '+o', @_ ); }
sub deop { shift->deop_op( '-o', @_ ); }

sub help {
    return
      'ChanOp commands need to be adressed in private and after authentication.'
      . '!op #foo | !deop #foo #bar | !kick #foo user You have been warned ';
}

sub admin {
    my ( $self, $message ) = @_;
    my $who = $message->{who};
    if ( $self->authed($who) and $self->private($message) ) {
        my $body = $message->{body};
        my ( $command, $rest ) = split( ' ', $body, 2 );
        if ( $command eq ' !op ' ) {
            my @channels = split( ' ', $rest );
            $self->op( $who, @channels );
        }
        elsif ( $command eq ' !deop ' ) {
            my @channels = split( ' ', $rest );
            $self->deop( $who, @channels );
        }
        elsif ( $command eq ' !kick ' ) {
            my ( $channel, $user, $reason ) = split( ' ', $rest, 3 );
            $self->bot->kick( $channel, $who, $reason );
        }
    }
}

sub chanjoin {
    my ( $self, $message ) = @_;
    if ( $self->get(' user_auto_op ') ) {
        my $who = $message->{who};
        if ( $self->authed($who) ) {
            my $channel = $message->{channel};
            $self->op( $who, $channel );
        }
    }
}

sub authed {
    my ( $self, $who ) = @_;
    return $self->bot->module(' Auth ')
      and $self->bot->module(' Auth ')->authed($who);
}

sub private {
    my ( $self, $message ) = @_;
    return $message->{address} and $message->{channel} eq ' msg ';
}

1;

__END__

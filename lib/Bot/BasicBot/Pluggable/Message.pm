package Bot::BasicBot::Pluggable::Message;
use Moose;

has who     => ( is => 'rw', isa => 'Str' );
has channel => ( is => 'rw', isa => 'Str' );
has body    => ( is => 'rw', isa => 'Str' );
has address => ( is => 'rw', isa => 'Str' );

__PACKAGE__->meta->make_immutable;

sub is_privmsg {
    my ($self) = @_;
    return !$self->channel || $self->channel eq 'msg';
}

sub is_directed {
    return shift->address;
}

sub split {
    my ( $self, $limit ) = @_;
    my ($command,@args) = split( ' ', $self->body(), $limit );
    $command = lc $command;
    return $command,@args;
}

sub prefixed {
    my ($self) = @_;
    return 0 unless $self->body =~ /^!/;
}

1;

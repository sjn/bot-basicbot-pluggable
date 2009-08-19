package Bot::BasicBot::Pluggable::Message;
use Moose;
use Text::Balanced qw(extract_multiple extract_quotelike);

has who     => ( is => 'rw', isa => 'Str' );
has channel => ( is => 'rw', isa => 'Str' );
has body    => ( is => 'rw', isa => 'Str', trigger => \&_body_set );
has address => ( is => 'rw', isa => 'Str', predicate => 'is_addressed' );
has prefix  => ( is => 'rw', isa => 'Str', default => '!' );

has command => ( is => 'rw', isa => 'Str' );
has args    => ( is => 'rw', isa => 'ArrayRef[Str]', auto_deref => 1 );

__PACKAGE__->meta->make_immutable;

sub _body_set {
    my ($self) = @_;
    my ( $command, @args ) = $self->split();
    $self->command($command);
    $self->args( [@args] );
}

sub is_privmsg {
    my ($self) = @_;
    return !$self->channel || $self->channel eq 'msg';
}

sub is_private {
    my ($self) = @_;
    return $self->is_privmsg and $self->is_addressed;
}

sub split {
    my ( $self, $limit ) = @_;

    $limit ||= 0;
    my $body   = $self->body();
    my $prefix = $self->prefix;

    $body =~ s/^$prefix//;

    my ( $command, @args ) =
      extract_multiple( $body,
        [ sub { ( extract_quotelike( $_[0], '' ) )[5] }, qr/\s*([\S]+)\s*/, ],
        undef, $limit );
    $command = lc $command;
    return $command, @args;
}

sub is_prefixed {
    my ($self) = @_;
    my $prefix = $self->prefix;
    return 0 unless $self->body =~ /^$prefix/;
}

1;

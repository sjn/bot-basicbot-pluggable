package Bot::BasicBot::Pluggable::Message;
use Moose;

has who     => ( is => 'rw', isa => 'Str' );
has channel => ( is => 'rw', isa => 'Str' );
has body    => ( is => 'rw', isa => 'Str' );
has address => ( is => 'rw', isa => 'Str' );
has prefix  => ( is => 'rw', isa => 'Str', default => '!' );

has command =>
  ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_command' );
has args =>
  ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_command' );

__PACKAGE__->meta->make_immutable;

sub _build_command {
	my ($self) = @_;
	my ($command,$args) = $self->split();
	$self->command($command);
	$self->args([@args]);
}

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

sub is_prefixed {
    my ($self) = @_;
    my $prefix = $self->prefix;
    return 0 unless $self->body =~ /^$prefix/;
}

1;

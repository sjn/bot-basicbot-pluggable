package Bot::BasicBot::Pluggable::Message;
use Moose;
use Text::Balanced qw(extract_multiple extract_quotelike);

has who      => ( is => 'rw', isa => 'Str' );
has raw_nick => ( is => 'rw', isa => 'Str' );
has channel  => ( is => 'rw', isa => 'Str' );
has body     => ( is => 'rw', isa => 'Str', trigger => \&_body_set );
has address  => ( is => 'rw', isa => 'Str', predicate => 'is_addressed' );
has prefix   => ( is => 'rw', isa => 'Str', default => '!' );

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

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Message - event dispatch informations

=head1 SYNOPSIS

  my $store = Bot::BasicBot::Pluggable::Store::DBI->new(
    dsn          => "dbi:mysql:bot",
    user         => "user",
    password     => "password",
    table        => "brane",

    # create indexes on key/values?
    create_index => 1,
  );

  $store->set( "namespace", "key", "value" );
  
=head1 DESCRIPTION

Every time L<Bot::BasicBot::Pluggable> dispatches an event to one
of your module, an object is handed over to the dispatched subroutine.

=head1 ATTRIBUTES

=head2 who

Who said it (the nick that said it)

=head2 raw_nick

The raw IRC nick string of the person who said it. Only really useful if you want more security for some reason.
channel

The channel in which they said it. Has special value "msg" if it
was in a message. Actually, you can send a message to many channels
at once in the IRC spec, but no-one actually does this so this is
just the first one in the list.

=head2 body

The body of the message (i.e. the actual text)

=head2 address

The text that indicates how we were addressed. Contains the string
"msg" for private messages, otherwise contains the string off the
text that was stripped off the front of the message if we were
addressed, e.g. "Nick: ". Obviously this can be simply checked for
truth if you just want to know if you were addressed or not.

=head1 AUTHOR

Mario Domgoergen <mdom@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.



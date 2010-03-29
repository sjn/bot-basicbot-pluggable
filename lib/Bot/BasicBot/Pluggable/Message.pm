package Bot::BasicBot::Pluggable::Message;
use Moose;
use Text::Balanced qw(extract_multiple extract_quotelike);

has who        => ( is => 'rw', isa => 'Str' );
has raw_nick   => ( is => 'rw', isa => 'Str' );
has channel    => ( is => 'rw', isa => 'Str' );
has reply_hook => ( is => 'rw', isa => 'CodeRef' );
has body       => ( is => 'rw', isa => 'Str', trigger => \&_body_set );
has address    => ( is => 'rw', isa => 'Str', predicate => 'is_addressed' );
has prefix     => ( is => 'rw', isa => 'Str', default => '!' );

has command => ( is => 'ro', writer => '_set_command', isa => 'Str' );
has args    => ( is => 'ro', writer => '_set_args',    isa => 'ArrayRef[Str]', auto_deref => 1 );

__PACKAGE__->meta->make_immutable;

sub _body_set {
    my ($self) = @_;
    my ( $command, @args ) = $self->split();
    $self->_set_command($command);
    $self->_set_args( [@args] );
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

  $message = Bot::BasicBot::Pluggable::Message->new(
      who     => 'me',
      channel => '#botzone',
      body    => 'Does anybody see me?',
      address => 0,
  );

  

=head1 DESCRIPTION

Every time L<Bot::BasicBot::Pluggable> dispatches an event to one
of your module, an object is handed over to the dispatched subroutine.

=head1 ATTRIBUTES

=head2 who

The nick which originated the message.

=head2 raw_nick

The raw IRC nick string of the person who said it. Only really
useful if you want more security for some reason.

=head2 channel

The channel in which they said it. Has special value "msg" if it
was in a message. Actually, you can send a message to many channels
at once in the IRC spec, but no-one actually does this so this is
just the first one in the list.

=head2 body

The body of the message (i.e. the actual text).

=head2 address

The text that indicates how we were addressed. Contains the string
"msg" for private messages, otherwise contains the string off the
text that was stripped off the front of the message if we were
addressed, e.g. "Nick: ". Obviously this can be simply checked for
truth if you just want to know if you were addressed or not.

=head2 prefix

The default prefix character. Defaults to I<!>. It's commonly used
for system modules like I<Auth> or I<Loader>.

=head2 reply_hook

The code reference is called every time the a handler returns a
value to the bot. It's only argument is the message returned.

=head1 METHODS

=head2 command

Every time the body attribute is changed or initialized, it's split
on whitespace and the first element can be accessed via this method.
The command is lowercased to help matching it in a dispatch table.
The arguments to the command are accessable by the I<args> methods.

=head2 args

Every time the body attribute is changed or initialized, it's split
on whitespace and all element ebut the first are returned as list
by this method.  The first arguments of the body is accessable by
the I<command> methods.

=head2 is_privmsg

Returns true if the message was produced by an IRC message. 

=head2 is_private

Returns true if the message was directly addressed and and in a
privmsg.

=head2 is_prefixed

Returns true if the message was prefixed by the prefix character
set by the I<prefix> method.

=head1 AUTHOR

Mario Domgoergen <mdom@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.



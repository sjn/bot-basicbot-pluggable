package App::Bot::BasicBot::Pluggable;
use Config::Find;
use Bot::BasicBot::Pluggable;
use Moose;
with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';
use Moose::Util::TypeConstraints;
use List::MoreUtils qw(any);

subtype 'App::Bot::BasicBot::Pluggable::Channels'
	=> as 'ArrayRef'
	## Either it's an empty ArrayRef or all channels start with #
	=> where { @{$_} ? any { /^#/ } @{$_} : 1 };

coerce 'App::Bot::BasicBot::Pluggable::Channels'
	=> from 'ArrayRef'
	=> via { [ map { /^#/ ? $_ : "#$_" } @{$_} ] };

has server  => ( is => 'rw', isa => 'Str', required => 1 );
has nick    => ( is => 'rw', isa => 'Str', default  => 'basicbot' );
has charset => ( is => 'rw', isa => 'Str', default  => 'utf8' );
has channel => ( is => 'rw', isa => 'App::Bot::BasicBot::Pluggable::Channels', coerce => 1, default => sub { []  });
has password => ( is => 'rw', isa => 'Str' );
has port     => ( is => 'rw', isa => 'Int', default => 6667 );

has store    => ( is => 'rw', isa => 'Str', default => 'Memory' );
has settings => ( metaclass => 'NoGetopt', is => 'rw', isa => 'HashRef', default => sub {{}} );

has configfile => (
    is      => 'rw',
    isa     => 'Str',
    default => Config::Find->find( name => 'bot-basicbot-pluggable.yaml' ),
);

has bot => (
    metaclass => 'NoGetopt',
    is        => 'rw',
    isa       => 'Bot::BasicBot::Pluggable',
    builder   => '_create_bot',
    lazy      => 1,
    handles   => [ 'run' ],
);

has module => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { return [qw( Auth Loader )] }
);

sub BUILD {
    my ($self) = @_;
    if ( $self->password() ) {
        my %module = map { $_ => 1 } @{ $self->module() };
        $module{Auth} = 1;
        $self->module( [ keys %module ] );
    }
    $self->_load_modules();
}

sub _load_modules {
    my ($self) = @_;
    my %settings = %{$self->settings()};
    for my $module_name ( @{ $self->module() } ) {
        my $module = $self->bot->load($module_name);
        if ( exists( $settings{$module_name} ) ) {
            for my $key ( keys %{ $settings{$module_name} } ) {
                $module->set( $key, $settings{$module_name}->{$key} );
            }
        }
        if ( $module_name eq 'Auth' and $self->password() ) {
            $module->set( 'password_admin', $self->password() );
        }
    }
}

sub _create_bot {
    my ($self) = @_;
    return Bot::BasicBot::Pluggable->new(
        channels => $self->channel(),
        server   => $self->server(),
        nick     => $self->nick(),
        charset  => $self->charset(),
        port     => $self->port(),
        store    => $self->store(),
    );
}

1;

package App::Bot::BasicBot::Pluggable;
use Config::Find;
use Bot::BasicBot::Pluggable;
use Moose;
with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has server  => ( is => 'rw', isa => 'Str', required => 1 );
has nick    => ( is => 'rw', isa => 'Str', default  => 'basicbot' );
has charset => ( is => 'rw', isa => 'Str', default  => 'utf8' );
has channel => ( is => 'rw', isa => 'ArrayRef' );
has password => ( is => 'rw', isa => 'Str' );
has port => ( is => 'rw', isa => 'Int', default => 6667 );

has settings => ( metaclass => 'NoGetopt', is => 'rw', isa => 'HashRef' );

has configfile => (
    is      => 'rw',
    isa     => 'Str',
    default => Config::Find->find( name => 'bot-basicbot-pluggable.yaml' ),
);

has bot => (
    metaclass => 'NoGetopt',
    is        => 'rw',
    isa       => 'Bot::BasicBot::Pluggable',
    builder   => 'create_bot',
    lazy      => 1,
    handles   => [ 'run' ],
);

has module => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { return [qw( Auth Loader )] }
);

sub BUILDER {
    my ($self) = @_;
    if ( $self->password() ) {
        my %module = map { $_ => 1 } @{ $self->modules() };
        $module{Auth} = 1;
        $self->modules( [ keys %module ] );
    }

    for my $module_name ( @{ $self->module() } ) {
        my $module = $self->bot->load($module_name);
        if ( $self->settings ) {
            my %settings = $self->settings;
            if ( exists( $settings{$module_name} ) ) {
                for my $key ( keys %{ $settings{$module_name} } ) {
                    $module->set( $key, $settings{$module_name}->{$key} );
                }
            }
        }
        if ( $module_name eq 'Auth' and $self->password() ) {
            $module->set( 'password_admin', $self->password() );
        }
    }

}

sub create_bot {
    my ($self) = @_;
    return Bot::BasicBot::Pluggable->new(
        channels => $self->channel(),
        server   => $self->server(),
        nick     => $self->nick(),
        charset  => $self->charset(),
        port     => $self->port(),
    );
}

1;

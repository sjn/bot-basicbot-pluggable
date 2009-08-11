package App::Bot::BasicBot::Pluggable;
use Config::Find;
use Moose;
with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has server   => ( is => 'ro', isa => 'Str', required => 1 );
has nick     => ( is => 'ro', isa => 'Str', default  => 'basicbot' );
has charset  => ( is => 'ro', isa => 'Str', default  => 'utf8' );
has channel  => ( is => 'ro', isa => 'ArrayRef' );
has password => ( is => 'ro', isa => 'Str' );
has port     => ( is => 'ro', isa => 'Int', default => 6667 );

has settings => ( metaclass => 'NoGetopt', is => 'rw', isa => 'HashRef');

has configfile => ( 
    is => 'ro', 
    isa => 'Str', 
    #builder   => '_build_configfile',
    default => sub { return Config::Find->find(name => 'bot-basicbot-pluggable.yaml'); },
);

sub _build_configfile {
	return Config::Find->find(name => 'bot-basicbot-pluggable.yaml');
}

has module => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { return [qw( Auth Loader )] }
);

sub BUILDER {
	my ($self) = @_;
	if ($self->password()) {
		my %module = map { $_ => 1 } @{$self->modules()};
		$module{Auth} = 1;
		$self->modules( [ keys %module ] );
	}
}

1;

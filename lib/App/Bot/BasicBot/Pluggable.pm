package App::Bot::BasicBot::Pluggable;
use Config::Find;
use Moose;
with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has server  => ( is => 'ro', isa => 'Str', required => 1 );
has nick    => ( is => 'ro', isa => 'Str', default  => 'basicbot' );
has charset => ( is => 'ro', isa => 'Str', default  => 'utf8' );
has channel => ( is => 'ro', isa => 'ArrayRef' );
has password => ( is => 'ro', isa => 'Str' );

has configfile => ( 
    is => 'ro', 
    isa => 'Str', 
);

has module => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { return [qw( Auth Loader )] }
);

sub _build_configfile {
	return Config::Any->find();
}

sub BUILDER {
	my ($self) = @_;
	if ($self->password()) {
		my %module = map { $_ => 1 } @{$self->modules()};
		$module{Auth} = 1;
		$self->modules( [ keys %module ] );
	}
}

1;

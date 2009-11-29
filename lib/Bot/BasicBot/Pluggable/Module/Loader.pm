package Bot::BasicBot::Pluggable::Module::Loader;
use base qw(Bot::BasicBot::Pluggable::Module);
use warnings;
use strict;

sub init {
    my $self = shift;
    my @modules = $self->store_keys;
    for (@modules) {
      eval { $self->{Bot}->load($_) };
      warn "Error loading $_: $@." if $@;
    }
}

sub help {
    return "Module loader and unloader. Usage: !load <module>, !unload <module>, !reload <module>, !list.";
}

sub maybe_join {
	my ($sep,@list) = @_;
	return $list[0]         if  @list == 1;
	return join($sep,@list) if  @list > 1;
	return ''               if !@list;
	return;
}

sub told {
    my ($self, $mess) = @_;
    my $body = $mess->{body};

    # we don't care about commands that don't start with '!'
    return 0 unless defined $body;
	return 0 unless $body =~ /^!/;

    my ($command, $param) = split(/\s+/, $body, 2);
    $command = lc($command);

    if ($command eq "!list") {
	my %available = map { lc $_ => $_ } $self->bot->available_modules();
	my @loaded    = map { delete $available{$_} } @{$self->bot->handlers()};
	my @available = values %available;

	my $loaded    = maybe_join(', ', sort @loaded);
	my $available = maybe_join(', ', sort @available);
        return "Loaded modules: $loaded\nAvailable modules: $available";

    } elsif ($command eq "!load") {
        eval { $self->bot->load($param) } or return "Failed: $@.";
        $self->set( $param => 1 );
        return "Success.";

    } elsif ($command eq "!reload") {
        eval { $self->bot->reload($param) } or return "Failed: $@.";
        return "Success.";

    } elsif ($command eq "!unload") {
        eval { $self->bot->unload($param) } or return "Failed: $@.";
        $self->unset( $param );
        return "Success.";
    }
}

1;

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::Loader - loads and unloads bot modules; remembers state

=head1 IRC USAGE

=over 4

=item !load <module>

Loads the named module.

=item !unload <module>

Unloads the named module.

=item !reload <module>

Reloads a module (combines !unload and !load).

=item !list

Lists all loaded modules.

=back

=head1 AUTHOR

Mario Domgoergen <mdom@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

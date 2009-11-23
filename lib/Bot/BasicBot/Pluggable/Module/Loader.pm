package Bot::BasicBot::Pluggable::Module::Loader;
use base qw(Bot::BasicBot::Pluggable::Module);
use warnings;
use strict;
use Try::Tiny;

sub init {
    my $self = shift;
    my @modules = $self->store_keys;
    for (@modules) {
      try   { $self->{Bot}->load($_) } 
      catch { warn "Error loading $_: $@."  };
    }
}

sub help {
    return "Module loader and unloader. Usage: !load <module>, !unload <module>, !reload <module>, !list.";
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
        return "Modules: ".join(", ", $self->store_keys).".";

    } elsif ($command eq "!load") {
        try { $self->bot->load($param) } catch { return "Failed: $@." };
        $self->set( $param => 1 );
        return "Success.";

    } elsif ($command eq "!reload") {
        try { $self->bot->reload($param) } catch { return "Failed: $@." };
        return "Success.";

    } elsif ($command eq "!unload") {
        try { $self->bot->unload($param) } catch { return "Failed: $@." };
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

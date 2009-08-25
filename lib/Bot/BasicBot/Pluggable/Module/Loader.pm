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

=cut

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

sub told {
    my ($self, $message) = @_;

    return if ! $message->is_prefixed;

    my $command  = $message->command();
    my ($module) = $message->args();

    if ($command eq "!list") {
        return "Modules: ".join(", ", $self->store_keys).".";

    } elsif ($command eq "!load") {
        eval { $self->bot->load($module) } or return "Failed: $@.";
        $self->set( $module => 1 );

    } elsif ($command eq "!reload") {
        eval { $self->bot->reload($module) } or return "Failed: $@.";

    } elsif ($command eq "!unload") {
        eval { $self->bot->unload($module) } or return "Failed: $@.";
        $self->unset( $module );
    }
    return "Success.";
}

1;

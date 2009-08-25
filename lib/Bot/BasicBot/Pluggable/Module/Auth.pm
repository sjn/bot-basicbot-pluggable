
=head1 NAME

Bot::BasicBot::Pluggable::Module::Auth - authentication for Bot::BasicBot::Pluggable modules

=head1 SYNOPSIS

This module catches messages at priority 1 and stops anything starting
with '!' unless the user is authed. Most admin modules, e.g. Loader, can
merely sit at priority 2 and assume the user is authed if the !command
reaches them. If you want to use modules that can change bot state, like
Loader or Vars, you almost certainly want this module.

=head1 IRC USAGE

The default user is 'admin' with password 'julia'. Change this.

=over 4

=item !auth <username> <password>

Authenticate as an administrators. Logins timeout after an hour.

=item !adduser <username> <password>

Adds a user with the given password.

=item !deluser <username>

Deletes a user. Don't delete yourself, that's probably not a good idea.

=item !password <old password> <new password>

Change your current password (must be logged in first).

=item !users

List all the users the bot knows about.

=back

=head1 METHODS

The only useful method is C<authed()>:

=over 4

=item authed($username)

Returns 1 if the given username is logged in, 0 otherwise:

  if ($bot->module("Auth")->authed("jerakeen")) { ... }

=back

=head1 BUGS

All users are admins. This is fine at the moment, as the only things that need
you to be logged in are admin functions. Passwords are stored in plaintext, and
are trivial to extract for any module on the system. I don't consider this a
bug, because I assume you trust the modules you're loading. If Auth is I<not>
loaded, all users effectively have admin permissions. This may not be a good
idea, but is also not an Auth bug, it's an architecture bug.

=head1 AUTHOR

Mario Domgoergen <mdom@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut

package Bot::BasicBot::Pluggable::Module::Auth;
use base qw(Bot::BasicBot::Pluggable::Module);
use warnings;
use strict;

sub init {
    my $self = shift;
    $self->config( { password_admin => "julia" } );
}

sub help {
    return
        "Authenticator for admin-level commands. "
      . "Usage: "
      . "!auth <username> <password>, "
      . "!adduser <username> <password>, "
      . "!deluser <username>, "
      . "!password <old password> <new password>, "
      . "!users.";
}

sub admin {
    my ( $self, $message ) = @_;

    return if not( $message->is_prefixed and $message->is_private );

    my $command = $message->command();
    my @args    = $message->args();
    my $who     = $message->who();

    my %subcommand = (
        auth => {
            args  => 2,
            auth  => 0,
            usage => "Usage: !auth <username> <password>.",
            func  => sub {
                my ( $user, $pass ) = $message->args;
                my $stored = $self->get( "password_" . $user );
                if ( $pass and $stored and $pass eq $stored ) {
                    $self->{auth}{$who}{time}     = time();
                    $self->{auth}{$who}{username} = $user;
                    if ( $user eq "admin" and $pass eq "julia" ) {
                        return "Authenticated. But change the password - you're using the default.";
                    }
                    return "Authenticated.";
                }
                else {
                    delete $self->{auth}{$who};
                    return "Wrong password.";
                }
              }
        },
        adduser => {
            args  => 2,
            auth  => 1,
            usage => "Usage: !adduser <username> <password>",
            func  => sub {
                my ( $user, $pass ) = @args;
                $self->set( "password_" . $user, $pass );
                return "Added user $user.";
            },
        },
        deluser => {
            args  => 1,
            auth  => 1,
            usage => "Usage: !deluser <username>",
            func  => sub {
                my $user = $args[0];
                $self->unset( "password_" . $user );
                return "Deleted user $user.";
            },
        },
        password => {
            args  => 2,
            auth  => 1,
            usage => "Usage: !password <old password> <new password>.",
            func  => sub {
                my ( $old_pass, $pass ) = @args;
                my $username = $self->{auth}{$who}{username};
                if ( $old_pass eq $self->get("password_$username") ) {
                    $self->set( "password_$username", $pass );
                    return "Changed password to $pass.";
                }
                else {
                    return "Wrong password.";
                }
            },
        },

        users => {
            auth => 0,
            func => sub {
                return "Users: "
                  . join( ", ",
                    map { s/^password_// ? $_ : () }
                      $self->store_keys( res => ["^password"] ) )
                  . ".";
              }
        }
    );
    $subcommand{passwd} = $subcommand{password};
    my $spec = $subcommand{$command};
    if ($spec) {
        if ( defined $spec->{args} and $spec->{args} != @args ) {
            return $spec->{usage};
        }
        if ( $spec->{auth} and !$self->authed($who) ) {
            return "You need to authenticate.";
        }
        return $spec->{func}->();
    }
}

sub authed {
    my ( $self, $username ) = @_;
    return 1
      if (  $self->{auth}{$username}{time}
        and $self->{auth}{$username}{time} + 7200 > time() );
    return 0;
}

1;

package SweetPea::Cli::Help;

use warnings;
use strict;

=head1 NAME

SweetPea::Cli::Help - Help documentation for SweetPea-Cli

=head1 METHODS

=head2 new

    Instantiate a new help display object for SweetPea-Cli.

=cut

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    bless $self, $class;
    return $self;
}


=head2 display

    Show help screen for a given function 

=cut

sub display {
    my $self = shift;
    my ($cmd, $c) = @_;
    my $u = SweetPea::Cli::Util->new;
    my $e = SweetPea::Cli::Error->new;
    
    if (defined $c->{_commands}->{$cmd}) {
        return $u->template("documents/help/$cmd"."_help.tt", $c);
    }
    else {
        return $e->error("Sorry, cannot find help for $cmd.")->report($c);
    }
}

=head1 AUTHOR

Al Newkirk, C<< <al.newkirk at awnstudio.com> >>

=head1 ACKNOWLEDGEMENTS

Al Newkirk <al.newkirk@awnstudio.com>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Al Newkirk, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of SweetPea::Cli::Help
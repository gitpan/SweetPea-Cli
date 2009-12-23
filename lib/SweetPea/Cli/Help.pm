package SweetPea::Cli::Help;

use warnings;
use strict;

# SweetPea::Cli::Help - Help documentation for SweetPea-Cli

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    bless $self, $class;
    return $self;
}


# display
# Show help screen for a given function 

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

1; # End of SweetPea::Cli::Help
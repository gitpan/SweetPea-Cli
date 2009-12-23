package SweetPea::Cli::Flash;

use warnings;
use strict;

use SweetPea::Cli::Util;

# SweetPea::Cli::Flash - Flash handling for SweetPea-Cli.

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    bless $self, $class;
    $self->{base}       = $s;
    $self->{flashes}    = [];
    return $self;
}

# flash
# The flash method is responsible for storing passed in error messages
# for later retrieval and rendering.

sub flash {
    my $self = shift;
    foreach my $message (@_) {
        push @{$self->{flashes}}, $message;
    }
    return $self;
}

# count
# The count method returns the number of error messages currently
# existing in the error messages container.

sub count {
    return @{shift->{flashes}};
}

# clear
# The clear method resets the error message container.

sub clear {
    shift->{flashes} = [];
}

# report
# The report method is responsible for displaying all stored error
# messages using the defined message delimiter.

sub report {
    my $self = shift;
    my $c = shift;
    my $u = SweetPea::Cli::Util->new;
    if ($c) {
        $c->stash->{flashes} = $self->{flashes};
        $self->clear;
        return $u->template('misc/text_string.tt', $c);
    }
}

1; # End of SweetPea::Cli::Flash

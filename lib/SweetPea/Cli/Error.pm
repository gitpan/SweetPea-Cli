package SweetPea::Cli::Error;

use warnings;
use strict;

use SweetPea::Cli::Util;

# SweetPea::Cli::Error - Error handling for SweetPea-Cli.

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    bless $self, $class;
    $self->{base}       = $s;
    $self->{errors}     = [];
    return $self;
}

# error# The error method is responsible for storing passed in error messages
# for later retrieval and rendering.

sub error {
    my $self = shift;
    foreach my $message (@_) {
        push @{$self->{errors}}, $message;
    }
    return $self;
}

# count
# The count method returns the number of error messages currently
# existing in the error messages container.

sub count {
    return @{shift->{errors}};
}

# clear
# The clear method resets the error message container.

sub clear {
    shift->{errors} = [];
}

# report
# The report method is responsible for displaying all stored error
# messages using the defined message delimiter.

sub report {
    my $self = shift;
    my $c = shift;
    my $u = SweetPea::Cli::Util->new;
    if ($c) {
        $c->stash->{errors} = $self->{errors};
        $self->clear;
        return $u->template('misc/error_string.tt', $c);
    }
}

1; # End of SweetPea::Cli::Error

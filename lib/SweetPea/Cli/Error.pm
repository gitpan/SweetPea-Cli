package SweetPea::Cli::Error;

use warnings;
use strict;

use SweetPea::Cli::Util;

=head1 NAME

SweetPea::Cli::Error - Error handling for SweetPea-Cli.

=cut

=head1 METHODS

=head2 new

    Instantiate a new exception object for SweetPea-Cli.

=cut

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    bless $self, $class;
    $self->{base}       = $s;
    $self->{errors}     = [];
    return $self;
}

=head2 error

    The error method is responsible for storing passed in error messages
    for later retrieval and rendering.

=cut

sub error {
    my $self = shift;
    foreach my $message (@_) {
        push @{$self->{errors}}, $message;
    }
    return $self;
}

=head2 count

    The count method returns the number of error messages currently
    existing in the error messages container.

=cut

sub count {
    return @{shift->{errors}};
}

=head2 clear

    The clear method resets the error message container.

=cut

sub clear {
    shift->{errors} = [];
}

=head2 report

    The report method is responsible for displaying all stored error
    messages using the defined message delimiter.
    
=cut

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

=head1 AUTHOR

Al Newkirk, C<< <al.newkirk at awnstudio.com> >>

=cut

1; # End of SweetPea::Cli::Error

package SweetPea::Cli::Util;

use warnings;
use strict;

use Cwd qw(getcwd);
use File::ShareDir ':ALL';
use File::Util;
use Template;

=head1 NAME

SweetPea::Cli::Util - Common Functions for SweetPea-Cli

=cut

=head1 METHODS

=head2 new

    Instantiate a new utility object.
    
=cut

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

=head2 template

    Load templates for terminal screen display.
    Takes 2 args
    - 1 template (scalar)
    - 2 stash (hashref)
    Returns 1 scalar
    
=cut

sub template {
    my $self      = shift;
    my $file      = shift;
    my $stash     = shift;
    my $t         = Template->new(
        EVAL_PERL => 1,
        ABSOLUTE  => 1,
        ANYCASE   => 1
    );
    my $content;
    
    $file = "templates/" . $file;
    $file = -e "files/$file" ?
        "files/$file" : dist_file('SweetPea-Cli', $file);
    $t->process($file, {
        's' => $stash
    }, \$content);
    
    return $content;
}

sub makefile {
    my $self = shift;
    my @data = @_;
    my $f = File::Util->new;
    $f->write_file(@data) unless -e $data[1];
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

1; # End of SweetPea::Cli::Util

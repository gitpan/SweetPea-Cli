package SweetPea::Cli::Mvc;

use warnings;
use strict;

use SweetPea;
use SweetPea::Cli::Util;
use SweetPea::Cli::Flash;
use SweetPea::Cli::Error;
use SweetPea::Cli::Help;

=head1 NAME

SweetPea::Cli::Mvc - Model, View, Controller builder for use with SweetPea-Cli

=cut

=head1 METHODS

=head2 new

    Instantiate a new MVC object.
    
=cut

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    my $c = $self->{c} = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    
    $self->{commands} = [
        {
            name => 'mvc',
            code => sub {
                $self->mvc(@_)
            },
            args => {
                'model' => {
                    aliases => ['m']
                },
                'view'  => {
                    aliases => ['v']
                },
                'controller'  => {
                    aliases => ['c']
                }
            },
            help => 'generate code for models, views and/or controllers.'
        }
    ];
    
    return $self;
}

sub mvc {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    my $h = SweetPea::Cli::Help->new;
    
    my $doc  = $c->argv->[0];
    my $type = 'Model'
        if $c->options->{model};
       $type = 'View'
        if $c->options->{view};
       $type = 'Controller'
        if $c->options->{controller};
    
    unless ($type && $doc) {
        return $h->display('mvc', $c);
    }
    
    if ($type) {
        if ($doc) {
            $doc =~ s/^[\\\/]+//;
            $doc =~ s/\.pm$//;
            my $package = $doc;
            $package =~ s/([\\\/]|::)+/::/g;
            $doc =~ s/([\\\/]|::)+/\//g;
            $doc .= '.pm';
            
            # make files
            $self->_write(
                0754,
                "sweet/application/$type/$doc",
                "generated/". lc($type) ."/new.tt",
                $package
            );
            
            my @return = (
                "$type created successfully as ...",
                "... file $doc"
            );
            return $f->flash(@return)->report($c);
        }
        else {
            my @return = (
                'No data profile specified. Use `help make;` for instructions.'
            );
            return $e->error(@return)->report($c);
        }
    }
    else {
        my @return = (
            'No MVC specified. Use `help mvc;` for instructions.'
        );
        return $e->error(@return)->report($c);
    }
}

sub _write {
    my $self = shift;
    my ($mask, $to, $from, $package) = @_;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    
    my $stash = {
        shebang => $^X,
        version => $SweetPea::VERSION,
        head => '---',
        fruitful => 'Now go be fruitful and multiply.',
        package => $package
    };
    
    my $content = '';
    $content = $u->template($from, $stash);
    
    $u->makefile(
        'file'    => $to,
        'content' => $content,
        'bitmask' => $mask
    );
}


=head1 AUTHOR

Al Newkirk, C<< <al.newkirk at awnstudio.commands> >>

=head1 ACKNOWLEDGEMENTS

Al Newkirk <al.newkirk@awnstudio.com>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Al Newkirk, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of SweetPea::Cli::Mvc
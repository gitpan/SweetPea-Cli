package SweetPea::Cli;

use 5.006;
use warnings;
use strict;
use App::Rad;
use SweetPea::Application 0.022;
use SweetPea::Cli::Util;
use SweetPea::Cli::Make;
use SweetPea::Cli::Data;
use SweetPea::Cli::Help;
use SweetPea::Cli::Tool;
use SweetPea::Cli::Mvc;

BEGIN {
    use Exporter();
    use vars qw( @ISA @EXPORT @EXPORT_OK );
    @ISA    = qw( Exporter );
    @EXPORT = qw(shell);
}

=head1 NAME

SweetPea::Cli - Rapid Application Development for SweetPea Packages

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

    ... from the command-line
    sweetpea
    or
    perl -MSweetPea::Cli -e shell


=head1 DOCUMENTATION

=over 4

=item * Detailed Documentation

L<SweetPea::Cli::Documentation>

=item * Live Documentation

L<http://app.alnewkirk.com/pod/projects/sweetpea-cli/>

=back

=cut

sub shell {
    App::Rad->shell({
        title      => [<DATA>],
        prompt     => 'sweetpea:',
        autocomp   => 1,
        abbrev     => 1,
        ignorecase => 0,
        history    => 1, # or 'path/to/histfile.txt'
    });
}

sub main::setup {
    my $c = shift;
       $c->stash->{commands} = $c->{_commands};
       
    my $m = [
        {
            name => 'help',
            code => sub {
                my $c = shift;
                my $u = SweetPea::Cli::Util->new;
                my $h = SweetPea::Cli::Help->new;
                
                # display help document for a specific function
                if (defined $c->argv->[0]) {
                    if (defined $c->{_commands}->{$c->argv->[0]}) {
                        return $h->display($c->argv->[0], $c);
                    }
                }
                
                return $u->template('menus/commands.tt', $c);
            },
            help => 'display available commands.'
        },
        {
            name => 'menu',
            code => sub {
                my $c = shift;
                my $u = SweetPea::Cli::Util->new;            
                
                return $u->template('menus/master.tt', $c);
            },
            help => 'display main menu.'            
        },
    ];
    
    $c->register( $_->{name}, $_->{code}, $_->{help} )
        foreach @{$m};
        
    # register make commands
    foreach my $cmd ( @{SweetPea::Cli::Make->new($c)->{commands}} ) {
        my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
        $c->{_commands}->{$n}->{args} = $cmd->{args};
    }
    
    # register data commands
    foreach my $cmd ( @{SweetPea::Cli::Data->new($c)->{commands}} ) {
        my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
        $c->{_commands}->{$n}->{args} = $cmd->{args};
    }
    
    # register toolbox commands
    #foreach my $cmd ( @{SweetPea::Cli::Tool->new($c)->{commands}} ) {
    #    my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
    #    $c->{_commands}->{$n}->{args} = $cmd->{args};
    #}
    
    # register MVC commands
    foreach my $cmd ( @{SweetPea::Cli::Mvc->new($c)->{commands}} ) {
        my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
        $c->{_commands}->{$n}->{args} = $cmd->{args};
    }
        
    $c->{'_functions'}->{'invalid'} = sub {
        my $c = shift;
        my $u = SweetPea::Cli::Util->new;            
        
        return $u->template('misc/error_string.tt', $c);
    };
}

sub main::pre_process {
    my $c = shift;
}


#sub App::Rad::error {
#    my $c = shift;
#    my $e = shift;
#    
#    if ( $c->{state} eq "shell" ) {
#        my $u = SweetPea::Cli::Util->new;
#        $e =~ s/(^[\r\n]+|[\r\n]+$)//g;
#        $c->stash->{errors} = ["$e\n","\n"];
#        return $u->template('misc/error_string.tt', $c);
#    }
#    else {
#        Carp::croak "$e----\n";
#    }
#}

=head1 AUTHOR

Al Newkirk, C<< <al.newkirk at awnstudio.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-SweetPea-Cli at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SweetPea-Cli>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SweetPea::Cli

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=SweetPea-Cli>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/SweetPea-Cli>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/SweetPea-Cli>

=item * Search CPAN

L<http://search.cpan.org/dist/SweetPea-Cli/>

=back


=head1 ACKNOWLEDGEMENTS

Al Newkirk <al.newkirk@awnstudio.com>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Al Newkirk, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of SweetPea::Cli

__DATA__

Welcome to the SweetPea interactive development interface.
*** Please type menu; to get started! ***


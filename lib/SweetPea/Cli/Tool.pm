package SweetPea::Cli::Tool;

use warnings;
use strict;

use SweetPea;
use SweetPea::Cli::Util;
use SweetPea::Cli::Flash;
use SweetPea::Cli::Error;
use SweetPea::Cli::Help;

=head1 NAME

SweetPea::Cli::Tool - Misc tools for SweetPea-Cli

=cut

=head1 METHODS

=head2 new

    Instantiate a new Make object.
    
=cut

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    my $c = $self->{c} = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    
    $self->{commands} = [
        #{
        #    name => 'sqlc',
        #    code => sub {
        #        $self->sql_client(@_)
        #    },
        #    args => {
        #        'executable' => {
        #            aliases => ['e']
        #        }
        #    },
        #    help => 'launch the sql client for your database.'
        #}
        {
            
        }
    ];
    
    return $self;
}

sub sql_client {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    my $h = SweetPea::Cli::Help->new;
    my $s = SweetPea::Application::Config->new(
        SweetPea::Application->new,
        Cwd::getcwd
    );
    
    my $executables = {
        'DB2'       => '?',
        'Oracle'    => '?',
        'PostgrSQL' => 'psql -d db -u user -p pass',
        'MySQL'     => 'mysql -d db -u user -p pass',
        'SQLite'    => 'sqlite3 db',
        'SQLServer' => '?',
        'Sybase'    => ''
    };
    
    unless ( -d "./sweet/configuration" )
    {
        return $e->error('No application configured.',
        'Try `help make;` for instructions on creating an application.'
        )->report($c);
    }
    
    my $application = $s->get('/application');
    my $datastore   = $s->get('/datastores');
    my $store       = $application->{datastore};
    my $data        = $datastore->{datastores}->{$store};
    my $conn = $data->{dsn};
    my $user = $data->{username};
    my $pass = $data->{password};
    my ($scheme, $driver, @trash) = DBI->parse_dsn($conn);
    my $client = $executables->{$driver};
    
    unless ( -d "./sweet/configuration/datastores/$store/table" )
    {
        return $e->error('No database configured.',
        'Try `help data;` for instructions on configuring your datastores.'
        )->report($c);
    }
    
    if ($client && $client ne '?') {
        $client =~ s/ db/ $scheme/ if $scheme;
        $client =~ s/ user/ $user/ if $user;
        $client =~ s/ pass/ $pass/ if $pass;
        
        system($client);
        
        my @return = (
            'SQL client was invoked with `' . $client . '`',
            'Note! SQL client host and port parameters not supported.'
        );
        return $f->flash(@return)->report($c);
    }
    else {
        my @return = (
            'SQL client not recognized or is not yet supported.',
            'Note! Sql client host and port parameters not supported.'
        );
        return $e->error(@return)->report($c);
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

1; # End of SweetPea::Cli::Tool
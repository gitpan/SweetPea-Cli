package SweetPea::Cli::Data;

use warnings;
use strict;

use Cwd;
use DBI;
use Exception::Handler;
use Hash::Merge::Simple qw(merge);
use SQL::Translator;
use SQL::Translator::Schema::Field;
use SweetPea::Application;
use SweetPea::Application::Config;
use SweetPea::Cli::Util;
use SweetPea::Cli::Flash;
use SweetPea::Cli::Error;
use SweetPea::Cli::Help;

=head1 NAME

SweetPea::Cli::Data - Data profile builder for use with SweetPea-Cli

=cut

=head1 METHODS

=head2 new

    Instantiate a new Data object.
    
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
            name => 'data',
            code => sub {
                $self->data(@_)
            },
            args => {
                'create' => {
                    aliases => ['c']
                },
                'update'  => {
                    aliases => ['u']
                }
            },
            help => 'create and update database data profiles.'
        }
    ];
    
    return $self;
}

sub data {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    my $h = SweetPea::Cli::Help->new;
    
    # check sweetpea-application availability
    eval 'use SweetPea::Application;';
    if ($@) {
        my @error = (
            'Error',
            'SweetPea::Application does not seem to be available.',
            '',
            'Please install SweetPea::Application. Try cpan SweetPea::Application.'
        );
        return $e->error(@error)->report($c);
    }
    else {
        if
        (
            -x -r -d './sweet/configuration/datastores/development' &&
            -x -r -d './sweet/configuration/datastores/production' 
        )
        {
            # create or update database data profiles
            if ($c->options->{create}) {
                $self->create($c);
            }
            elsif ($c->options->{update}) {
                $self->update($c);
            }
            else {
                return $h->display('data', $c);
            }
        }
        else {
            my @error = (
            'Please create database data files before attempting an update.',
            'Use `help data;` for instructions.'
        );
        return $e->error(@error)->report($c);
        }
    }
}

sub create {
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
    
    # check if profiles exist
    my $datastore = $s->get('/application')->{datastore};
    if
    (
        -f "./sweet/configuration/datastores/$datastore/table/users.yml" ||
        -f "./sweet/configuration/datastores/$datastore/table/permissions.yml"
    )
    {
        return $e->error('Database already created.')->report($c);
    }
    else
    {
        # check for valid dsn, user and pass
        if ($self->_check_dsn($c->argv->[0], $c->argv->[1], $c->argv->[2])) {
            my ($dsn, $user, $pass) =
                ($c->argv->[0], $c->argv->[1], $c->argv->[2]);
            
            my @dsn              = ($dsn, $user, $pass);
            my ($scheme, $driver, @trash) = DBI->parse_dsn($dsn[0]);
            my $translator       = SQL::Translator->new(
             debug               => 0,
             add_drop_table      => 0,
             quote_table_names   => 1,
             quote_field_names   => 1,
             validate            => 1,
             no_comments         => 1,
             producer            => $self->_translate_database_type($driver)
            );
        
            my $schema     =  $translator->schema(
                  name     => $scheme,
              );
            
            my $table      = $schema->add_table( name => 'users' );
            $table->add_field(
                 name      => 'id',
                 data_type => 'integer',
                 size      => 11,
                 table     => $table,
                 
                 is_auto_increment => 1,
                 is_primary_key    => 1
            );
            $table->add_field(
                 name      => 'name',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 0
            );
            $table->add_field(
                 name      => 'email',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 0
            );
            $table->add_field(
                 name      => 'login',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 is_unique => 1,
                 
                 is_nullable       => 0
            );
            $table->add_field(
                 name      => 'password',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 0
            );
            $table->add_field(
                 name      => 'status',
                 data_type => 'integer',
                 size      => 1,
                 table     => $table,
                 
                 is_nullable       => 0
            );
            $table->primary_key('id');
            
            $table         = $schema->add_table( name => 'permissions' );
            $table->add_field(
                 name      => 'id',
                 data_type => 'integer',
                 size      => 11,
                 table     => $table,
                 
                 is_auto_increment => 1,
                 is_primary_key    => 1
            );
            $table->add_field(
                 name      => 'user',
                 data_type => 'integer',
                 size      => 11,
                 table     => $table,
                 
                 is_nullable       => 0
            );
            $table->add_field(
                 name      => 'role',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 1
            );
            $table->add_field(
                 name      => 'permission',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 1
            );
            $table->add_field(
                 name      => 'operation',
                 data_type => 'varchar',
                 size      => 255,
                 table     => $table,
                 
                 is_nullable       => 1
            );
            $table->primary_key('id');
            my  $db = DBI->connect(@dsn) or exit print "\n", $@;
            if ($db) {
                # hack
                my ($scheme, $driver, @trash)
                                 = DBI->parse_dsn($dsn[0]);
                
                for ($translator->translate(
                        to => $self->_translate_database_type($driver))) {
                    $db->do($_) or exit print "\n", $@;
                }
            }
            
            # auto-update
            $self->update($c);
            
            return $f->flash('Database created successfully.')->report($c);
        }
        else {
            my @return = (
                'Invalid datasource. Use `help data;` for instructions.'
            );
            return $e->error(@return)->report($c);
        }
    }
}

sub update {
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
    
    # check for valid dsn, user and pass
    if ($self->_check_dsn($c->argv->[0], $c->argv->[1], $c->argv->[2])) {
        my ($dsn, $user, $pass) =
            ($c->argv->[0], $c->argv->[1], $c->argv->[2]);
        
        my @dsn              = ($dsn, $user, $pass);
        my ($scheme, $driver, @trash)
                             = DBI->parse_dsn($dsn[0]);
        
        my  $db              = DBI->connect(@dsn)
            or exit print "\n", $@;
        
        my $translator       = SQL::Translator->new(
                 parser      => 'DBI',
                 parser_args => {
                 dsn         => $dsn[0],
                 db_user     => $dsn[1],
                 db_password => $dsn[2],
                 },
                 producer    => $self->_translate_database_type($driver)
        );
        $translator->translate or die $translator->error;
    
        my $schema           =  $translator->schema;
        
        my @tables           = $schema->get_tables
            or exit print "\n", $translator->error;
            
        # update datastore config
        my $application = $s->get('/application');
        my $datastore   = $s->get('/datastores');
        
        $datastore->{datastores}->{$application->{datastore}} = {
            dsn      => $dsn[0],
            username => $dsn[1],
            password => $dsn[2]
        };
        
        $s->set('/datastores');
        
        my $store = $application->{datastore};
        
        foreach my $table (@tables) {
            
            my $profile = {};
            my $name = $table->name;
            my $yaml =
            "/datastores/development/table/$name";
            my $path =
            "sweet/configuration/datastores/development/table/$name.yml";
            
            $profile = {
                table     => {
                    'name'    => $name,
                    'columns' => {}
                },
                form      => {
                    'name'          => $name . "_form",
                    'fields'        => {},
                    'validation'    => {
                        optional    => [],
                        required    => [],
                        constraint_methods => {}                        
                    }
                },
                grid      => {
                    'name'    => $name . "_grid",
                    'columns' => {}
                }
            };
            
            # update table configuration data
            my @fields = $table->get_fields;
            foreach my $field (@fields) {
                my $name = $field->name;
                if ($name) {
                    my $field_label     = ucfirst $name;
                        $field_label    =
                        join(" ", map {ucfirst $_} split /_/, $field_label);
                        
                    # build validation hash
                    
                    if ($field->is_nullable) {
                        push @{$profile->{form}->{validation}->{optional}},
                            $name;
                    }
                    else {
                        push @{$profile->{form}->{validation}->{required}},
                            $name;
                    }
                    
                    $profile->{table}->{columns}->{$name} = {
                        'type'      => $field->data_type,
                        'size'      => $field->size,
                        'value'     => ( lc($field->default_value) eq 'null' ?
                                        '' : $field->default_value ),
                        'required'  => $field->is_nullable,
                        'key'       => $field->is_primary_key,
                        'auto'      => $field->is_auto_increment,
                        'unique'    => $field->is_unique
                    };
                    $profile->{form}->{fields}->{$name} = {
                        name        => $name,
                        length      => $field->size,
                        value       => $field->default_value,
                        maps_to     => $name,
                        label       => $field_label,
                        type        => 'text',
                        input_via   => 'post',
                        attributes  => {
                            class   => 'form_field'
                        }
                    };
                    $profile->{grid}->{columns}->{$name} = {
                        attributes  => {
                            class   => 'grid_column'
                        },
                        maps_to     => $name,
                        value       => $field->default_value,
                        name        => $name,
                        label       => $field_label
                    };
                }
            }
            
            # get/set base table configuration data
            if (-e $path) {
                my $existing = $s->get($yaml);
                $profile = merge $profile, $existing;
            }
            
            # save changes
            $s->set($yaml, $profile);
        }
        
        return $f->flash('Database data files updated.')->report($c);
    }
    else {
        my @return = (
            'Invalid datasource. Use `help data;` for instructions.'
        );
        return $e->error(@return)->report($c);
    }
}

sub _check_dsn {
    my $self = shift;
    my ($dsn, $user, $pass) = @_;
    
    return 0 if !$dsn;
    return ($dsn =~ /^dbi\:/ && $user) ? 1 : 0;
}

sub _translate_database_type {
    my $self = shift;
    my $dsn  = shift;
       $dsn  =~ s/dbi\:([a-zA-Z0-9\-\_]+)\:/dbi\:$1\:/ if $dsn =~ /\:/;
    my $dbt  = {
        'db2'     => 'DB2',
        'mysql'   => 'MySQL',
        'oracle'  => 'Oracle',
        'pg'      => 'PostgrSQL',
        'odbc'    => 'SQLServer',
        'sqlite'  => 'SQLite',
        'sybase'  => 'Sybase'
    };
    return $dbt->{lc($dsn)};
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

1; # End of SweetPea::Cli::Data
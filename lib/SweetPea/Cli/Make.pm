package SweetPea::Cli::Make;

use warnings;
use strict;

use SweetPea::Application;
use SweetPea::Cli::Util;
use SweetPea::Cli::Flash;
use SweetPea::Cli::Error;
use SweetPea::Cli::Help;

=head1 NAME

SweetPea::Cli::Make - Application builder for use with SweetPea-Cli

=cut

my @return = (
    'SweetPea application files were created successfully.',
    '',
    'Attention, you may need to fix permissions for generated files.',
    'Remember to secure your application, try the following commands:',
    '',
    'sudo chown -R www-data *',
    'sudo chmod -R 0700 *',
    'sudo chmod -R 0755 static/ .htaccess .routes .pl',
    '',
    'Next! Create database data profiles. See help data;'
);

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
        {
            name => 'make',
            code => sub {
                $self->make(@_)
            },
            args => {
                'script' => {
                    aliases => ['s']
                },
                'basic'  => {
                    aliases => ['b']
                },
                'stack'  => {
                    aliases => ['f']
                },
                'profile' => {
                    aliases => ['p']
                }
            },
            help => 'generate a script, basic or full-stack app.'
        }
    ];
    
    return $self;
}

sub make {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    my $h = SweetPea::Cli::Help->new;
    
    my $type;
    
    if ($c->options->{basic}) {
        # build basic app
        return $self->basic($c);
    }
    elsif ($c->options->{script}) {
        # build script-only app
        return $self->script($c);
    }
    elsif ($c->options->{stack}) {
        # build full-stack app
        return $self->stack($c);
    }
    elsif ($c->options->{profile}) {
        # build data profile
        return $self->profile($c);
    }
    else {
        return $h->display('make', $c);
    }
}



sub script {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    
    # make files
    $self->_write(0755, '.htaccess', 'generated/htaccess.tt');
    $self->_write(0755, '.pl', 'generated/script/pl.tt');
    $self->_write(0754, '.server', 'generated/server.tt');
    $self->_write(0755, 'routes.pl', 'generated/routes.tt');
    $self->_write(0754, 'extras/Makefile.PL', 'generated/makefile.tt');
    $self->_write(0754, 'extras/TODO', 'placeholder');
    $self->_write(0754, 'extras/Changes', 'placeholder');
    
    return $f->flash(@return)->report($c);
}

sub basic {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    
    # make files
    $self->_write(0755, '.htaccess', 'generated/htaccess.tt');
    $self->_write(0755, '.pl', 'generated/basic/pl.tt');
    $self->_write(0754, '.server', 'generated/server.tt');
    $self->_write(0755, 'routes.pl', 'generated/routes.tt');
    $self->_write(0754, 'sweet/application/Controller/Root.pm', 'generated/controller/root.tt');
    $self->_write(0754, 'sweet/application/Controller/Sweet.pm', 'generated/controller/basic/sweet.tt');
    $self->_write(0754, 'sweet/application/Model/Schema.pm', 'generated/model/schema.tt');
    $self->_write(0754, 'sweet/application/View/Main.pm', 'generated/view/main.tt');
    $self->_write(0754, 'sweet/App.pm', 'generated/app.tt');
    $self->_write(0777, 'sweet/sessions/empty', 'placeholder');
    $self->_write(0754, 'sweet/templates/empty', 'placeholder');
    $self->_write(0755, 'static/empty', 'placeholder');
    $self->_write(0754, 'extras/Makefile.PL', 'generated/makefile.tt');
    $self->_write(0754, 'extras/TODO', 'placeholder');
    $self->_write(0754, 'extras/Changes', 'placeholder');
    
    return $f->flash(@return)->report($c);
}

sub stack {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    
    # make files
    $self->_write(0755, '.htaccess', 'generated/htaccess.tt');
    $self->_write(0755, '.pl', 'generated/stack/pl.tt');
    $self->_write(0755, 'routes.pl', 'generated/routes.tt');
    $self->_write(0754, '.server', 'generated/server.tt');
    $self->_write(0754, 'sweet/application/Controller/Root.pm', 'generated/controller/root.tt');
    $self->_write(0754, 'sweet/application/Controller/Sweet.pm', 'generated/controller/stack/sweet.tt');
    $self->_write(0754, 'sweet/application/Model/Schema.pm', 'generated/model/schema.tt');
    $self->_write(0754, 'sweet/application/View/Main.pm', 'generated/view/main.tt');
    $self->_write(0754, 'sweet/App.pm', 'generated/app.tt');
    $self->_write(0777, 'sweet/sessions/empty', 'placeholder');
    $self->_write(0754, 'sweet/templates/empty', 'placeholder');
    $self->_write(0755, 'static/empty', 'placeholder');
    $self->_write(0754, 'extras/Makefile.PL', 'generated/makefile.tt');
    $self->_write(0754, 'extras/TODO', 'placeholder');
    $self->_write(0754, 'extras/Changes', 'placeholder');
    
    $self->_write(0754, 'sweet/configuration/datastores/development/empty', 'placeholder');
    $self->_write(0754, 'sweet/configuration/datastores/production/empty', 'placeholder');
    $self->_write(0754, 'sweet/configuration/application.yml', 'generated/config/application.tt');
    $self->_write(0754, 'sweet/configuration/datastores.yml', 'generated/config/datastores.tt');
    $self->_write(0754, 'sweet/configuration/permissions.yml', 'generated/config/permissions.tt');
    $self->_write(0754, 'sweet/locales/en.yml', 'generated/locale/english.tt');
    $self->_write(0754, 'sweet/templates/elements/form.tt', 'generated/element/form.tt');
    $self->_write(0754, 'sweet/templates/elements/grid.tt', 'generated/element/grid.tt');
    $self->_write(0754, 'sweet/templates/layouts/default.tt', 'data');
    $self->_write(0754, 'sweet/templates/index.tt', 'Now go be fruitful and multiply.');
    $self->_write(0754, 'extras/t/00-load.t', 'generated/stack/test-00.tt');
    
    return $f->flash(@return)->report($c);
}

sub profile {
    my $self = shift;
    my $c = shift;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    
    my $profile = $c->argv->[0];
    
    if ($profile) {
        $profile =~ s/^[\\\/]+//;
        $profile =~ s/\.yml$//;
        $profile =~ s/\\/\//g;
        $profile .= '.yml';
        
        # make files
        $self->_write(0754, "sweet/configuration/$profile", 'generated/config/profile/new.tt');
        
        my @return = (
            "Data profile $profile created successfully."
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

sub _write {
    my $self = shift;
    my ($mask, $to, $from, $type) = @_;
    my $f = SweetPea::Cli::Flash->new;
    my $e = SweetPea::Cli::Error->new;
    my $u = SweetPea::Cli::Util->new;
    
    my $stash = {
        shebang => $^X,
        sver    => $SweetPea::VERSION,
        saver   => $SweetPea::Application::VERSION,
        head    => '---',
        fruitful => 'Now go be fruitful and multiply.',
    };
    
    my $content = '';
    
    if ($from eq "placeholder") {
        $content = "placeholder";
    }
    elsif ($from eq "data") {
        $content .= $_ while (<DATA>);
    }
    else {
        if ($from !~ /\.tt$/) {
            $content = $from;
        }
        else {
            $content = $u->template($from, $stash);
        }
    }
    
    $u->makefile(
        'file'    => $to,
        'content' => $content,
        'bitmask' => $mask
    );
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

1; # End of SweetPea::Cli::Make

__DATA__
<!doctype html>
<head><title>Welcome to the SweetPea Web Framework</title></head>
<body>
    <h2>Thanks for trying the SweetPea-Application Web Framework!</h2>
    SweetPea::Application is a full stack web application framework
    utilizing conventional wisdom and granular configuration over a highly
    sophisticated Push MVC architecture.<br/>
    [% content %]
</body>
</html>
package SweetPea::Cli::Util;

use warnings;
use strict;

use Cwd qw(getcwd);
use File::ShareDir ':ALL';
use File::Util;
use Template;

# SweetPea::Cli::Util - Common Functions for SweetPea-Cli

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

# template
# 
# Load templates for terminal screen display.
# Takes 2 args
# - 1 template (scalar)
# - 2 stash (hashref)
# Returns 1 scalar
    
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

1; # End of SweetPea::Cli::Util

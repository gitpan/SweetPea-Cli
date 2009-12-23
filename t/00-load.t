#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'SweetPea::Cli' );
}

diag( "Testing SweetPea::Cli $SweetPea::Cli::VERSION, Perl $], $^X" );

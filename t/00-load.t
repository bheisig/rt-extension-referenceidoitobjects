#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'RT::Extension::ReferenceIDoitObject' );
}

diag( "Testing RT::Extension::ReferenceIDoitObject $RT::Extension::ReferenceIDoitObject::VERSION, Perl $], $^X" );

package RT::Extension::ReferenceIDoitObject;

use 5.010;
use warnings;
use strict;

our $VERSION = '0.1';


=head1 NAME

RT::Extension::ReferenceIDoitObject - Create a ticket in relation to an i-doit
object


=head1 DESCRIPTION

FIXME


=head1 INSTALLATION

This extension requires a running i-doit >= 0.9.9-8 installation.

To install this extension, run the following commands:

    perl Makefile.PL
    make
    make test
    make install


=head1 CONFIGURATION


=head2 RT SITE CONFIGURATION

To enabled this condition edit the RT site configuration based in
C<RT_HOME/etc/RT_SiteConfig>:

    Set(@Plugins,qw(RT::Extension::ReferenceIDoitObject));

FIXME more variables...


=head1 AUTHOR

Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc RT::Extension::ReferenceIDoitObject


=head1 BUGS

Please report any bugs or feature requests to the L<author|/"AUTHOR">.


=head1 ACKNOWLEDGEMENTS

Special thanks to the synetics GmbH, C<< <http://i-doit.org/> >> for initiating
and supporting this project!


=head1 COPYRIGHT AND LICENSE

Copyright 2011 Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.


=cut


1;


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

This extension requires RT >= 4.0.0 and a running i-doit >= 0.9.9-8
installation.

To install this extension, run the following commands:

    perl Makefile.PL
    make
    make test
    make install
    make initdb


=head1 CONFIGURATION


=head2 RT SITE CONFIGURATION

To enabled this condition edit the RT site configuration based in
C<RT_HOME/etc/RT_SiteConfig>:

    Set(@Plugins,qw(RT::Extension::ReferenceIDoitObject));

i-doit has a built-in API based on JSON-RPC. To call this API set its URL:

    Set($IDoitAPI, 'http://localhost/i-doit/?api=jsonrpc');

    Set($IDoitUser, 'admin');

    Set($IDoitPassword, '21232f297a57a5a743894a0e4a801fc3'); # 'admin'

The password is MD5 encoded. It's highly recommended to establish an encrypted
connection between RT and i-doit, e. g. TLS over HTTP (HTTPS). You also need a
mandator who owns the objects, but this is handled while creating a ticket.


=head1 AUTHORS

Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>

Leonard Fischer, E<lt>lfischer@synetics.deE<gt>


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc RT::Extension::ReferenceIDoitObject


=head1 BUGS

Please report any bugs or feature requests to the L<author|/"AUTHORS">.


=head1 COPYRIGHT AND LICENSE

Copyright 2011 synetics GmbH, E<lt>http://i-doit.org/E<gt>

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.


=cut


1;


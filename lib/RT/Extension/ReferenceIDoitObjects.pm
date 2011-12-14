package RT::Extension::ReferenceIDoitObjects;

use 5.010;
use warnings;
use strict;

our $VERSION = '0.1';


=head1 NAME

RT::Extension::ReferenceIDoitObjects - Create a ticket in relation to one or
more i-doit objects


=head1 DESCRIPTION

This extension gives you the opportunity to combine an issue tracker like RT
with an IT documentation tool / CMDB like i-doit. It uses i-doit's API to relate
a ticket with one or more CIs / objects managed by i-doit.


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
C<RT_HOME/etc/RT_SiteConfig.pm>:

    Set(@Plugins,qw(RT::Extension::ReferenceIDoitObjects));

i-doit has a built-in API based on JSON-RPC. To call this API set its URL:

    Set($IDoitURL, 'http://localhost/i-doit/');

    Set($IDoitAPI, $IDoitURL . '?api=jsonrpc');

    Set($IDoitUser, 'admin');

    Set($IDoitPassword, '21232f297a57a5a743894a0e4a801fc3'); # 'admin'

    Set($IDoitDefaultMandator, -1);

    Set($IDoitDefaultView, 'tree'); # 'object', 'tree' or 'item'

    Set($IDoitShowCustomFields, 1); # 1 ('yes') or 0 ('no')

The password is MD5 encoded. It's highly recommended to establish an encrypted
connection between RT and i-doit, e. g. TLS over HTTP (HTTPS). You also need a
mandator who owns the objects, but this is handled while creating a ticket.

After all your new configuration will take effect after restarting your RT
environment:

    rm -rf $RT_HOME/var/mason_data/obj/* && service apache2 restart

This is an example for deleting the mason cache and restarting the Apache HTTP
web server on a Debian GNU/Linux based operating system.


=head1 AUTHOR

Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>

Leonard Fischer, E<lt>lfischer@synetics.deE<gt>


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the C<perldoc> command.

    perldoc RT::Extension::ReferenceIDoitObjects

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/RT-Extension-ReferenceIDoitObjects/>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RT-Extension-ReferenceIDoitObjects>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RT-Extension-ReferenceIDoitObjects>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RT-Extension-ReferenceIDoitObjects>

=back


=head1 BUGS

Please report any bugs or feature requests to the L<author|/"AUTHOR">.


=head1 COPYRIGHT AND LICENSE

Copyright 2011 synetics GmbH, E<lt>http://i-doit.org/E<gt>

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.


=head1 SEE ALSO

    RT


=cut


1;


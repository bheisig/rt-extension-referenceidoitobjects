# RT::Extension::ReferenceIDoitObjects
#
# Copyright 2011-12 synetics GmbH, http://i-doit.org/
#
# This program is free software; you can redistribute it and/or modify it under
# the same terms as Perl itself.
#
# Request Tracker (RT) is Copyright Best Practical Solutions, LLC.

package RT::Extension::ReferenceIDoitObjects;

use 5.010;
use warnings;
use strict;

our $VERSION = '0.91';

=head1 NAME

RT::Extension::ReferenceIDoitObjects - Create a ticket in relation to one or
more i-doit objects


=head1 DESCRIPTION

This extension gives you the opportunity to combine an issue tracker like RT
with an IT documentation tool / CMDB like i-doit. It uses i-doit's API to relate
a ticket with one or more CIs / objects managed by i-doit. On i-doit's side you
are able to view all tickets related to an object. This extension also supports
i-doit's multi-mandator functionality.

i-doit ("I document IT") is a web-based tool to document complex IT
infrastructures. It provides several modules like a ITIL compliant Configuration
Management Database (CMDB). More information about i-doit is available under
L<http://www.i-doit.org/>. Its core is Free and Open Source Software. Visit
L<http://www.i-doit.com/> for commercial support and additional services. Please
note, that B<i-doit's API (which is essential for this extension) is currently
only implemented in the commercial branch>.


=head1 INSTALLATION

This extension requires RT 4.x or higher and a running installation of i-doit
0.9.9-9 or higher.

To install this extension, run the following commands:

    perl Makefile.PL
    make
    make test
    make install
    make initdb

Executing the last command creates 2 new custom fields, so please do it only
once. These fields contain the i-doit mandator and the referenced objects.

Another way to install the latest release is via CPAN:

    cpan RT::Extension::ReferenceIDoitObjects
    $RT_HOME/sbin/rt-setup-database --action insert --datafile /opt/rt4/local/plugins/RT-Extension-ReferenceIDoitObjects/etc/initialdata

The second command is equivalent to C<make initdb>, but is unfortunately not executed automatically. C<$RT_HOME> is the path to your RT installation, for example C</opt/rt4>.


=head1 CONFIGURATION

To enable this extension edit the RT site configuration based in
C<$RT_HOME/etc/RT_SiteConfig.pm>:

    Set(@Plugins,qw(RT::Extension::ReferenceIDoitObjects));

i-doit has a built-in API based on JSON-RPC. To call this API set its URL:

    Set($IDoitURL, 'http://example.org/i-doit/');

    Set($IDoitAPI, $IDoitURL . '?api=jsonrpc');

    Set($IDoitUser, 'admin');

    Set($IDoitPassword, '21232f297a57a5a743894a0e4a801fc3'); # 'admin'

    Set($IDoitDefaultMandator, 1);

    Set($IDoitDefaultView, 'object'); # 'object', 'tree' or 'item'

    Set($IDoitShowCustomFields, 1); # 1 ('yes') or 0 ('no')


=over 4

=item C<$IDoitURL>

It's I<highly recommended> to establish an encrypted connection between RT and
i-doit over a network, e. g. TLS over HTTP (HTTPS).


=item C<$IDoitAPI>

Please be aware of browsers' "B<Same Origin Policy>"! This extension uses AJAX
requests access i-doit's API. If RT and i-doit are not available under the same
domain name (or IP address), AJAX calls will fail.

To avoid this "problem" (actually this policy is very useful) you can setup an
AJAX proxy. This extension already provides such a proxy located under C<etc/>.
It's written in PHP, so you have to install PHP 5.2 or higher and the PHP
extension C<curl> on the same machine where RT is installed. Make this little
script available through your web server and edit the script by setting
C<$l_url> to the URL of i-doit's API, e. g.
C<http://example.org/i-doit/index.php?api=jsonrpc>. In RT's site configuration
C<$IDoitAPI> has to be set to this script, e. g.
C<http://rt.example.org/path/to/i-doit_api_proxy.php>.


=item C<$IDoitUser>

You need a valid i-doit user with reading permissions.


=item C<$IDoitPassword>

The user's password is encoded as a MD5 hash.


=item C<$IDoitDefaultMandator>

You need the identifier of a mandator who owns the objects, but this may also be
set while creating a ticket. This identifier has be to added to the list of the
corresponding custom field. For a list of (activated) mandators and their
identifiers see i-doit's admin center.


=item C<$IDoitDefaultView>

When creating or editing a ticket, this extension adds a so-called I<object
browser> to the web interface. The browser gives you three views on objects:

=over 4

=item C<object>

Select any object provided by the API and filter them by type.

=item C<tree>

Select users' work stations and their related sub objects. Each user will be
taken by the email address provided by RT's field C<Requestors> if these users
are documented in i-doit.

i-doit gives you the possiblity to create relations between users, their work
stations and all equipment related to these workstations.

Tip: You may synchronize user information between RT and i-doit via LDAP.

=item C<item>

View and remove all selected items.

=back


=item C<$IDoitShowCustomFields>

Sometimes it's better to "clean up" the web user interface. Whenever you only
have 1 mandator within i-doit and don't want to edit the object identifiers
manually it's recommended to hide the used custom fields.


=back


After all your new configuration will take effect after restarting your RT
environment:

    rm -rf $RT_HOME/var/mason_data/obj/* && service apache2 restart

This is an example for deleting the mason cache and restarting the Apache HTTP
web server on a Debian GNU/Linux based operating system.


=head1 USAGE

Whenever you create a new ticket or edit an existing one you are able to
reference this ticket with one or more objects in i-doit. An additional box
with the so-called "object browser" will shown up. Just select the objects you
need or unselect the objects you don't need.


=head1 AUTHORS

Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>

Leonard Fischer, E<lt>lfischer@synetics.deE<gt>


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the C<perldoc> command.

    perldoc RT::Extension::ReferenceIDoitObjects

You can also look for information at:


=over 4

=item B<Search CPAN>

L<http://search.cpan.org/dist/RT-Extension-ReferenceIDoitObjects/>

=item B<RT: CPAN's request tracker>

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RT-Extension-ReferenceIDoitObjects>

=item B<AnnoCPAN: Annotated CPAN documentation>

L<http://annocpan.org/dist/RT-Extension-ReferenceIDoitObjects>

=item B<CPAN Ratings>

L<http://cpanratings.perl.org/d/RT-Extension-ReferenceIDoitObjects>

=item B<Repository>

L<https://github.com/bheisig/rt-extension-referenceidoitobjects>

=back


=head1 BUGS

Please report any bugs or feature requests to the L<authors|/"AUTHORS">.


=head1 COPYRIGHT AND LICENSE

Copyright 2011-12 synetics GmbH, E<lt>http://i-doit.org/E<gt>

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.


=head1 SEE ALSO

    RT


=cut

1;

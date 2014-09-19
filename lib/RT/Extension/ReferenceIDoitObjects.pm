# RT::Extension::ReferenceIDoitObjects
#
# Copyright (C) 2011-14 synetics GmbH, <http://i-doit.org/>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Request Tracker (RT) is Copyright Best Practical Solutions, LLC.

package RT::Extension::ReferenceIDoitObjects;

use 5.010;
use warnings;
use strict;

our $VERSION = '0.94';

=head1 NAME

RT::Extension::ReferenceIDoitObjects - Create a ticket in relation to one or more i-doit objects


=head1 DESCRIPTION

This extension gives you the opportunity to combine an issue tracker like RT with an IT documentation tool / CMDB like i-doit. It uses i-doit's API to relate a ticket with one or more CIs / objects managed by i-doit. On i-doit's side you are able to view all tickets related to an object. This extension also supports i-doit's multi-mandator functionality.

i-doit ("I document IT") is a web-based tool to document complex IT infrastructures. It provides several modules like a ITIL compliant Configuration Management Database (CMDB). More information about i-doit is available under L<http://www.i-doit.org/>. Its core is Free and Open Source Software. Visit L<http://www.i-doit.com/> for commercial support and additional services.


=head1 INSTALLATION

This extension requires RT 4.2.x or higher and a running installation of i-doit 1.3 or higher.

B<Important notice:> This version is no longer compatible to Request Tracker version 4.0.x and i-doit version 1.2.x or older! Please use version 0.92 instead if you need compatibility to those older versions.

To install this extension, run the following commands:

    perl Makefile.PL
    make
    make test
    make install
    make initdb

Executing the last command creates 2 new custom fields, so please do it only once. These fields contain the i-doit mandator and the referenced objects.

Another way to install the latest release is via CPAN:

    cpan RT::Extension::ReferenceIDoitObjects
    $RT_HOME/sbin/rt-setup-database --action insert --datafile /opt/rt4/local/plugins/RT-Extension-ReferenceIDoitObjects/etc/initialdata

The second command is equivalent to C<make initdb>, but is unfortunately not executed automatically. C<$RT_HOME> is the path to your RT installation, for example C</opt/rt4>.


=head1 CONFIGURATION

To enable this extension edit the RT site configuration based in C<$RT_HOME/etc/RT_SiteConfig.pm>:

    Set(@Plugins,qw(RT::Extension::ReferenceIDoitObjects));

i-doit has a built-in API based on JSON-RPC. To call this API set its URL:

    Set($IDoitURL, 'http://example.org/i-doit/');

    Set($IDoitAPI, $IDoitURL . '?api=jsonrpc');

    Set(%IDoitMandatorKeys, (
        'Mandator 1' => 'api key',
        'Mandator 2' => 'api key'
    ));

    Set($IDoitDefaultMandator, 'Mandator 1');

    Set($IDoitDefaultView, 'objects'); # 'objects', 'workplaces', 'devices', or 'item'

    Set($IDoitInstalledSoftware, 'relations'); # 'objects', or 'relations'

    Set($IDoitShowCustomFields, 1); # 1 ('yes') or 0 ('no')


=over 4

=item C<$IDoitURL>

It's I<highly recommended> to establish an encrypted connection between RT and i-doit over a network, e. g. TLS over HTTP (HTTPS).


=item C<$IDoitAPI>

Please be aware of browsers' "B<Same Origin Policy>"! This extension uses AJAX requests access i-doit's API. If RT and i-doit are not available under the same domain name (or IP address), AJAX calls will fail.

To avoid this "problem" (actually this policy is very useful) you can setup an AJAX proxy. This extension already provides such a proxy located under C<etc/>. It's written in PHP, so you have to install PHP 5.2 or higher and the PHP extension C<curl> on the same machine where RT is installed. Make this little script available through your web server and edit the script by setting C<$l_url> to the URL of i-doit's API, e. g. C<http://example.org/i-doit/index.php?api=jsonrpc>. In RT's site configuration C<$IDoitAPI> has to be set to this script, e. g. C<http://rt.example.org/path/to/i-doit_api_proxy.php>.


=item C<$IDoitMandatorKeys>

This is a list of mandators with their API keys. Just put the name and API key of every mandator in i-doit you like to relate to tickets.

B<Notice:> Within the Web GUI you must configure the custom field "i-doit mandator". Add a new value for each mandator. The important field is C<name> where you should set the mandator name.


=item C<$IDoitDefaultMandator>

Choose a default mandator for every situation where it's needed. Use its name (or whatever you like) to identify the mandator. This name has be to added to the list of the corresponding custom field as well.


=item C<$IDoitDefaultView>

When creating or editing a ticket, this extension adds a so-called I<object browser> to the web interface. The browser gives you several views on objects:

=over 4

=item C<objects>

Select objects provided by the API and filter them by type.

=item C<workplaces>

Select users' workplaces and their related sub objects. Each user will be taken by the email address provided by RT's field "Requestors" if these users are documented in i-doit.

i-doit gives you the possiblity to create relations between users, their workplaces and all equipment related to these workplaces.

Tip: You may synchronize user information between OTRS and i-doit via LDAP.

=item C<devices>

Select assigned devices for current requestor. Those devices are objects in i-doit which have this requestor as an assigend person.

=item C<selected>

View and remove all selected items.

=back


=item C<$IDoitInstalledSoftware>

Defines which type of objects will be shown for the installed software. There are two options: "objects" or "relations".


=over 4

=item C<objects>

Shows software objects which are assigned to the currently selected object.

=item C<relations>

Shows the software relation between the object and the assigned software.

=back


=item C<$IDoitShowCustomFields>

Sometimes it's better to "clean up" the web user interface. Whenever you only have 1 mandator within i-doit and don't want to edit the object identifiers manually it's recommended to hide the used custom fields. Select 1 to show them or 0 to hide them.


=back


After all your new configuration will take effect after restarting your RT environment:

    rm -rf $RT_HOME/var/mason_data/obj/* && service apache2 restart

This is an example for deleting the mason cache and restarting the Apache HTTP web server on a Debian GNU/Linux based operating system.


=head1 I-DOIT CONFIGURATION

You may see and create object-related tickets within i-doit. Please refer to the i-doit manual to enable this feature.

If you create a new ticket in i-doit a new browser tab will be opened with the RT user interface. Sometimes RT shows a warning that there is a CSR attack. If you observe this behavior edit RT's local configuration file C<$RT_HOME/etc/RT_SiteConfig.pm> where C<$RT_HOME> is the path to your RT installation, for example C</opt/rt4>:

    Set($RestrictReferrer, 0); # avoids possible CSR attacks

Don't forget to clear the Mason cache and restart your webserver.

B<Notice:> This setting could breach your security!


=head1 USAGE

Whenever you create a new ticket or edit an existing one you are able to reference this ticket with one or more objects in i-doit. An additional box with the so-called "object browser" will shown up. Just select the objects you need or unselect the objects you don't need.


=head1 AUTHORS

Benjamin Heisig, E<lt>bheisig@synetics.deE<gt>

Leonard Fischer, E<lt>lfischer@synetics.deE<gt>

Van Quyen Hoang, E<lt>qhoang@synetics.deE<gt>


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

Copyright (C) 2011-14 synetics GmbH, E<lt>http://i-doit.org/E<gt>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Request Tracker (RT) is Copyright Best Practical Solutions, LLC.


=head1 SEE ALSO

    RT


=cut

1;

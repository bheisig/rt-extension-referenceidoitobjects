use inc::Module::Install;

RTx 'RT-Extension-ReferenceIDoitObjects';

all_from 'lib/RT/Extension/ReferenceIDoitObjects.pm';
license 'perl';
readme_from;
repository 'git://git.benjaminheisig.net/rt-extension-referenceidoitobjects.git';

requires_rt('4.0.0');
auto_install();

sign;
&WriteAll;

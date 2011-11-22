use inc::Module::Install;

RTx 'RT-Extension-ReferenceIDoitObject';

all_from 'lib/RT/Extension/ReferenceIDoitObject.pm';
license 'perl';
readme_from;
repository 'git://git.benjaminheisig.net/rt-extension-referenceidoitobject.git';

auto_install();

sign;
&WriteAll;


use inc::Module::Install;
name 'WebService-Backlog';
all_from 'lib/WebService/Backlog.pm';

requires 'Class::Accessor::Fast';
requires 'Carp';
requires 'RPC::XML';
requires 'Crypt::SSLeay';

test_requires 'Test::More';
test_requires 'Test::TCP';

WriteAll;

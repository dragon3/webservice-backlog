package WebService::Backlog::Project;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw/id key name url archived/);

1;
__END__

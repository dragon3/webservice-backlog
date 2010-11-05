package WebService::Backlog::Version;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);
my @PARAMS = qw/id project_id name start_date due_date archived/;
__PACKAGE__->mk_accessors(@PARAMS);

sub hash {
    my $self = shift;
    my $hash = {};
    for my $p (@PARAMS) {
        $hash->{$p} = $self->$p if ( defined $self->$p );
    }
    return $hash;
}

1;
__END__

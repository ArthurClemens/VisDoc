use strict;
use warnings;
use diagnostics;

package HashUtilsTests;
use base qw(Test::Unit::TestCase);

use VisDoc::HashUtils;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    # your state for fixture here
    return $self;
}

sub test_mergeHashes {
    my ($this) = @_;

    my $A = {
        'A' => 'abc',
        'B' => 'boat',
    };
    my $B = {
        'D' => 'dummy',
        'E' => 'essen',
    };
    my $merged = VisDoc::HashUtils::mergeHashes( $A, $B );
    {
        my $expected = 'abc';
        my $result   = $merged->{'A'};
        print("result=$result.\n")     if $debug;
        print("expected=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $expected = 'dummy';
        my $result   = $merged->{'D'};
        print("result=$result.\n")     if $debug;
        print("expected=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

1;

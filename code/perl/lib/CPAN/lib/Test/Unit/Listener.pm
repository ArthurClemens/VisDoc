package Test::Unit::Listener;
use Test::Unit::Loader;
use Carp;
use strict;

sub new {
    my $class = shift;
    croak "call to abstract constructor ${class}::new";
}

sub start_suite {
    my $self = shift;
    my $class = ref($self);
    my ($suite) = @_;
    croak "call to abstract method ${class}::start_suite";
}

sub start_test {
    my $self = shift;
    my $class = ref($self);
    my ($test) = @_;
    croak "call to abstract method ${class}::start_test";
}

sub add_error { 
    my $self = shift;
    my $class = ref($self);
    my ($test, $exception) = @_;
    croak "call to abstract method ${class}::add_error";
}

sub add_failure {
    my $self = shift;
    my $class = ref($self);
    my ($test, $exception) = @_;
    croak "call to abstract method ${class}::add_failure";
}
 
sub end_test {
    my $self = shift;
    my $class = ref($self);
    my ($test) = @_;
    croak "call to abstract method ${class}::end_test";
}
    
1;
__END__


=head1 NAME

Test::Unit::Listener - unit testing framework abstract base class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to define the interface of a test
listener. It is an abstract base class implemented by the test
runners.

Due to the nature of the Perl OO implementation, this class is not
really needed, but rather serves as documentation of the interface.

Each of the add_ methods gets two arguments: C<test> and C<exception>.
The test is a Test::Unit::Test and the exception is a
Test::Unit::Exception. Typically you want to display
C<test-E<gt>name()> and keep the rest as details.

=head1 AUTHOR

Copyright (c) 2000-2002, 2005 the PerlUnit Development Team
(see L<Test::Unit> or the F<AUTHORS> file included in this
distribution).

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Exception>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=back

=cut

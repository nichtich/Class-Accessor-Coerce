package MooX::AutoConstructor;
#ABSTRACT: Extends accessors to automatically call constructors if needed

use Scalar::Util qw(blessed);
use Class::Method::Modifiers qw(install_modifier);
use base qw(Exporter);
our @EXPORT = qw(autoconstructor);

sub autoconstructor {
    my (%attributes) = @_;
    my ($package) = caller;
    
    while (my ($attribute, $class) = each %attributes) {
        install_modifier $package, around => $attribute
        => sub {
             my $orig = shift;
             my $self = shift;
             if (@_) {
                 return $orig->($self, @_) if blessed $_[0] and $_[0]->isa($class);
                 return $orig->($self, $class->new( @_ ));
             } else {
                 return $orig->($self);
            }
        };
    }
}

=head1 SYNOPSIS

For instance given this packages (note the last line):

    package Person;
    use Moo;
    use v5.10;

    has given   => (is => 'rw');
    has surname => (is => 'rw');

    sub BUILDARGS {
        shift;
        return { } unless @_;

        # Person->new( $given )
        return { given => $_[0] } if @_ == 1;

        # Person->new( $surname, $given )
        return { given => $_[1], surname => $_[0] } 
            if @_ == 2 and !($_[0] ~~ [qw(given surname)]);

        # Person->new( given => $given, surname => $surname )
        return { @_ };
    }

    package Artifact;
    use Moo;
    use MooX::AutoConstructor;
    use Scalar::Util qw(blessed);

    has creator => (
        is => 'rw',
        coerce => sub { # this only works for a single argument
            (blessed $_[0] and $_[0]->isa('Person')) ? 
                $_[0] : Person->new( $_[0] );
        }
    );

    autoconstructor
        creator => 'Person';

One can use accessors with autoconstructor like this:

    use Artifact;

    my $a = Artifact->new;
    $a->artifact( 'Smith', 'Alice' );

Instead of excplicitly havving to call the constructor:

    $a->artifact( Person->new( 'Smith', 'Alice' ) );

=head1 SEE ALSO

This module is based on L<Class::Method::Modifiers>. Although defined in the
MooX namespace, it does not require L<Moo>. One can probably use it with custom
classes, not build with Moo, L<Moose>, or L<Mouse>, as well.

=cut

1;

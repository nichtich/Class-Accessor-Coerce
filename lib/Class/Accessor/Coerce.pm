package Class::Accessor::Coerce;
#ABSTRACT: Extends class accessors with coercing

use Scalar::Util qw(blessed);
use Class::Method::Modifiers qw(install_modifier);
use base qw(Exporter);
our @EXPORT = qw(coerce);

sub coerce {
    my (%attributes) = @_;
    my ($package) = caller;
    
    while (my ($attribute, $sub) = each %attributes) {
        install_modifier $package, 
        around => $attribute
        => sub {
             my $orig = shift;
             my $self = shift;
             if (@_) {
                 return $self->$orig($sub->(@_));
             } else {
                 return $orig->($self);
            }
        };
    }
}

=head1 SYNOPSIS

    package Order;

    sub amount { # explicit or created with Class::Accessor
        my $self = shift;
        if(@_) {
            $self->{amount} = $_[0];
        }
        return $self->{amount};
    }

    use Class::Accessor::Coerce;

    coerce amount => sub {
        $_[0] + 1 unless $_[0] % 2;
    };

In contrast to coercing like implemented in L<Moo>, this module also supports
multiple arguments:

    coerce amount => sub {
        my $sum = List::Util::sum(0, @_);
        ($sum % 2) ? $sum + 1 : $sum;
    };

    # usage
    $order->amount(1,3,2); # sets amount to 6

=head1 EXAMPLE

This examples shows how to extend Moo accessors to automatically call a
constructor with multiple arguments:

    # package with constructor that supports multiple arguments
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

    # package that uses Class::Accessor::Coerce
    package Artifact;
    use Moo;
    use Class::Accessor::Coerce;
    use Scalar::Util qw(blessed);

    sub coerce_creator {
        (blessed $_[0] and $_[0]->isa('Person')) ? $_[0] : Person->new( @_ );
    }

    has creator => (
        is => 'rw',
        coerce => \&coerce_creator, # needed for coercing on object creation
    );

    coerce creator => \&coerce_creator;

One can use accessors with coerce like this:

    use Artifact;

    my $a = Artifact->new;
    $a->artifact( 'Smith', 'Alice' );

Instead of excplicitly having to call the constructor:

    $a->artifact( Person->new( 'Smith', 'Alice' ) );

=head1 SEE ALSO

This module is based on L<Class::Method::Modifiers>. 

=cut

1;

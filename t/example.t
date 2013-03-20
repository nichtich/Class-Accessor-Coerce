use Test::More;

{
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
}

diag('Person');

my $alice = Person->new( 'Alice' );
is $alice->given, 'Alice';
is $alice->surname, undef;

my $bob = Person->new( given => 'Bob' );
is $bob->given, 'Bob';
is $bob->surname, undef; 

my $carol = Person->new( 'Smith', 'Carol' );
is $carol->given, 'Carol';
is $carol->surname, 'Smith'; 

my $dave = Person->new( given => 'Dave', surname => 'Smith' );
is $dave->given, 'Dave';
is $dave->surname, 'Smith'; 

{
    package Artifact;
    use Moo;
    use Class::Accessor::Coerce;
    use Scalar::Util qw(blessed);

    sub coerce_creator {
        (blessed $_[0] and $_[0]->isa('Person')) ? $_[0] : Person->new( @_ );
    }

    has creator => (
        is => 'rw',
        coerce => \&coerce_creator, # this only works for a single argument
    );

    coerce creator => \&coerce_creator;
}

diag('Artifact');

my $artifact = Artifact->new;
is $artifact->creator, undef;

$artifact = Artifact->new( creator => 'Bob' );
is $artifact->creator->given, 'Bob';
is $artifact->creator->surname, undef; 

$artifact->creator('Smith', 'Alice');
is $artifact->creator->given, 'Alice';
is $artifact->creator->surname, 'Smith';

done_testing;


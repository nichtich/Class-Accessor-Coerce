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

    has creator => (
        is => 'rw',
        coerce => sub {
            return $_[0] if blessed $_[0] and $_[0]->isa('Person');
            return Person->new( ref $_[0] ? @{$_[0]} : $_[0] );
        }
    );

    has foo => (
        is => 'rw'
    );

    expect_arrayref('foo','creator');

    sub expect_arrayref {
        around @_ => sub {
            my ($orig, $self, @rest) = @_;
            $self->$orig( @rest ? \@rest : () );
        }
    }

    # ...
    # ...
    # ...
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


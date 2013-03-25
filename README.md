This Perl module provides functions to extend Moo accessors to support
multiple arguments. In short, it exports the following functions:

    sub expect_arrayref {
        around @_ => sub {
            my ($orig, $self, @rest) = @_;
            $self->$orig( @rest ? \@rest : () );
        }
    }

    sub expect_hashref {
        around @_ => sub {
            my ($orig, $self, @rest) = @_;
            $self->$orig( @rest ? { @rest } : () );
        }
    }

    sub undef_clears {
        foreach my $name (@_) {
            around $name => sub {
                my ($orig, $self, @rest) = @_;
                if (@rest == 1 and $rest[0] == undef) {
                    return delete $self->{$name};
                } else {}
                    $self->$orig( @rest );
                }
            }
        }
    }

As long as the module has not been published at CPAN, one can install it with
cpanminus >= 1.6 as following:

    cpanm git://github.com/nichtich/Class-Accessor-Coerce.git

Or just download the repository (e.g. by cloning) and call

    make install


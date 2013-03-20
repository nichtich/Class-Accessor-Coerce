use Test::More;

{
    package Order;
    use List::Util;

    sub amount { # explicit or created with Class::Accessor
        my $self = shift;
        if(@_) {
            $self->{amount} = $_[0];
        }
        return $self->{amount};
    }

    use Class::Accessor::Coerce;

    coerce amount => sub {
        my $sum = List::Util::sum(0, @_);
        ($sum % 2) ? $sum + 1 : $sum;
    };
}

my $order = bless {}, 'Order';
is $order->amount, undef;

$order->amount(1);
is $order->amount, 2;

$order->amount(1,2,3,1);
is $order->amount, 8;

done_testing;

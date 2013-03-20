# perl => '>= 5.10';

requires 'Scalar::Util';
requires 'Class::Method::Modifiers', '>= 1.05';

on 'test' => sub {
	requires 'Test::More', '>= 0.88';
	requires 'Moo', '>= 1.000000';
    requires 'List::Util';
};

#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 12;
use File::Spec;

BEGIN { 
    use_ok('Class::MOP');    
    require_ok(File::Spec->catdir('examples', 'InstanceCountingClass.pod'));
}

=pod

This is a trivial and contrived example of how to 
make a metaclass which will count all the instances
created. It is not meant to be anything more than 
a simple demonstration of how to make a metaclass.

=cut

{
    package Foo;
    
    use metaclass 'InstanceCountingClass';
    
    sub new  {
        my $class = shift;
        bless $class->meta->construct_instance(@_) => $class;
    }
    
    package Bar;
    
    our @ISA = ('Foo');
}

is(Foo->meta->get_count(), 0, '... our Foo count is 0');
is(Bar->meta->get_count(), 0, '... our Bar count is 0');

my $foo = Foo->new();
isa_ok($foo, 'Foo');

is(Foo->meta->get_count(), 1, '... our Foo count is now 1');
is(Bar->meta->get_count(), 0, '... our Bar count is still 0');

my $bar = Bar->new();
isa_ok($bar, 'Bar');

is(Foo->meta->get_count(), 1, '... our Foo count is still 1');
is(Bar->meta->get_count(), 1, '... our Bar count is now 1');

for (2 .. 10) {
    Foo->new();
}

is(Foo->meta->get_count(), 10, '... our Foo count is now 10');    
is(Bar->meta->get_count(), 1, '... our Bar count is still 1');


#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 27;
use Test::Exception;
use Scalar::Util 'blessed';

{
        package Parent;
        use metaclass;

        sub new    { bless {} => shift }
        sub whoami { "parent"          }
        sub parent { "parent"          }

        package Child;
        use metaclass;
        use base qw/Parent/;

        sub whoami { "child" }
        sub child  { "child" }

        package LeftField;
        use metaclass;

        sub new    { bless {} => shift }
        sub whoami { "leftfield"       }
        sub myhax  { "areleet"         }
}

# basic tests
my $foo = Parent->new;
is(blessed($foo), 'Parent', 'Parent->new gives a Parent');
is($foo->whoami, "parent", 'Parent->whoami gives parent');
is($foo->parent, "parent", 'Parent->parent gives parent');
dies_ok { $foo->child } "Parent->child method doesn't exist";

$foo->meta->rebless_instance($foo, "Child");
is(blessed($foo), 'Child', 'rebless_instance really reblessed the instance');
is($foo->whoami, "child", 'reblessed->whoami gives child');
is($foo->parent, "parent", 'reblessed->parent gives parent');
is($foo->child, "child", 'reblessed->child gives child');

throws_ok { $foo->meta->rebless_instance($foo, "LeftField") } qr/You may rebless only into a subclass. \(LeftField\) is not a subclass of \(Child\)\./;
throws_ok { $foo->meta->rebless_instance($foo, "NonExistent") } qr/You may rebless only into a subclass. \(NonExistent\) is not a subclass of \(Child\)\./;

# make sure our ->meta is still sane
my $bar = Parent->new;
is(blessed($bar), 'Parent', "sanity check");
is(blessed($bar->meta), 'Class::MOP::Class', "meta gives a Class::MOP::Class");
is($bar->meta->name, 'Parent', "this Class::MOP::Class instance is for Parent");

ok($bar->meta->has_method('new'), 'metaclass has "new" method');
ok($bar->meta->has_method('whoami'), 'metaclass has "whoami" method');
ok($bar->meta->has_method('parent'), 'metaclass has "parent" method');

is(blessed($bar->meta->new_object), 'Parent', 'new_object gives a Parent');

$bar->meta->rebless_instance($bar, "Child");
is(blessed($bar), 'Child', "rebless really reblessed");
is(blessed($bar->meta), 'Class::MOP::Class', "meta gives a Class::MOP::Class");
is($bar->meta->name, 'Child', "this Class::MOP::Class instance is for Child");

ok($bar->meta->find_method_by_name('new'), 'metaclass has "new" method');
ok($bar->meta->find_method_by_name('parent'), 'metaclass has "parent" method');
ok(!$bar->meta->has_method('new'), 'no "new" method in this class');
ok(!$bar->meta->has_method('parent'), 'no "parent" method in this class');
ok($bar->meta->has_method('whoami'), 'metaclass has "whoami" method');
ok($bar->meta->has_method('child'), 'metaclass has "child" method');

is(blessed($bar->meta->new_object), 'Child', 'new_object gives a Child');


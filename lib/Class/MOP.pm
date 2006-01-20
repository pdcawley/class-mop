
package Class::MOP;

use strict;
use warnings;

our $VERSION = '0.01';

1;

__END__

=pod

=head1 NAME 

Class::MOP - A Meta Object Protocol for Perl 5

=head1 SYNOPSIS

  # ... coming soon

=head1 DESCRIPTON

This module is an attempt to create a meta object protocol for the 
Perl 5 object system. It makes no attempt to change the behavior or 
characteristics of the Perl 5 object system, only to create a 
protocol for it's manipulation and introspection.

That said, it does attempt to create the tools for building a rich 
set of extensions to the Perl 5 object system. Every attempt has been 
made for these tools to keep to the spirit of the Perl 5 object 
system that we all know and love.

=head2 Who is this module for?

This module is specifically for anyone who has ever created or 
wanted to create a module for the Class:: namespace. The tools which 
this module will provide will hopefully make it easier to do more 
complex things with Perl 5 classes by removing such barriers as 
the need to hack the symbol tables, or understand the fine details 
of method dispatch. 

=head1 PROTOCOLS

The protocol is divided into 3 main sub-protocols:

=over 4

=item The Class protocol

This provides a means of manipulating and introspecting a Perl 5 
class. It handles all of symbol table hacking for you, and provides 
a rich set of methods that go beyond simple package introspection.

=item The Attribute protocol

This provides a consistent represenation for an attribute of a 
Perl 5 class. Since there are so many ways to create and handle 
atttributes in Perl 5 OO, this attempts to provide as much of a 
unified approach as possible, while giving the freedom and 
flexibility to subclass for specialization.

=item The Method protocol

This provides a means of manipulating and introspecting methods in 
the Perl 5 object system. As with attributes, there are many ways to 
approach this topic, so we try to keep it pretty basic, while still 
making it possible to extend the system in many ways.

=back

What follows is a more detailed documentation on each specific sub 
protocol.

=head2 The Class protocol

=head3 Class construction

These methods handle creating Class objects, which can be used to 
both create new classes, and analyze pre-existing ones. 

Class::MOP will internally store weakened references to all the 
instances you create with these methods, so that they do not need 
to be created any more than nessecary. 

=over 4

=item B<create ($package_name, ?@superclasses, ?%methods, ?%attributes)>

This returns the basic Class object, bringing the specified 
C<$package_name> into existence and adding any of the 
C<@superclasses>, C<%methods> and C<%attributes> to it.

=item B<load ($package_name)>

This returns the basic Class object, after examining the given 
C<$package_name> and attempting to discover it's components (the 
methods, attributes and superclasses). 

B<NOTE>: This method makes every attempt to ignore subroutines
which have been exported by other packages into this one.

=item B<initialize ($package_name, @superclasses, %methods, %attributes)>

This creates the actual Class object given a C<$package_name>, 
an array of C<@superclasses>, a hash of C<%methods> and a hash 
of C<%attributes>. This method is used by both C<load> and 
C<create>.

=back

=head3 Instance construction

=over 4

=item <create_instance ($canidate, %params)>

This will construct and instance using the C<$canidate> as storage 
(currently on HASH references are supported). This will collect all 
the applicable attribute meta-objects and layout out the fields in the 
C<$canidate>, it will then initialize them using either use the 
corresponding key in C<%params> or any default value or initializer 
found in the attribute meta-object.

=back

=head3 Informational 

=over 4

=item C<name>

This is a read-only attribute which returns the package name that 
the Class is stored in.

=item C<version>

This is a read-only attribute which returns the C<$VERSION> of the 
package the Class is stored in.

=back

=head3 Inheritance Relationships

=over 4

=item C<superclasses (?@superclasses)>

This is a read-write attribute which represents the superclass 
relationships of this Class. Basically, it can get and set the 
C<@ISA> for you.

=item C<class_precendence_list>

This computes the a list of the Class's ancestors in the same order 
in which method dispatch will be done. 

=back

=head3 Methods

=over 4

=item C<add_method ($method_name, $method)>

This will take a C<$method_name> and CODE reference to that 
C<$method> and install it into the Class. 

B<NOTE> : This does absolutely nothing special to C<$method> 
other than use B<Sub::Name> to make sure it is tagged with the 
correct name, and therefore show up correctly in stack traces and 
such.

=item C<has_method ($method_name)>

This just provides a simple way to check if the Class implements 
a specific C<$method_name>. It will I<not> however, attempt to check 
if the class inherits the method.

=item C<get_method ($method_name)>

This will return a CODE reference of the specified C<$method_name>, 
or return undef if that method does not exist.

=item C<remove_method ($method_name)>

This will attempt to remove a given C<$method_name> from the Class. 
It will return the CODE reference that it has removed, and will 
attempt to use B<Sub::Name> to clear the methods associated name.

=item C<get_method_list>

This will return a list of method names for all I<locally> defined 
methods. It does B<not> provide a list of all applicable methods, 
including any inherited ones. If you want a list of all applicable 
methods, use the C<compute_all_applicable_methods> method.

=item C<compute_all_applicable_methods>

This will return a list of all the methods names this Class will 
support, taking into account inheritance. The list will be a list of 
HASH references, each one containing the following information; method 
name, the name of the class in which the method lives and a CODE reference 
for the actual method.

=item C<find_all_methods_by_name ($method_name)>

This will traverse the inheritence hierarchy and locate all methods 
with a given C<$method_name>. Similar to C<compute_all_applicable_methods>
it returns a list of HASH references with the following information; 
method name (which will always be the same as C<$method_name>), the name of 
the class in which the method lives and a CODE reference for the actual method.

=back

=head2 Attributes

It should be noted that since there is no one consistent way to define the 
attributes of a class in Perl 5. These methods can only work with the 
information given, and can not easily discover information on their own.

=over 4

=item C<add_attribute ($attribute_name, $attribute_meta_object)>

This stores a C<$attribute_meta_object> in the Class object and associates it 
with the C<$attribute_name>. Unlike methods, attributes within the MOP are stored 
as meta-information only. They will be used later to construct instances from
(see C<create_instance> above). More details about the attribute meta-objects can 
be found in the L<The Attribute protocol> section of this document.

=item C<has_attribute ($attribute_name)>

Checks to see if this Class has an attribute by the name of C<$attribute_name> 
and returns a boolean.

=item C<get_attribute ($attribute_name)>

Returns the attribute meta-object associated with C<$attribute_name>, if none is 
found, it will return undef. 

=item C<remove_attribute ($attribute_name)>

This will remove the attribute meta-object stored at C<$attribute_name>, then return 
the removed attribute meta-object. 

B<NOTE:> Removing an attribute will only affect future instances of the class, it 
will not make any attempt to remove the attribute from any existing instances of the 
class.

=item C<get_attribute_list>

This returns a list of attribute names which are defined in the local class. If you 
want a list of all applicable attributes for a class, use the 
C<compute_all_applicable_attributes> method.

=item C<compute_all_applicable_attributes>

This will traverse the inheritance heirachy and return a list of HASH references for
all the applicable attributes for this class. The HASH references will contain the 
following information; the attribute name, the class which the attribute is associated
with and the actual attribute meta-object

=back

=head1 SEE ALSO

=over 4

=item "The Art of the Meta Object Protocol"

=item "Advances in Object-Oriented Metalevel Architecture and Reflection"

=back

=head1 AUTHOR

Stevan Little E<gt>stevan@iinteractive.comE<lt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut




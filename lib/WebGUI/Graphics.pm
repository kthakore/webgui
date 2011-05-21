package WebGUI::Graphics;

# Refactors Image::Magick calls so other libraries can be tested.

use strict;
use warnings;
use Carp qw( croak );
use Image::Magick;

sub new 
{
	
	return Image::Magick->new( @_ );

}

1;

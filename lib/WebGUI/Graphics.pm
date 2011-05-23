package WebGUI::Graphics;

# Refactors Image::Magick calls so other libraries can be tested.

use strict;
use warnings;
use Carp qw( croak );
use Image::Magick;

sub new 
{
	my $class = shift;
	
	my $wrap = bless {@_}, $class;
	$wrap->{core} = Image::Magick->new( @_ );

	return $wrap; 
	# return $warp->{core}; 

}

sub Set
{
	my $self = shift; return $self->{core}->Set( @_ );
}

sub ReadImage
{
	my $self = shift; return $self->{core}->ReadImage( @_ );
}

sub AddNoise
{
	my $self = shift; return $self->{core}->AddNoise( @_ );
}

sub Draw
{
	my $self = shift; return $self->{core}->Draw( @_ );
}

sub Blur
{
	my $self = shift; return $self->{core}->Blur( @_ );
}

sub Border
{
	my $self = shift; return $self->{core}->Border( @_ );
}

sub Write
{
	my $self = shift; return $self->{core}->Write( @_ );
}

sub Get 
{
	my $self = shift; return $self->{core}->Get( @_ );
}

sub Scale 
{
	my $self = shift; return $self->{core}->Scale( @_ );
}

sub Sharpen
{
	my $self = shift; return $self->{core}->Sharpen( @_ );
}

sub Read
{
	my $self = shift; return $self->{core}->Read( @_ );
}


sub Crop
{
	my $self = shift; return $self->{core}->Crop( @_ );
}

sub Rotate
{
	my $self = shift; return $self->{core}->Rotate( @_ );
}

sub Resize
{
	my $self = shift; return $self->{core}->Resize( @_ );
}

sub Annotate
{
	my $self = shift; return $self->{core}->Annotate( @_ );
}


1;


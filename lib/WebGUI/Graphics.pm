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
	my $self = shift;

	$self->{core}->Set( @_ );

}

sub ReadImage
{
	my $self = shift;

	$self->{core}->ReadImage( @_ );

}

sub AddNoise
{
	my $self = shift;

	$self->{core}->AddNoise( @_ );

}

sub Draw
{
	my $self = shift;

	$self->{core}->Draw( @_ );

}

sub Blur
{
	my $self = shift;

	$self->{core}->Blur( @_ );

}

sub Border
{
	my $self = shift;

	$self->{core}->Border( @_ );

}

sub Write
{
	my $self = shift;

	$self->{core}->Write( @_ );

}

1;
=pod

=head1 REFACTOR TODO FROM WebGUI::Storage 

=head2 generateThumbnail 

        my $error = $image->Read($self->getPath($filename));
        my ($x, $y) = $image->Get('width','height');
                $image->Scale(width=>$x,height=>$y);
		$image->Sharpen('0.0x1.0');
        $error = $image->Write($self->getPath.'/'.'thumb-'.$filename);

=head2 getSize 

        my $image = WebGUI::Graphics->new;
        my $error = $image->Read($self->getPath($filename));
        my ($x, $y) = $image->Get('width','height');

=head2 getSizeInPixels
        my $error = $image->Read($self->getPath($filename));
        return $image->Get('width','height');

=head2 crop 
    my $error = $image->Read($self->getPath($filename));
        $image->Crop( height => $height, width => $width, x => $x, y => $y );
    $error = $image->Write($self->getPath($filename));

=head2 rotate  

    my $error = $image->Read($self->getPath($filename));
    $image->Rotate( $degree );
    $error = $image->Write($self->getPath($filename));

=head2 resize 
    my $error = $image->Read($self->getPath($filename));
        $image->Set( density => "${density}x${density}" );
        my ($x, $y) = $image->Get('width','height');
        $image->Resize( height => $height, width => $width );
    $error = $image->Write($self->getPath($filename));
=cut 

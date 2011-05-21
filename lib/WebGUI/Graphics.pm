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
=pod

=head1 REFACTOR TODO FROM WebGUI::Storage 

=head2 addFileFromCaptcha

	my $image = WebGUI::Graphics->new();
	$error = $image->Set(size=>'200x50');
    $error = $image->ReadImage('xc:white');
    $error = $image->AddNoise(noise=>"Multiplicative");
    $error = $image->Annotate(font=>WebGUI::Paths->share.'/default.ttf', pointsize=>40, skewY=>0, skewX=>0, gravity=>'center', fill=>'#ffffff', antialias=>'true', text=>$challenge);
    $error = $image->Draw(primitive=>"line", points=>"5,5 195,45", stroke=>'#ffffff', antialias=>'true', strokewidth=>2);
    $error = $image->Blur(geometry=>"9");
    $error = $image->Set(type=>"Grayscale");
    $error = $image->Border(fill=>'black', width=>1, height=>1);
    $error = $image->Write($self->getPath($filename));

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

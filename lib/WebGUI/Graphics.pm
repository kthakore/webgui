package WebGUI::Graphics;

# Refactors Image::Magick calls so other libraries can be tested.

use strict;
use warnings;
use Carp qw( croak );
use Image::Magick;
use GD;
use GD::Thumbnail;
use GD::SecurityImage;
use Try::Tiny;

sub new {
    my $class = shift;

    my $wrap = bless {@_}, $class;
    $wrap->{core} = Image::Magick->new(@_);

    return $wrap;

    # return $warp->{core};

}

sub Set {
    my $self = shift;
    return $self->{core}->Set(@_);
}

sub ReadImage {
    my $self = shift;
    return $self->{core}->ReadImage(@_);
}

sub AddNoise {
    my $self = shift;
    return $self->{core}->AddNoise(@_);
}

sub Draw {
    my $self = shift;
    return $self->{core}->Draw(@_);
}

sub Blur {
    my $self = shift;
    return $self->{core}->Blur(@_);
}

sub Border {
    my $self = shift;
    return $self->{core}->Border(@_);
}

sub Write {
    my $self = shift;
    return $self->{core}->Write(@_);
}

sub Get {
    my $self = shift;
    return $self->{core}->Get(@_);
}

sub Scale {
    my $self = shift;
    return $self->{core}->Scale(@_);
}

sub Sharpen {
    my $self = shift;
    return $self->{core}->Sharpen(@_);
}

sub Read {
    my $self = shift;
    return $self->{core}->Read(@_);
}

sub Crop {
    my $self = shift;
    return $self->{core}->Crop(@_);
}

sub Rotate {
    my $self = shift;
    return $self->{core}->Rotate(@_);
}

sub Resize {
    my $self = shift;
    return $self->{core}->Resize(@_);
}

sub Annotate {
    my $self = shift;
    return $self->{core}->Annotate(@_);
}

sub genThumbnailRefactor {

    my $filename      = shift;
    my $thumbnailSize = shift;
    my $thumbname     = shift;

    # Open the image or return the error message
    my $image = GD::Image->new($filename) || return "Couldn't read image for thumbnail creation: $!";
    my $thumb = GD::Thumbnail->new        || return $!;
    my $raw   = $image->gd;
    my $n     = $thumbnailSize;
    $raw = $thumb->create( $filename, $n );
    my $error = write_gd( $thumbname, $raw );
    return "Couldn't create thumbnail: $error" if $error;
}

sub addFileFromCaptchaRefactor {

    my $filename  = shift;
    my $challenge = shift;
    my $ttf       = shift;

    my $image = GD::SecurityImage->new( width => 200, height => 50, gd => 1, itype => 'gif', font => $ttf );
    $image->random($challenge);
    $image->create( 'ttf', 'circle', [ 255, 255, 255 ], [ 120, 200, 200 ] );
    $image->particle;
    my ( $image_data, $mime_type, $random_number ) = $image->out;

    return write_gd( $filename, $image_data );

}

sub cropRefactor {
    my $self     = shift;
    my $filename = shift;
    my $width    = shift;
    my $height   = shift;
    my $x        = shift;
    my $y        = shift;

    try {

        my $image = GD::Image->new($filename) || die "Couldn't read image for resizing: " . $!;

        my $crop_img = GD::Image->new( $width, $height );

        $self->session->log->info("Resizing $filename to w:$width h:$height x:$x y:$y");

        $crop_img->copy( $image, $x, $y, 0, 0, $width, $height );

        my $error = write_gd( $filename, $crop_img->gd );

        if ($error) {
            $self->session->log->error( "Couldn't resize image: " . $error );
            return 0;
        }

    } ## end try
    catch {

        $self->session->log->error($_);
        return 0;

    };

    return 1;
} ## end sub cropRefactor

sub getSizeRefactor {

    my $self = shift;

    my $filename = shift;

    my $error;
    my $image;
    try {
        $image = GD::Image->new($filename) or die "Couldn't read image to check the size of it: " . $!;
        my ( $x, $y ) = $image->getBounds();
        return ( $x, $y );

    }
    catch {
        $self->session->log->error($_);
        return 0;

    };

} ## end sub getSizeRefactor

sub write_gd {
    my $filename = shift;
    my $raw      = shift;

    open my $IMG, ">", $filename or return $!;
    binmode $IMG;
    print $IMG $raw;
    close $IMG;

    return 0;
}

1;


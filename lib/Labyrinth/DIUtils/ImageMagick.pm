package Labyrinth::DIUtils::ImageMagick;

use warnings;
use strict;

our $VERSION = '5.05';

=head1 NAME

Labyrinth::DIUtils::ImageMagick - Digital Image utilities driver for ImageMagick.

=head1 SYNOPSIS

  use Labyrinth::DIUtils::ImageMagick;

  Labyrinth::DIUtils::Tool('ImageMagick');

  my $hook = Labyrinth::DIUtils::ImageMagick->new($file);
  my $hook = $hook->rotate($degrees);       # 0 - 360
  my $hook = $hook->reduce($xmax,$ymax);
  my $hook = $hook->thumb($thumbnail,$square);

=head1 DESCRIPTION

Handles the driver software for ImageMagick image manipulation; Do not use
this module directly, access via Labyrinth::DIUtils.

=cut

#############################################################################
#Modules/External Subroutines                                               #
#############################################################################

use Image::Magick;

#############################################################################
#Subroutines
#############################################################################

=head1 METHODS

=head2 Contructor

=over 4

=item new($file)

The constructor. Passed a single mandatory argument, which is then used as the
image file for all image manipulation.

=back

=cut

sub new {
    my $self  = shift;
    my $image = shift;

    die "no image specified"    if !$image;
    die "no image file found"   if !-f $image;

    # read in current image
    my $i = Image::Magick->new();
    die "object image error: [$image]\n"    if !$i;
    my $c = $i->Read($image);
    die "read image error: [$image] $c\n"   if $c;

    my $atts = {
        'image'     => $image,
        'object'    => $i,
    };

    # create the object
    bless $atts, $self;
    return $atts;
}


=head2 Image Manipulation

=over 4

=item rotate($degrees)

Object Method. Passed a single mandatory argument, which is then used to turn
the image file the number of degrees specified.

=cut

sub rotate {
    my $self = shift;
    my $degs = shift || return undef;

    return  unless($self->{image} && $self->{object});

    my $i = $self->{object};
    $i->Rotate(degrees => $degs);
    my $c = $i->Write($self->{image});
    die "write image error: [$self->{image}] $c\n"   if $c;

    return 1;
}

=item reduce($xmax,$ymax)

Object Method. Passed two arguments (defaulting to 100x100), which is then
used to reduce the image to a size that fit inside a box of the specified
dimensions.

=cut

sub reduce {
    my $self = shift;
    my $xmax = shift || 100;
    my $ymax = shift || 100;

    return  unless($self->{image} && $self->{object});

    my $i = $self->{object};
    my ($width,$height) = $i->Get('columns', 'rows');
    return  unless($width > $xmax || $height > $ymax);

    $i->Scale(geometry => "${xmax}x${ymax}");
    my $c = $i->Write($self->{image});
    die "write image error: [$self->{image}] $c\n"   if $c;

    return 1;
}

=item thumb($thumbnail,$square)

Object Method. Passed two arguments, the first being the name of the thumbnail
file to be created, and the second being a single dimension of the square box
(defaulting to 100), which is then used to reduce the image to a thumbnail.

=back

=cut

sub thumb {
    my $self = shift;
    my $file = shift || return;
    my $smax = shift || 100;

    my $i = $self->{object};
    return  unless($i);

    $i->Scale(geometry => "${smax}x${smax}");
    my $c = $i->Write($file);
    die "write image error: [$self->{image}] $c\n"   if $c;

    return 1;
}

1;

__END__

=head1 SEE ALSO

  Image::Magick
  Labyrinth

=head1 AUTHOR

Barbie, <barbie@missbarbell.co.uk> for
Miss Barbell Productions, L<http://www.missbarbell.co.uk/>

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2002-2013 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or
  modify it under the Artistic License 2.0.

=cut
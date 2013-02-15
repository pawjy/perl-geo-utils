package Geo::Format::Image;
use strict;
use warnings;
our $VERSION = '1.0';
use Geo::Coords;
use Exporter::Lite;

our @EXPORT= qw(
    get_location_from_img
);

sub get_location_from_img ($) {
    my $img = shift; # $img is path or reference of imgdata (or filehandle?)
    require Image::Info;
    my $exif = Image::Info::image_info($img);
    my ($lat, $lon);
    if ($exif->{GPSLatitudeRef} && $exif->{GPSLatitudeRef} =~ /^(N|S)$/i && (my @data = @{$exif->{GPSLatitude}})) {
        $lat = $data[0] / $data[1] + ($data[2] / $data[3]) / 60 + ($data[4] / $data[5]) / 3600;
        $lat *= -1 if $exif->{GPSLatitudeRef} =~ /S/i;
    }
    if ($exif->{GPSLongitudeRef} && $exif->{GPSLongitudeRef} =~ /^(E|W)$/i && (my @data = @{$exif->{GPSLongitude}})) {
        $lon = $data[0] / $data[1] + ($data[2] / $data[3]) / 60 + ($data[4] / $data[5]) / 3600;
        $lon *= -1 if $exif->{GPSLongitudeRef} =~ /W/i;
    }

    if ($lat && $lon && $exif->{GPSMapDatum} && ($exif->{GPSMapDatum} eq 'TOKYO')) {
        ($lat, $lon) = tokyo2wgs($lat, $lon);
    }
    return ($lat, $lon);
}

1;

package test::Geo::Format::Image;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*/lib');
use Test::More;
use Geo::Format::Image;

my $image_d = file(__FILE__)->dir->parent->subdir('images');

sub _get_location_from_img_path_without_location : Test(2) {
    my $img_file_path = $image_d->file("img-without-geo.gif");
    my ($lat, $lon) = get_location_from_img "$img_file_path";
    ok not $lat;
    ok not$lon;
}

sub _get_location_from_img_data_without_location : Test(2) {
    my $img_data = $image_d->file("img-without-geo.gif")->slurp;
    my ($lat, $lon) = get_location_from_img \$img_data;
    ok not $lat;
    ok not $lon;
}

sub _get_location_from_img_filehandle_without_location : Test(2) {
    my $img_fh = $image_d->file("img-without-geo.gif")->open;
    my ($lat, $lon) = get_location_from_img $img_fh;
    ok not $lat;
    ok not $lon;
}

sub _get_location_from_img_path_jpg : Test(2) {
    my $img_file_path = $image_d->file("img-with-geo.jpg");
    my ($lat, $lon) = get_location_from_img "$img_file_path";
    ok abs ($lat - 35.011) < 0.001;
    ok abs ( $lon - 135.7615) < 0.001;
}

sub _get_location_from_img_data : Test(2) {
    my $img_data = $image_d->file("img-with-geo.jpg")->slurp;
    my ($lat, $lon) = get_location_from_img \$img_data;
    ok abs ($lat - 35.011) < 0.001;
    ok abs ( $lon - 135.7615) < 0.001;
}

sub _get_location_from_img_filehandle : Tests {
    my $img_fh = $image_d->file("img-with-geo.jpg")->open;
    my ($lat, $lon) = get_location_from_img $img_fh;
    ok abs ($lat - 35.011) < 0.001;
    ok abs ( $lon - 135.7615) < 0.001;
}

__PACKAGE__->runtests;

1;

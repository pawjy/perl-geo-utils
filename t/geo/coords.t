package test::Geo::Coords;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*/lib');
use Test::More;
use Geo::Coords;

sub _tokyo2wgs : Test(2) {
    my ($b, $l) = tokyo2wgs 10.3333, 124.3333;
    is $b, 10.338656151825;
    is $l, 124.331788071567;
}

sub _meter_distance : Test(2) {
    is meter_distance_of_latlons(0,0 => 0,0), 0;
    is meter_distance_of_latlons(0,0 => 1,0), 110946;
}

__PACKAGE__->runtests;

1;

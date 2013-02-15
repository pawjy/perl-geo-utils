package test::Geo::Format::Degree;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*/lib');
use Test::Differences;
use Geo::Format::Degree;

sub _geo_number_to_shms : Test(5) {
    for (
        [0 => [1, 0, 0, 0]],
        [35.02475764688 => [1, 35, 1, 29]],
        [135.77008745431 => [1, 135, 46, 12]],
        [-35.02475764688 => [-1, 35, 1, 29]],
        [-135.77008745431 => [-1, 135, 46, 12]],
    ) {
        eq_or_diff [geo_number_to_shms $_->[0]], $_->[1];
    }
}

__PACKAGE__->runtests;

1;


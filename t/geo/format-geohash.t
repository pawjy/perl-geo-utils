package test::Geo::Format::Geohash;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->parent->subdir('*/lib');
use Test::More;
use Test::Differences;
use Geo::Format::Geohash;

sub _encode_geohash : Test(5) {
    for (
        [(1, 2) => 's01m'],
        [(-10.2, 0.444444) => 'kn0mfp5ssq1m'],
        [undef, undef, 's000'],
        ['', '' => 's000'],
        [0, 0 => 's000'],
    ) {
        is encode_geohash($_->[0], $_->[1]) => $_->[2];
    }
}

sub _decode_geohash : Test(6) {
    for (
        [undef, (0, 0)],
        ['' => (0, 0)],
        ['s000' => (0.087890625, 0.17578125)],
        [kn0mfp5ssq1m => (-10.2000000793487, 0.444443877786398)],
        [s01m => (0.966796875, 1.93359375)],
        ['abc' => (undef, undef)],
    ) {
        eq_or_diff [decode_geohash($_->[0])], [$_->[1], $_->[2]];
    }
}

sub _calculate_adjacent_geohash_recursion : Tests {
    my $edge_geo_hash;

    my @trys = (
        [0, 179],
        [0, 180],
        [0, 181],
        [0, -179],
        [0, -180],
        [0, -181],

        [89, 0],
        [90, 0],
        [91, 0],
        [-89, 0],
        [-90, 0],
        [-91, 0],

        [90, 180],
        [90, -180],
        [-90, 180],
        [-90, -180],
    );

    for my $try (@trys) {
        $edge_geo_hash = encode_geohash($try->[0], $try->[1]);
        geohash9 $edge_geo_hash; # call calculate_adjacent_geohash inside
    }
    pass;
}

sub _geohash9 : Test(1) {
    eq_or_diff geohash9 'xn0x1m', [qw(
        xn0x1n xn0x1q xn0x1w
        xn0x1j xn0x1m xn0x1t
        xn0x1h xn0x1k xn0x1s
    )];
}

sub _geohash_sqla : Test(5) {
    eq_or_diff geohash_sqla(gh => 'xn0x1m', 3, 0) => {gh => {-like => 'xn0%'}};
    eq_or_diff geohash_sqla(GH => 'xn0x1m', 4, 1) => {-or => [
        {GH => {-like => 'xn22%'}},
        {GH => {-like => 'xn28%'}},
        {GH => {-like => 'xn2b%'}},
        {GH => {-like => 'xn0r%'}},
        {GH => {-like => 'xn0x%'}},
        {GH => {-like => 'xn0z%'}},
        {GH => {-like => 'xn0q%'}},
        {GH => {-like => 'xn0w%'}},
        {GH => {-like => 'xn0y%'}},
    ]};
    eq_or_diff geohash_sqla(geo => 'xn0x1m', 9, 0) => {geo => {-like => 'xn0x1m%'}};
    eq_or_diff geohash_sqla(geo => 'xn%', 9, 0) => {geo => {-like => 'xn\%%'}};
    eq_or_diff geohash_sqla(GH => 'x_m', 4, 1) => {-or => [
        {GH => {-like => 'x\_s%'}},
        {GH => {-like => 'x\_t%'}},
        {GH => {-like => 'x\_w%'}},
        {GH => {-like => 'x\_k%'}},
        {GH => {-like => 'x\_m%'}},
        {GH => {-like => 'x\_q%'}},
        {GH => {-like => 'x\_h%'}},
        {GH => {-like => 'x\_j%'}},
        {GH => {-like => 'x\_n%'}},
    ]};
}

__PACKAGE__->runtests;

1;


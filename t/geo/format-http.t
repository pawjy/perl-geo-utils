package test::Geo::Format::HTTP;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->subdir('t_deps/modules/*/lib');
use Test::MoreMore;
use Test::MoreMore::Mock;
use Geo::Format::HTTP;

sub _get_location_from_req_undef : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new;
    ng $lat;
    ng $lon;
}

sub _get_location_from_req_latlon_1 : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '+34.42.33.14',
            lon => '+135.36.52.52',
        },
    );
    is $lat, '34.7092055555556';
    is $lon, '135.614588888889';
}

sub _get_location_from_req_latlon_zero : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '+0.0.0',
            lon => '+0.0.0',
        },
    );
    ng $lat;
    ng $lon;
}

sub _get_location_from_req_latlon_zero_2 : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '0.0.0.0',
            lon => '0.0.0.0',
        },
    );
    ng $lat;
    ng $lon;
}

sub _get_location_from_req_latlon_one : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '+1.0.0',
            lon => '+1.0.0',
        },
    );
    is $lat, 1;
    is $lon, 1;
}

sub _get_location_from_req_latlon_one_2 : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '1.0.0.0',
            lon => '1.0.0.0',
        },
    );
    is $lat, 1;
    is $lon, 1;
}

sub _get_location_from_req_latlon_abc : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '21.34.12',
            lon => '11.12.50',
        },
    );
    is $lat, 21.57;
    is $lon, 11.2138888888889;
}

sub _get_location_from_req_latlon_none : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '-1.0.0',
            lon => '-1.0.0',
        },
    );
    is $lat, -1;
    is $lon, -1;
}

sub _get_location_from_req_latlon_ntwo : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => '-2.0.0',
            lon => '-2.0.0',
        },
    );
    is $lat, -2;
    is $lon, -2;
}

sub _get_location_from_req_softbank : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            pos => 'N35.0.51.001E135.45.47.023',
            geo => 'wgs84',
            'x-acr' => '1',
        },
    );
    is $lat, + (35 + 0 / 60 + 51 / 60 / 60);
    is $lon, + (135 + 45 / 60 + 47 / 60 / 60);
}

sub _get_location_from_req_softbank_sw : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            pos => 'S35.0.51.001W135.45.47.023',
            geo => 'wgs84',
            'x-acr' => '1',
        },
    );
    is $lat, - (35 + 0 / 60 + 51 / 60 / 60);
    is $lon, - (135 + 45 / 60 + 47 / 60 / 60);
}

sub _get_location_from_req_willcom : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            pos => 'N35.44.33.150E135.22.33.121',
        },
    );
    is $lat, '35.7456664429371';
    is $lon, '135.373042610934';
}

sub _get_location_from_req_ll : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            ll => "13.4431345331,-135.535233333",
        },
    );
    is $lat, 13.4431345331;
    is $lon, -135.535233333;
}

sub _get_location_from_req_ll_ng : Test(4) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            ll => "13.4431345331",
        },
    );
    is $lat, 13.4431345331;
    is $lon, 0;
    ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            ll => "",
        },
    );
    is $lat, 0;
    is $lon, 0;
}

sub _get_location_from_req_custom : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            lat => 12.4431345331,
            lon => -124.535233333,
        },
    );
    is $lat, 12.4431345331;
    is $lon, -124.535233333;
}

sub _get_location_from_req_jslatlon_1 : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            js_lat => '+34.7092055555556',
            js_lon => '-135.614588888889',
        },
    );
    is $lat, '+34.7092055555556';
    is $lon, '-135.614588888889';
}

sub _get_location_from_req_too_large : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            js_lat => '+95',
            js_lon => '+182',
        },
    );
    is $lat, 90;
    is $lon, 180;
}

sub _get_location_from_req_too_small : Test(2) {
    my ($lat, $lon) = get_location_from_req +Test::MoreMore::Mock->new(
        param => {
            js_lat => '-95',
            js_lon => '-182',
        },
    );
    is $lat, -90;
    is $lon, -180;
}

__PACKAGE__->runtests;

1;

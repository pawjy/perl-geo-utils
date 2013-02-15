package Geo::Format::Degree;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;

our @EXPORT = qw(
    geo_number_to_sdms
    geo_number_to_shms
);

sub geo_number_to_sdms ($) {
    my $n = shift;

    my $sign = 1;
    if ($n < 0) {
        $sign = -1;
        $n *= -1;
    }

    my $hour = int $n;
    my $min = int(60 * ($n - $hour));
    my $sec = int(60 * (60 * $n - 60 * $hour - $min));
    
    return ($sign, $hour, $min, $sec);
}
*geo_number_to_shms = \&geo_number_to_sdms; # for compat

1;

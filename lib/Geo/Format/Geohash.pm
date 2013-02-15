package Geo::Format::Geohash;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;

our @EXPORT = qw(
    encode_geohash
    decode_geohash
    geohash9
    geohash_sqla
);

sub encode_geohash ($$) {
    my ($lat, $lon) = @_;
    require Geo::Hash;
    return Geo::Hash->encode($lat, $lon);
}

sub decode_geohash ($) {
    my $geohash = shift;
    require Geo::Hash;
    my ($lat, $lon) = eval { (Geo::Hash->decode($geohash)) };
    return ($lat, $lon); # or (undef, undef)
}

# ------

# <http://github.com/davetroy/geohash-js/blob/master/geohash.js>
# geohash.js
# Geohash library for Javascript
# (c) 2008 David Troy
# Distributed under the MIT License

use constant BASE32 => "0123456789bcdefghjkmnpqrstuvwxyz";
use constant NEIGHBORS => {
    right => { even => "bc01fg45238967deuvhjyznpkmstqrwx" },
    left => { even => "238967debc01fg45kmstqrwxuvhjyznp" },
    top => { even => "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
    bottom => { even => "14365h7k9dcfesgujnmqp0r2twvyx8zb" },
};
use constant BORDERS => {
    right => { even => "bcfguvyz" },
    left => { even => "0145hjnp" },
    top => { even => "prxz" },
    bottom => { even => "028b" },
};

NEIGHBORS->{bottom}->{odd} = NEIGHBORS->{left}->{even};
NEIGHBORS->{top}->{odd} = NEIGHBORS->{right}->{even};
NEIGHBORS->{left}->{odd} = NEIGHBORS->{bottom}->{even};
NEIGHBORS->{right}->{odd} = NEIGHBORS->{top}->{even};

BORDERS->{bottom}->{odd} = BORDERS->{left}->{even};
BORDERS->{top}->{odd} = BORDERS->{right}->{even};
BORDERS->{left}->{odd} = BORDERS->{bottom}->{even};
BORDERS->{right}->{odd} = BORDERS->{top}->{even};

sub calculate_adjacent_geohash ($$);
sub calculate_adjacent_geohash ($$) {
    my ($srcHash, $dir) = @_;
    return calculate_adjacent_geohash_limited($srcHash, $dir, 30);
}

sub calculate_adjacent_geohash_limited ($$$);
sub calculate_adjacent_geohash_limited ($$$) {
    my ($srcHash, $dir, $limit) = @_;
    $srcHash =~ tr/A-Z/a-z/;
    my $lastChr = substr $srcHash, -1;
    my $type = ((length $srcHash) % 2) ? 'odd' : 'even';
    my $base = substr $srcHash, 0, -1 + length $srcHash;
    if ($limit > 0 && -1 != index BORDERS->{$dir}->{$type}, $lastChr) {
        $limit -= 1;
        $base = calculate_adjacent_geohash_limited($base, $dir, $limit);
    }
    return $base . substr BASE32, (index NEIGHBORS->{$dir}->{$type}, $lastChr), 1;
}

# ------

sub geohash9 ($) {
    my @geohash;
    $geohash[4] = shift;
    $geohash[1] = calculate_adjacent_geohash $geohash[4], 'top';
    $geohash[5] = calculate_adjacent_geohash $geohash[4], 'right';
    $geohash[7] = calculate_adjacent_geohash $geohash[4], 'bottom';
    $geohash[3] = calculate_adjacent_geohash $geohash[4], 'left';
    $geohash[0] = calculate_adjacent_geohash $geohash[1], 'left';
    $geohash[2] = calculate_adjacent_geohash $geohash[1], 'right';
    $geohash[6] = calculate_adjacent_geohash $geohash[7], 'left';
    $geohash[8] = calculate_adjacent_geohash $geohash[7], 'right';
    return \@geohash;
}

## <http://dev.mysql.com/doc/refman/5.6/en/string-literals.html>.
sub _like ($) {
  my $s = $_[0];
  $s =~ s/([\\%_])/\\$1/g;
  return $s;
} # like

sub geohash_sqla ($$$$) {
    my ($column_name, $geohash, $length, $expand9) = @_;
    $geohash = substr $geohash, 0, $length;
    if ($expand9) {
        return {-or => [map { {$column_name => {-like => (_like $_) . '%'}} } @{geohash9 $geohash}]};
    } else {
        return {$column_name => {-like => (_like $geohash) . '%'}};
    }
}

1;

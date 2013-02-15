#!/usr/bin/perl
use strict;
use warnings;
use Encode;

my $datum_code_file_name = 'WGS2TKY2.html';
open my $datum_code_file, '<', $datum_code_file_name or die "$0: $datum_code_file_name: $!";
local $/ = undef;
my $datum_code = <$datum_code_file> // die;
$datum_code =~ s[<[^<>]+>][]g;
$datum_code =~ s[&gt;][>]g;
$datum_code = decode 'cp932', $datum_code;
$datum_code =~ s[^.*?\#!][\#]s;

my $datum1 = $datum_code;
$datum1 =~ s/^.+?\n(?!\#)//s;
$datum1 =~ s/\@files.+//s;

my $datum2 = $datum_code;
$datum2 =~ s/^.*?\bsub\b/sub/s;
$datum2 =~ s/\bsub deg2gdms.+//s;

binmode STDOUT, ':encoding(utf8)';
while (<>) {
    s/\#\s*\@\@\@DATUM1\@\@\@/$datum1/;
    s/\#\s*\@\@\@DATUM2\@\@\@/$datum2/;
    print;
}

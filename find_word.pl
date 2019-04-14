#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use Smart::Options;

my $opts = Smart::Options->new
    ->default(invert => '')->alias(v => 'invert')
    ->default(unrestricted => '')->alias(u => 'unrestricted')
    ->default(depth => 10)->alias(d => 'depth')
    ->parse;

my $invert = $opts->{invert};
if ($invert ne '') {
    if (ref $invert eq "ARRAY") {
        my @invert = @$invert;
        $invert = join ' --ignore-dir ', @invert;
    }
    $invert = '--ignore-dir '.$invert;
}

my $unrestricted = '';
if ($opts->{unrestricted}) {
    $unrestricted = '-u';
}

my $depth = $opts->{depth};
my $query = $opts->{_}->[0];

my $search_segment = "ag --depth $depth $unrestricted $invert $query";

my $result = `$search_segment | peco`;
$result =~ s/\A(.+?):\d+.*/$1/;
print `echo $result`;

#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @args = @ARGV;

my $depth = 10;
my $result = '';
my $omitf = '';
my $omitd = '';
my $query = '';
my $dump = 0;

my @omitf = ();
my @omitd = ('.*');
my @path = ();

# オプション取得
for my $arg (@args) {
    chomp $arg;
    if ($arg =~ /\A-i=(.+)\z/) {
        push @path, $1;
    }
    elsif ($arg =~ /\A(\w+)\z/) {
        $query = $1;
    }
}

my $path;
if (scalar @path != 0) {
    if (scalar @path > 1) {
        for (@path) {
            $path .= ("! -path '*/*$_*/*' ");
        }
    }
    elsif (scalar @path == 1) {
        $path = "! -path '*/*$path[0]*/*'";
    }
    $path =~ s/ \z//;
}

my $print_peco = '-print 2>/dev/null';

$result = `find . -iname "*$query*"`;

$result =~ s/[ \t]+/_/g;
print $result;

my @result;
@result = split /\n/, $result;

say "\nTotal files: ".scalar @result;
say "OK? (y/N)";

my $answer = <STDIN>;
chomp $answer;

if ($answer eq 'y') {
    for (@result) {
        print `open $_`;
    }
}

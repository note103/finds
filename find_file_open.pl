#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @args = @ARGV;
my $query = '';

for my $arg (@args) {
    chomp $arg;
    if ($arg =~ /\A(\w+)\z/) {
        $query = $1;
    }
}

my $result = `find . -iname "*$query*"`;
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

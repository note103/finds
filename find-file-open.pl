#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my $query = $ARGV[0];

unless ($query) {
    say "Input a query.";
    exit;
}

my $result = `find . -iname "*$query*"`;

print $result;

my @result = split /\n/, $result;

say "\nTotal files: ".scalar @result;
say "OK? (y/N)";

my $answer = <STDIN>;
chomp $answer;

if ($answer eq 'y') {
    for (@result) {
        print `open $_`;
    }
}

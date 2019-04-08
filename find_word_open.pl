#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @args = @ARGV;
my $depth = 10;
my $dump = 0;
my $opt = '-S';
my $query = '';
my @omit = ();

for my $arg (@args) {
    chomp $arg;
    if ($arg =~ /\A-d=(\d+)\z/) {
        $depth = $1;
    }
    elsif ($arg eq '-d') {
        $dump = 1;
    }
    elsif ($arg =~ /\A-i=(.+)\z/) {
        push @omit, "*$1*";
    }
    else {
        $query = $arg;
    }
}

$query = '.' if $query eq '';

my $omit = '';
if (scalar @omit != 0) {
    if (scalar @omit > 1) {
        for (@omit) {
            $omit .= "--ignore-dir $_ ";
        }
    }
    elsif (scalar @omit == 1) {
        $omit = "--ignore-dir $omit[0]";
    }
}

my $search_segment = "ag $opt $query --depth $depth $omit";

my $result = `$search_segment`;
my @result = split /\n/, $result;

my %urls;
for (@result) {
    say $_;
    $_ =~ s/\A(.+?):\d+.*/$1/;
    $urls{$_} = 1;
}

say "\nTotal files: ".scalar keys %urls;
say "OK? (y/N)";

my $answer = <STDIN>;
chomp $answer;

if ($answer eq 'y') {
    for (keys %urls) {
        print `open $_`;
    }
}

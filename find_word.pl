#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @args = @ARGV;

my $depth = 10;
my $all = '';
my $query = '';
my @omit = ();

for my $arg (@args) {
    chomp $arg;
    if ($arg =~ /\A-d=(\d+)\z/) {
        $depth = $1;
    }
    elsif ($arg =~ /\A-v=(.+)\z/) {
        push @omit, "$1";
    }
    elsif ($arg eq '-u') {
        $all = '-u';
    }
    elsif ($arg =~ /\A-c=(.+)\z/) {
        next;
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

my $search_segment = "ag --depth $depth $all $omit $query";

my $result = `$search_segment | peco`;
$result =~ s/\A(.+?):\d+.*/$1/;
print `echo $result`;

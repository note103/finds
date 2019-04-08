#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my @args = @ARGV;

my $all = '';
my $depth = 10;
my $dump = 0;
my $file = '';
my $hidden = '';
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
    elsif ($arg =~ /\A-f=(.+)\z/) {
        $file = "-G $1";
    }
    elsif ($arg eq '-h') {
        $hidden = '--hidden';
    }
    elsif ($arg eq '--count') {
        $opt = '-cS';
    }
    elsif ($arg =~ /\A-i=(.+)\z/) {
        push @omit, "*$1*";
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

my $search_segment = "ag $opt $query --depth $depth -u -i $hidden $omit $file";

if ($dump == 1) {
    warn `$search_segment`;
}
else {
    my $result = `$search_segment | peco`;
    $result =~ s/\A(.+?):\d+.*/$1/;
    print `echo $result`;
}

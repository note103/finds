#!/usr/bin/env perl
use strict;
use warnings;

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
    if ($arg =~ /\A-d=(\d+)\z/) {
        $depth = $1;
    }
    elsif ($arg =~ /\A-vf=(.+)\z/) {
        push @omitf, $1;
    }
    elsif ($arg =~ /\A-vd=(.+)\z/) {
        push @omitd, $1;
    }
    elsif ($arg =~ /\A-i=(.+)\z/) {
        push @path, $1;
    }
    elsif ($arg eq '-a') {
        shift @omitd;
    }
    elsif ($arg =~ /\A(\w+)\z/) {
        $query = "--query $1";
    }
    elsif ($arg eq '-d') {
        $dump = 1;
    }
}

if (scalar @omitd != 0) {
    if (scalar @omitd > 1) {
        for (@omitd) {
            $omitd .= ("-path './$_' -o ");
        }
    }
    elsif (scalar @omitd == 1) {
        $omitd = "-path './$omitd[0]'";
    }
    $omitd =~ s/-o \z//;
}

if (scalar @omitf != 0) {
    if (scalar @omitf > 1) {
        for (@omitf) {
            $omitf .= ("! -iname '*$_*' ");
        }
    }
    elsif (scalar @omitf == 1) {
        $omitf = "! -iname '*$omitf[0]*'";
    }
    $omitf =~ s/ \z//;
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

my $find_omit_segment = "find . -maxdepth $depth $omitd -prune -o -iname '*'";
my $find_no_omit_segment = "find . -maxdepth $depth -iname '*'";
my $print_peco = "-print | peco $query";
$print_peco = '-print 2>/dev/null' if $dump == 1;

if ($path) {
    if ($omitf) {
        $result = `find . -maxdepth $depth $path $omitf -iname '*' $print_peco`;
    }
    else {
        $result = `find . -maxdepth $depth $path -iname '*' $print_peco`;
    }
}
elsif ($omitd) {
    if ($omitf) {
        $result = `$find_omit_segment $omitf $print_peco`;
    }
    else {
        $result = `$find_omit_segment $print_peco`;
    }
}
else {
    if ($omitf) {
        $result = `$find_no_omit_segment $omitf $print_peco`;
    }
    else {
        $result = `$find_no_omit_segment $print_peco`;
    }
}

if ($result =~ /\n/) {
    if ($dump == 1) {
        $result =~ s/[ \t]+/_/g;
        my @result;
        @result = split /\n/, $result;
        print `echo @result`;
    }
    else {
        $result =~ s/\A(.+?):\d+.*/$1/;
        print `echo "$result"`;
    }
}
else {
    $result =~ s/\A(.+?):\d+.*/$1/;
    print `echo $result`;
}

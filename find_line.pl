#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
binmode STDOUT, ':encoding(UTF-8)';
use open IN => ':encoding(UTF-8)';
use Encode;

my @args = @ARGV;
my $length = 35;
my $command = 'echo';
my $dump = 0;

for my $arg (@args) {
    chomp $arg;
    if ($arg eq '-o') {
        if ($^O eq 'darwin') {
            $command = 'open';
        }
        else {
            $command = 'vim';
        }
    }
    elsif ($arg eq '-d') {
        $dump = 1;
    }
    elsif ($arg =~ /\A(\d+)\z/) {
        $length = $1;
    }
}

my @files = glob "*";
@files = grep {-f $_} @files;

my @list;
my $num;
my $fill;
my @orig;
my $substr;

for my $file (@files) {
    push @orig, $file;
    $file = decode('utf8', $file);
    if ( length($file) > $length ){
        $substr = substr($file, 0, ($length - 3)).'...';
    }
    else {
        $num = ($length - length($file));
        $fill = ' ' x $num;
        $substr = "$file$fill";
    }
    push @list, "$substr : ".`sed -n 1p $file | sed -e 's/"//g' | sed -e 's/^# //'`;
}

my $contents;
my $filename;
if ($dump == 1) {
    for (@list) {
        chomp $_;
        if ($_ =~ /\A(.+?): (.+)\z/ms) {
            $filename = $1;
            $contents = $2;
            $contents = substr($contents, 0, ($length - 3)).'...' if (length($contents) > $length);
            print `echo "\033[32m$filename\033[00m: \033[33m$contents"`;
            # see also: https://scrapbox.io/note103/memo%20list%20%E7%9A%84%E3%81%AA%E3%82%82%E3%81%AE
            # see also: http://yonchu.hatenablog.com/entry/2012/10/20/044603
        }
    }
    print `echo "\033[00m" | tr -d "\n"`;
}
else {
    if (@list) {
        chomp $list[-1];
        my $catch = `echo "@list" | sed -e 's/^ *//' | peco`;

        $catch =~ s/(\S+).*:.+/$1/ms;
        $catch =~ s/\.\.$//ms;
        
        if ($catch ne '') {
            for my $orig (@orig) {
                if ($orig =~ /$catch/) {
                    $orig =~ s/(\w.+):.+/$1/ms;
                    print `$command $orig`;
                }
            }
        }
    }
}

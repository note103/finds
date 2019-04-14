#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use Smart::Options;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Pod::Usage;


my $opts = {
    depth => 10,
    invert => '',
};

GetOptions(
    $opts => qw(
        depth|d=i
        command=s
        invert|v=s@
        unrestricted|u
        help|h
    ),
);

my $query = $ARGV[0] // '';

pod2usage if ($opts->{help});

my $invert = '';
if ($opts->{invert}) {
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

my $search_segment = "ag --depth $depth $unrestricted $invert $query";

my $result = `$search_segment | peco`;
$result =~ s/\A(.+?):\d+.*/$1/;
print `echo $result`;

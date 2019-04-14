#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Pod::Usage;


my $opts = {
    depth => 10,
    dump => 0,
};

GetOptions(
    $opts => qw(
        dump
        depth=i
        command=s
        invert-file=s@
        invert-dir=s@
        query|q=s@
        help|h
    ),
);

pod2usage if ($opts->{help});


my $depth = $opts->{depth};
my $dump = $opts->{dump};

my @invert_file = @{$opts->{'invert-file'}} if $opts->{'invert-file'};
my @invert_dir = @{$opts->{'invert-dir'}} if $opts->{'invert-dir'};
my @query = @{$opts->{query}} if $opts->{query};

my $invert_file;
if (scalar @invert_file != 0) {
    if (scalar @invert_file > 1) {
        for (@invert_file) {
            $invert_file .= ("! -iname '*$_*' ");
        }
    }
    elsif (scalar @invert_file == 1) {
        $invert_file = "! -iname '*$invert_file[0]*'";
    }
}

my $invert_dir;
if (scalar @invert_dir != 0) {
    if (scalar @invert_dir > 1) {
        for (@invert_dir) {
            $invert_dir .= ("! -path '*/*$_*' ");
        }
    }
    elsif (scalar @invert_dir == 1) {
        $invert_dir = "! -path '*/*$invert_dir[0]*'";
    }
}

my $query = '';
if (scalar @query != 0) {
    if (scalar @query > 1) {
        for (@query) {
            $query .= ("--query $_ ");
        }
    }
    elsif (scalar @query == 1) {
        $query = "--query $query[0]";
    }
}

my $print_peco = "-print | peco $query";
$print_peco = '-print 2>/dev/null' if $dump == 1;

if ($invert_dir) {
    if ($invert_file) {
        print `find . -maxdepth $depth $invert_dir $invert_file -iname '*' $print_peco`;
    }
    else {
        print `find . -maxdepth $depth $invert_dir -iname '*' $print_peco`;
    }
}
else {
    if ($invert_file) {
        print `find . -maxdepth $depth -iname '*' $invert_file $print_peco`;
    }
    else {
        print `find . -maxdepth $depth -iname '*' $print_peco`;
    }
}


__END__

=head1 SYNOPSIS

find-file [options] [FILE]

Options:

  -h --help            Show help
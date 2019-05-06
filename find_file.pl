#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Pod::Usage;


my $opts = {
    depth => 10,
    command => 'echo',
};

GetOptions(
    $opts => qw(
        depth=i
        command=s
        invert-file=s@
        invert-dir=s@
        help|h
    ),
);

my $query = $ARGV[0] // '';

pod2usage if ($opts->{help});


my $depth = $opts->{depth};
my $command = $opts->{command};

my @invert_file = @{$opts->{'invert-file'}} if $opts->{'invert-file'};
my @invert_dir = @{$opts->{'invert-dir'}} if $opts->{'invert-dir'};

my $invert_file = '';
if (scalar @invert_file > 0) {
    if (scalar @invert_file > 1) {
        for (@invert_file) {
            $invert_file .= ("! -iname '*$_*' ");
        }
    }
    else {
        $invert_file = "! -iname '*$invert_file[0]*'";
    }
}

my $invert_dir = '';
if (scalar @invert_dir > 0) {
    if (scalar @invert_dir > 1) {
        for (@invert_dir) {
            $invert_dir .= ("! -path '*/*$_*' ");
        }
    }
    else {
        $invert_dir = "! -path '*/*$invert_dir[0]*'";
    }
}

$query = '--query '.$query if $query;

my $selected = `
    files=\$(find . -maxdepth $depth $invert_dir $invert_file -iname '*')
    for i in exit \$files ; do echo \$i; done | peco $query | tr -d "\n"
`;

exit if $selected eq 'exit';

print `$command $selected` if $selected;


__END__
=head1 SYNOPSIS

find-file [options] [FILE]

Options:

  -h --help            Show help
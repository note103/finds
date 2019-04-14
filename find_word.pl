#!/usr/bin/env perl
use strict;
use warnings;
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


my $invert_dir = '';
if ($opts->{'invert-dir'}) {
    my @invert_dir = @{$opts->{'invert-dir'}};
    $invert_dir = join ' --ignore-dir ', @invert_dir;
    $invert_dir = '--ignore-dir '.$invert_dir;
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


__END__

=head1 SYNOPSIS

find-word [options] [FILE]

Options:

  -h --help            Show help

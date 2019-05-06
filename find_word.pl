#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Pod::Usage;


# デフォルト引数を設定
my $opts = {
    depth => 10,
    command => 'echo',
};

GetOptions(
    $opts => qw(
        depth|d=i
        command|c=s
        invert-dir|v=s@
        unrestricted|u
        help|h
    ),
);

pod2usage if ($opts->{help});

my $query = $ARGV[0] // '';

# 検索語句が未入力なら終了
unless ($query) {
    say "Input a query.";
    exit;
}

# 検索対象外にするディレクトリを指定
my $invert_dir = '';
if ($opts->{'invert-dir'}) {
    my @invert_dir = @{$opts->{'invert-dir'}};
    $invert_dir = join ' --ignore-dir ', @invert_dir;
    $invert_dir = '--ignore-dir '.$invert_dir;
}

# Agがデフォルトで弾いている不可視ファイル等を検索対象に含める
my $unrestricted = '';
if ($opts->{unrestricted}) {
    $unrestricted = '-u';
}

# 対象階層の指示があれば反映
my $depth = $opts->{depth};

# 検索クエリの作成
my $search = "ag --depth $depth $unrestricted $invert_dir $query";

# pecoに渡す
my $selected = `$search | peco`;

exit if $selected eq '';

# パス以外の要素をカット
$selected =~ s/\A(.+?):\d+.*/$1/;

my $command = $opts->{command};

print `$command $selected`;


__END__
=head1 SYNOPSIS

$ perl find-word.pl [options]

Options:

  -c --command          コマンド指定（デフォルトはecho）
  -d --depth            階層指定（デフォルトは10）
  -h --help             ヘルプ
  -u --unrestricted     不可視ファイル等を検索対象に含める
  -v --invert-dir       検索対象外ディレクトリを指定（複数可）

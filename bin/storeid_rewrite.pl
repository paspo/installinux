#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use utf8;

my %urls;
my $dir = '/etc/installinux/mirrors';

opendir (DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./);
    open (my $data, '<', $dir . '/' . $file) || die "Error: $!\n";
    while (my $line = <$data>) {
        chomp $line;
        $line =~ s/\R//g;
        next if ($line =~ m/^\s*#?$/);
        my($mirror_url, $redir_url) = split("\t", $line);
        $urls{$mirror_url} = $redir_url;
    }
}
closedir(DIR);

$| = 1;
while (<>) {
    chomp;
    my @X = split(" ");
    my $a = $X[0];
    my $url = $X[1];
    my $new_URL = $url;

    while( my( $key, $value ) = each %urls ){
        if (index($url, $key) != -1) {
            $new_URL =~ s/$key/$value/g;
        }
    }

    print "$a OK store-id=$new_URL\n";
}

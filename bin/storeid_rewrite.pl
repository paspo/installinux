#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use utf8;

my @rules;
my $dir = '/etc/squid3/storeid';

opendir (DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./);
    open (my $data, '<', $dir . '/' . $file) or die "Error: $!\n";
    while (<$data>) {
        chomp;
		if (/^\s*([^\t]+?)\s*\t+\s*([^\t]+?)\s*$/) {
        	push(@rules, [qr/$1/, $2]);
        } else {
        	print STDERR "$0: Parse error in $ARGV[0] (line $.)\n";
        }
    }
}
closedir(DIR);

print STDERR "$0: loaded " . scalar @rules . " rules\n";

$| = 1;
URL: while (<STDIN>) {
    chomp;
    my @X = split(" ");
    my $a = $X[0];
	my $url = $X[1];

    foreach my $rule (@rules) {
        if (my @match = $url =~ /$rule->[0]/) {
            print STDERR "$0 [$a]: rewriting for: $url \n";
            my $new_url = $rule->[1];
			for (my $i=1; $i<=scalar(@match); $i++) {
            	$new_url =~ s/\$$i/$match[$i-1]/g;
            }
            print "$a OK store-id=$new_url\n";
            next URL;
    	}
    }

    print "$a OK store-id=$url\n";
}

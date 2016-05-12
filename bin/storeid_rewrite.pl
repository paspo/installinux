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
    open (my $data, '<', $dir . '/' . $file) || die "Error: $!\n";
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

URL: while (<STDIN>) {
    chomp;
    my @X = split(" ");
    my $a = $X[0];
	$_ = $X[1];
    my $new_URL = $X[1];

    foreach my $rule (@rules) {
        if (my @match = /$rule->[0]/) {
            $_ = $rule->[1];
			for (my $i=1; $i<=scalar(@match); $i++) {
            	s/\$$i/$match[$i-1]/g;
            }
            print "$a OK store-id=$_\n";
            next URL;
    	}
    }

    print "$a OK store-id=$new_URL\n";
}

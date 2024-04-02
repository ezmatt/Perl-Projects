#!/usr/bin/perl
# glob.plx
use warnings;
use strict;

use Data::Dumper;

use lib "Modules";
use Handbrake;
use Try::Tiny;

my $replace_folder = "F:\\Kids";

my $directory = "C:/Users/Salvage/Videos/Handbrake";

my @files = glob($directory."/*");
my %files_to_convert = ();

#die Dumper \@files;

foreach my $movie (@files) {
	my $rc = Handbrake::copy_files_back($movie, $replace_folder);
}

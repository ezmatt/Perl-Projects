#!/usr/bin/perl
# glob.plx
use warnings;
use strict;

use Data::Dumper;

use lib "Modules";
use Handbrake;
use Try::Tiny;

#my $directory = "F:/Movies";
my $directory = "F:/Luke";

my @files = glob($directory."/*");
my %files_to_convert = ();

foreach my $movie_directory (@files) {
	next unless ( -d $movie_directory );
	#print "Movie: ".$movie_directory."\n";
	opendir DH, $movie_directory or die "Couldn't open the directory: $!";
	while (my $file_name = readdir(DH)) {
		# Skip system files
		next if ($file_name eq "." or $file_name eq "..");
		
		# Skip unless the file is over 500mb
		#next if (-s $movie_directory."/".$file_name < 500000000);
		
		# Skip unless the file is a movie file
		my $extension = "";
		if ( $file_name =~ m/^.*\.(.*)$/) {
			$extension = $1;
		}
		next unless ( $extension =~ m/mkv|m4v|avi|wmv|mp4|iso/i );
		
		# Skip if file is below 3 gb
		next if (-s $movie_directory."/".$file_name < 3200000000);
		
		# Place large files into a hash
		$files_to_convert{$movie_directory} = $file_name;
		
		#print "  File: ".$file_name, " "x (70-length($file_name));
		#print -s $movie_directory."/".$file_name;
		#print "\n\n";
	}
	
	#exit;
}

die Dumper sort keys %files_to_convert;

foreach my $movie ( sort keys %files_to_convert ) {
	

	my $rc = Handbrake::convert_file($movie, $files_to_convert{$movie});

	### delete the old file
	unlink $movie."/".$files_to_convert{$movie}.".old";
	
	#exit;
}

#print Dumper(\%files_to_convert);
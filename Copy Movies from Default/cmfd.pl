#!/usr/bin/perl -w
# glob.plx
use warnings;
use strict;

use Data::Dumper;
use Try::Tiny;
use File::Path;
use Getopt::Long qw(GetOptions);

use lib "Modules";
use Handbrake;

my %args;
GetOptions('test' => \$args{'test'});

my %directories = (
	"C:/Users/Salvage/Documents/sab/Complete/Movies"	=> "E:/Adult",
	"C:/Users/Salvage/Documents/sab/Complete/Kids"		=> "E:/Kids",
);	

my @extensions = (
	'mkv',
	'm4v',
	'avi',
	'wmv',
	'mp4',
	'iso',
	'm2ts',
	'mx'
);

foreach my $directory ( keys %directories ) {
	#print Dumper $directory;
	my @files = glob($directory."/*");
	my %files_to_convert = ();
	my $destination_folder = $directories{$directory};
	
	#print Dumper \@files;

	print "\n\nSearching for movie directories in $directory to move to $destination_folder\n\n";
	
	foreach my $movie_directory (@files) {
		next unless ( -d $movie_directory );
		print "Movie: ".$movie_directory."\n";
		
		### Get actual movie name
		my $movie_name = $movie_directory;
		if ( $movie_name =~ /.*\/(.*)$/i ) {
			$movie_name = $1;
		}
		$movie_name =~ s/[._-]+/ /g;
		
		if ( $movie_name =~ /^(.*?)\s*\(*([12][0-9][0-9][0-9]).*$/i ) {
			$movie_name = $1." (".$2.")";
		}
		
		opendir DH, $movie_directory or die "Couldn't open the directory: $!";
		while (my $file_name = readdir(DH)) {
			# Skip system files
			next if ($file_name eq "." or $file_name eq "..");
			
			# Skip if directory
			next if ( -d $file_name );
			
			# Skip unless the file is a movie file
			my $extension = "";
			if ( $file_name =~ m/^.*\.(.*)$/) {
				$extension = $1;
			}
			
			if ( $extension ~~ @extensions ) {
			
				my $size = 0;
				$size = -s $movie_directory."/".$file_name;
				
				# Place files into a hash
				$files_to_convert{$movie_directory."\\".$file_name}{'movie_name'}		= $movie_name;
				$files_to_convert{$movie_directory."\\".$file_name}{'ext'}				= $extension;
				$files_to_convert{$movie_directory."\\".$file_name}{'size'}				= $size;
				$files_to_convert{$movie_directory."\\".$file_name}{'movie_dir'}		= $movie_directory;
			}
			
		}
		
		### Testing
		#exit if ($args{'test'});
	}

	foreach my $input_file ( sort keys %files_to_convert ) {
		
		my $rc = 0;
		
		print Dumper \%files_to_convert if ($args{'test'});

		# Skip if file is a trailer or sample
		next if ( $files_to_convert{$input_file}{'size'} < 400000000);
		
#		if ( $files_to_convert{$input_file}{'size'} > 10000000000 ) {
#			$rc = Handbrake::convert_file($input_file, $files_to_convert{$input_file}, $destination_folder);
#		}
#		else {
		unless ( $args{'test'} ) {
			$rc = Handbrake::move_file($input_file, $files_to_convert{$input_file}, $destination_folder);
			unless ( $rc ) {
				rmtree($files_to_convert{$input_file}{'movie_dir'}, {'safe' => 1,});
				print "Remove tree return Code: $!";
				#die "\n\n*****************************************\nFailed to remove directory: ".$files_to_convert{$input_file}{'movie_dir'}."\n\n$!" if ($!);
			}
		}
	}
}
#print Dumper(\%files_to_convert);

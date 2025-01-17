package Handbrake;

use strict;
use warnings;

use Data::Dumper;
use Try::Tiny;

my %failed_files = ();

sub convert_file {
	my($input_file, $movie_info, $ouptut_directory) = @_;
	
	my $cmd = "\"C:\\Program Files\\Handbrake\\HandBrakeCLI.exe\" -i \"";
	if (-e $input_file) {
		my $movie_name = $movie_info->{'movie_name'};
		my $ouptut_file = $ouptut_directory."\\".$movie_name;
		
		### Check to see if destination folder exists
		unless (-e $ouptut_file and -d $ouptut_file) {
			 mkdir($ouptut_file);
		}
		$ouptut_file .= "\\".$movie_name.'.m4v';

		# Very Fast 1080p30
		# Fast 1080p30
		# Very Fast 720p30
		# Fast 720p30
		# Normal
		# Chromecast 1080p30 Surround
		$cmd .= $input_file."\" -o \"".$ouptut_file."\" -Z \"Normal\"";
		
		print "\n\nConverting and moving movie:\n\n";
		print "\t".$cmd."\n\n";
		
		my $rc = 0;
		try {
			$rc = system $cmd;
		}
		catch {
			warn "Got a die: $_";
			$rc = 1;
		};	
		return $rc;
	}
	else {
		return 'file does not exist';
	}
	
}

sub move_file {
	my($input_file, $movie_info, $ouptut_directory) = @_;
	
	my $cmd = "move \"";
	if (-e $input_file) {
		
		my $movie_name			= $movie_info->{'movie_name'};
		my $ext					= $movie_info->{'ext'};
		
		my $ouptut_file = $ouptut_directory."/".$movie_name;
		
		mkdir $ouptut_file unless ( -e $ouptut_file and -d $ouptut_file);
		
		$cmd .= $input_file."\" \"".$ouptut_file."/".$movie_name.".".$ext."\"";
		
		print "\n\nMoving movie:\n\n";
		print "\t".$cmd."\n\n";
		
		my $rc = 0;
		try {
			$rc = system $cmd;
		}
		catch {
			warn "Got a die: $_";
			$rc = 1;
		};
		
		return $rc;
	}
}

1;  
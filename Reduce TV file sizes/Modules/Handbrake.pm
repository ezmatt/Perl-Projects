package Handbrake;

use strict;
use warnings;

use Data::Dumper;
use Try::Tiny;
use File::Copy;

my %failed_files = ();

my $test_mode = 0;

sub convert_file {
	my($source_video, $target_video) = @_;
	
	#die Dumper $source_video, $target_video;
	
	my $cmd = "";
	my $input_file = $source_video->{'full_video_name'};
	#die Dumper $input_file;
	if (-e $input_file) {
		my $ouptut_file = $target_video->{'full_video_name'};
        $ouptut_file =~ s/\..*$//;

		#die Dumper $ouptut_file;

		$ouptut_file .= '.m4v.new';

		$target_video->{'full_video_name'} = $ouptut_file;

		### check to see if output file exists
		return 0 if (-e $ouptut_file);

		$cmd = "\"C:\\Program Files\\Handbrake\\HandBrakeCLI.exe\" --preset-import-file \"C:/Users/Salvage/AppData/Roaming/HandBrake/presets.json\" -i \"".$input_file."\" -o \"".$ouptut_file."\" -Z \"Fast 720p30\"";

		print "\n\nCommand:\n".$cmd."\n\n";
		#<STDIN>;

		my $rc = 0;

		$rc = system($cmd);



        return $rc;
	}

}

sub copy_files_back {
	my($converted_movie, $replace_folder) = @_;
	
	my $cmd = "";
	my $old_directory	= $replace_folder;
	
	if ( $converted_movie =~ m/^.*\/(.*)\..*$/) {
		$old_directory .="\\".$1;
	}
	
	my $old_file		= $old_directory;

	### Check folder exists and that a vallid movie file exists on that folder
	next unless ( -d $old_directory );
	opendir DH, $old_directory or die "Couldn't open the directory $old_directory: $!";
	while (my $file_name = readdir(DH)) {
		# Skip system files
		next if ($file_name eq "." or $file_name eq "..");
		
		# Skip unless the file is the movie file
		my $extension = "";
		if ( $file_name =~ m/^.*\.(.*)$/) {
			$extension = $1;
		}
		next unless ( $extension =~ m/mkv|m4v|avi|wmv|mp4|iso/i );
		
		$old_file .= "\\".$file_name;
		#die Dumper $old_file;
	
		if (-e $old_file) {
			### Rename old file
			print "\nRenaming file: \n$old_file\n to \n$old_file.old\n";
			<STDIN> if ( $test_mode );
			rename $old_file, $old_file."\.old" or die "Couldn't rename file: $old_file $!";
			
			### Move reduced file back to F:
			print "\nMoving file: \n$converted_movie\n to \n$old_file\n";
			<STDIN> if ( $test_mode );
			move ($converted_movie, $old_file) or die "Couldn't move file $converted_movie to $old_file: $!";

			### Move reduced file back to F:
			print "\nDeleting old file: $old_file.old\n";
			<STDIN> if ( $test_mode );
			unlink ( $old_file."\.old" ) if ( -e $old_file."\.old" ) or die "Could not delete file $old_file.old: $!";
			
		}
	}

}

1;  

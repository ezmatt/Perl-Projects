#!/usr/bin/perl
# glob.plx
use warnings;
use strict;

use Data::Dumper;

use lib "Modules";
use Handbrake;
use Try::Tiny;

#my $directory = "F:/Movies";
my $directory = "F:/TV";

my @files = glob($directory."/*");
my %files_to_convert = ();

foreach my $tv_directory (@files) {
	next unless ( -d $tv_directory );
	print "Tv Show: ".$tv_directory."\n";
	opendir DH, $tv_directory or die "Couldn't open the directory: $!";
	### Loop through the seasons
	while (my $season_directory = readdir(DH)) {
		# Only interested in Season directories
		next unless ($season_directory =~ /season/i);
		my $tv_season = $tv_directory.'/'.$season_directory;

		opendir DH2, $tv_season or die "Couldn't open the directory: $!";
        ### Loop through the seasons
        while (my $video_file = readdir(DH2)) {
            my $full_video_name = $tv_season.'/'.$video_file;
            # Skip system files
            next if ($video_file eq "." or $video_file eq "..");

            my $extension = "";
            if ( $video_file =~ m/^.*\.(.*)$/) {
                $extension = $1;
            }
            next unless ( $extension =~ m/mkv|m4v|avi|wmv|mp4|iso/i );

            # Skip if file is below 700mb
            next if (-s $full_video_name < 700000000);

            #print "Video file: ".$video_file."\n";


            # Place large files into a hash
            $files_to_convert{$full_video_name} = {
                'path'              => $tv_season,
                'file_name'         => $video_file,
                'full_video_name'   => $full_video_name,
            };
		}
	}
	
}

print "\n\n";
print "Converting tv shows to lower file size";
print "\n";
#die Dumper %files_to_convert;

foreach my $tv_show_and_season ( sort keys %files_to_convert ) {
	
	print "File: ".$files_to_convert{$tv_show_and_season}{'full_video_name'}."\n\n";

	### Edit this bit for different functionality
    my $target_video = {
        'path'              => $files_to_convert{$tv_show_and_season}{'path'},
        'file_name'         => $files_to_convert{$tv_show_and_season}{'file_name'},
        'full_video_name'   => $files_to_convert{$tv_show_and_season}{'full_video_name'},
    };

	my $rc = Handbrake::convert_file($files_to_convert{$tv_show_and_season}, $target_video);

	### delete the old file and rename new file
	unless ($rc) {
        my $ouput_file = $target_video->{'full_video_name'};
        $ouput_file =~ s/\.new//i;
        #die Dumper $files_to_convert{$tv_show_and_season}{'full_video_name'}, $target_video->{'full_video_name'}, $ouput_file;

        print "Deleting old file: ".$files_to_convert{$tv_show_and_season}{'full_video_name'}."\n";
        ### delete old file
        unlink $files_to_convert{$tv_show_and_season}{'full_video_name'};

        print "Renaming: ".$target_video->{'full_video_name'}." to: ".$ouput_file."\n";
        ### rename new file
        rename $target_video->{'full_video_name'}, $ouput_file || die "Failed to rename file";

    }
	
    exit;
}

#print Dumper(\%files_to_convert);

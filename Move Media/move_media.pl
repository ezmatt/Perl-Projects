#!/usr/bin/perl
# glob.plx
use warnings;
use strict;

use Data::Dumper;
use File::Find 'find';
use File::Copy 'move';
use File::Path qw(make_path remove_tree);
use File::Basename;
use Image::ExifTool;

# use lib "Modules";
use Try::Tiny;

### Hash array of folders and files
my %image_files = ();
my $image_types = undef;
my $exifTool = new Image::ExifTool;

### Media Folders
my $media_folder = {
#    "E:\\Media\\Fix"	=> 1,
	"E:\\Media\\iphone"	=> 1,
};

### Destination
my $destination_folder = "E:\\Media\\";

my $months = {
	1	=> 'January',
	2	=> 'February',
	3	=> 'March',
	4	=> 'April',
	5	=> 'May',
	6	=> 'June',
	7	=> 'July',
	8	=> 'August',
	9	=> 'September',
	10	=> 'October',
	11	=> 'November',
	12	=> 'December',
};

### which file types do we want to move
my %file_types = (
	'MOV'	=>	"Videos",
	'MP4'	=>	"Videos",
	'M4V'	=>	"Videos",
    'PNG'	=>	"Pictures",
	'JPEG'	=>	"Pictures",
	'JPG'	=>	"Pictures",
);

### Get all files from each media directory nominated and each sub-directory beneath
foreach my $folder ( keys %{$media_folder}) {
    find(\&wanted, $folder);
}

die Dumper $image_types if $image_types;

foreach my $image (keys %image_files) {
	my $m_time = (stat ($image))[9];
	my @mtime = localtime((stat ($image))[9]);
	my $month = $months->{$mtime[4]+1};
	my $year = $mtime[5]+1900;
	
	my $info = $exifTool->ImageInfo($image);
	
	#print Dumper $image, $info->{'CreateDate'}, $image_files{$image};# if ($image_files{$image} eq "Videos");
	print Dumper $image, $info if ($image_files{$image} eq "Pictures");
	#next;
	
	if ( exists $info->{'CreateDate'} and $info->{'CreateDate'}) {
		my ($date, $time) = split(' ', $info->{'CreateDate'});
		my $month_number = undef;
		($year, $month_number) = split (":", $date);
		$month_number =~ s/^0//;
		#print Dumper $month_number;
		$month = $months->{$month_number};
	}

	if ( exists $info->{'Creationdate'} and $info->{'Creationdate'}) {
		my ($date, $time) = split('T', $info->{'Creationdate'});
		my $month_number = undef;
		($year, $month_number) = split ("-", $date);
		$month_number =~ s/^0//;
		print Dumper $month_number;
		$month = $months->{$month_number};
	}

	print $year, $month, "\n";
	#next;
	my $dir = $destination_folder.$image_files{$image}."\\".$year."\\".$month;
    #die Dumper $info->{'Creationdate'}, $dir, $image;
	unless(-e $dir ) {
        make_path($dir) or die "Could not create path: $dir $!\n\n"
    }
	print "Moving file: $image \nto $dir\n";
	move($image, $dir) or die "The move operation failed: $!"; 
}

sub wanted {

    return unless -f;
	my $vid_or_img = undef;
    if ($_ =~ m/\.(.*)$/i) {
		### Use this to work out which file types are there
        # $image_types->{uc$1} += 1;
        return unless exists $file_types{uc($1)};
        $vid_or_img = $file_types{uc($1)};
	}
	$image_files{$File::Find::name} = $vid_or_img;
}
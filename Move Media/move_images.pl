#!/usr/bin/perl
# glob.plx
use warnings;
use strict;

use Data::Dumper;
use File::Find 'find';
use File::Copy 'move';
use File::Path qw(make_path remove_tree);
use File::Basename;

# use lib "Modules";
use Try::Tiny;

### Hash array of folders and files
my %image_files = ();

### Media Folders
my $media_folder = "E:\\Videos\\Home Videos";

### Destination
my $destination_folder = "E:\\Media\\Pictures";

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
	'PNG'	=>	1,
	'JPEG'	=>	1,
	'JPG'	=>	1,
);

find(\&wanted, $media_folder);

#die Dumper \%image_files;

foreach my $image (keys %image_files) {
 	#print $image."\n";
	my $m_time = (stat ($image))[9];
	my @mtime = localtime((stat ($image))[9]);
	my $month = $months->{$mtime[4]+1};
	my $year = $mtime[5]+1900;
	
	#print Dumper $month, $year;
    #print "Last change:\t" . scalar localtime($m_time) . "\n";
	my $dir = $destination_folder."\\".$year."\\".$month;
	#print "Directory: $dir\n\n";
	unless(-e $dir ) {
        make_path($dir) or die "Could not create path: $dir $!\n\n"
    }
	print "Moving file: $image \nto $dir\n";
	move($image, $dir) or die "The move operation failed: $!"; 
	#die;
}

sub wanted {

    return unless -f;
	if ($_ =~ m/\.(.*)$/i) {
		return unless exists $file_types{uc($1)};
	}
	$image_files{$File::Find::name} = 1;
    #print $File::Find::name, "\n";
}
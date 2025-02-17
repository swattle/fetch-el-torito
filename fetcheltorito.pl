#!/usr/bin/perl

use Getopt::Std;

#
# fetcheltorito.pl: a bootimage extractor
# Script that will extract the first El Torito bootimage from a
# bootable CD image
# Sai Vittal B 06/2020
# hello@saivittalb.com
# License: GPL
#
$utilVersion="1.0";
#
# For information on El Torito see 
# http://en.wikipedia.org/wiki/El_torito

$vSecSize=512;
$secSize=2048;
$ret=undef;$version=undef;$opt_h=undef;$loadSegment=undef;$systemType=undef;

#
# Read a particular sector from a file
# sector counting starts at 0, not 1
#
sub getSector{
   my ($secNum, $secCount, $file)=@_;
   my ($sec, $count);

   open(FILE, "<:raw", $file) || die "Cannot open \"$file\" \n";

   seek(FILE, $secNum*$secSize, 0);
   $count=read(FILE, $sec, $vSecSize*$secCount, 0) ;
   if( $count != $vSecSize*$secCount ){
       warn "Error reading from file \"$file\"\n";
   }
   close(FILE);

   return($sec);
}


#
# Write eltorito data into a file
#
sub writeOutputFile{
   my($name)=shift;
   my($value)=shift;

   open(OUT, ">:raw", $name)|| die "$0: Cannot open outputfile \"$name\" for writing. Stop.";
   print OUT $value;
   close(OUT);
}


#
# Usage
#
sub usage{
	warn "\n$0 [-hv] [-o outputfilename] cd-image \n",
	    "Script will try to extract an El Torito image from a \n",
	    "bootable CD (or cd-image) given by <cd-image> and write \n",
	    "the data extracted to STDOUT or to a file.\n",
	    "   -h:        This help. \n",
	    "   -v:        Print version of script and exit.\n",
	    "   -o <file>: Write extracted data to file <file> instead of STDOUT.\n",
	    "\n\n";
	exit 0;    
}


# ---------------------------------------------------------------------
$ret=getopts('hvo:');
 
if( defined($opt_v) ){
 	warn "Version: $utilVersion \n";
	exit 0;
}

if( defined($opt_h) || $#ARGV <0 ){
         usage(0);
}	 

if( defined($opt_o) ){
   $outputFilename="$opt_o";
}
	 
$imageFile=$ARGV[0];

if( ! -r $imageFile ){
	die "Cannot read image/device \"$imageFile\". Aborting\n";
}

#
# Read Sector 17 from CD which should contain a Boot Record Volume
# descriptor. This descriptor contains at its start the text ($isoIdent)
# CD001     and ($toritoSpec)
# EL TORITO SPECIFICATION
# see http://www.cdpage.com/Compact_Disc_Variations/eltoritoi.html
# for details
#

$sector=getSector(17, 1, $imageFile );
($boot, $isoIdent, $version, $toritoSpec,
 	$unUsed, $bootP)= unpack( "Ca5CA32A32V", $sector );

if( $isoIdent ne "CD001" || $toritoSpec ne "EL TORITO SPECIFICATION" ){
	die "This data image does not seem to be a bootable CD-image\n";
}	

#
# Now fetch the sector of the booting catalog 
#
$sector=getSector($bootP, 1, $imageFile );

print STDERR "Booting catalog starts at sector: $bootP \n";

# The first 32 bytes of this sector contains the validation entry for a
# boot. The first byte has to be 01, the next byte determines the
# architecture the image is designed for, where 00 is i86, 01 is PowerPC
# and 02 is Mac. More data give info about manufacturer, etc.  The 
# final two bytes must contain 0x55 and 0xAA respectively (as 
# defined by the El Torito standard).

$validateEntry=substr($sector, 0, 32);

($header, $platform, $unUsed, $manufact, $unUsed, $five, $aa)=
               unpack( "CCvA24vCC", $validateEntry);

if( $header != 1 || $five != 0x55 || $aa != 0xaa ){
	die "Invalid Validation Entry on image \n";
}

print STDERR "Manufacturer of CD: $manufact\n";
print STDERR "Image architecture: ";
print STDERR "x86" if( $platform == 0 );
print STDERR "PowerPC" if( $platform == 1 );
print STDERR "Mac" if( $platform == 2 );
print STDERR "unknown ($platform)" if( $platform > 2 );
print STDERR "\n";

#
# Now we examine the initial/defaultentry which follows the validate
# entry and has a size of 32 bytes. 

$initialEntry=substr($sector, 32, 32);

($boot, $media, $loadSegment, $systemType, $unUsed, 
       $sCount, $imgStart, $unUsed)=unpack( "CCvCCvVC", $initialEntry);

if( $boot != 0x88 ){
	die "Boot indicator in Initial/Default-Entry is not 0x88. CD is not bootable. \n";
}    

print STDERR "Boot media type is: ";
if( $media == 0 ){
	print STDERR "no emulation";
	$count=0;
}
if( $media == 1 ){
	print STDERR "1.2meg floppy";
        $count=1200*1024/$vSecSize;  
}
if( $media == 2 ){
	print STDERR "1.44meg floppy";
        $count=1440*1024/$vSecSize;  
}
if( $media == 3 ){
	print STDERR "2.88meg floppy";
        $count=2880*1024/$vSecSize;  
}
if( $media == 4 ){
	print STDERR "harddisk";
	$MBR=getSector($imgStart, 1, $imageFile );
	$partition1=substr($MBR, 446, 16);
	($unUsed, $firstSector, $partitionSize) = unpack( "A8VV", $partition1);
	$count=$firstSector + $partitionSize;
}
print STDERR "\n";

# Only use the internal sector counter if the real size is unknown
# ($count==0)
$cnt=$count==0?$sCount:$count;

print STDERR "El Torito image starts at sector $imgStart and has $cnt sector(s) of $vSecSize Bytes\n";

# We are there:
# Now read the bootimage to stdout
$image=getSector($imgStart, $cnt, $imageFile);

if( length($outputFilename) ){
   writeOutputFile($outputFilename, $image);
   print STDERR "\nImage has been written to file \"$outputFilename\".\n";
}else{
   print "$image";
   print STDERR "Image has been written to stdout ....\n"; 
}

#!/usr/bin/perl
# Copyright (c) 2000 Flavio Glock <fglock@pucrs.br>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

=head1 NAME

Archive::Parity - makes parity file; recover files.

=head1 USAGE

use Parity;

to make a parity file from a list of files:
 Parity::do_parity (out_filename, filename1, filename2, filename3);

to recover a lost file:
use the same command, placing the lost file name in front of the list:
 Parity::do_parity (filename1, out_filename, filename2, filename3);

The parity file must have a ".par" extension.

=head1 TODO

object interface.
register module Archive::Parity.
try not to overwrite outfile; do not allow repeated filenames.
save filename;
check errors.
memory operation for small files.
make, test. Test with different chunk sizes.
check_parity just to check if everything is ok.

=head1 AUTHOR

Flávio Soibelmann Glock - fglock@pucrs.br

=cut

use strict;
no strict "refs"; 	# allow this ---> open ($file, $filename);
package Parity;

### DEFAULTS

our $VERSION = '0.05';
our $LENGTH = 65000;
our $EXTENSION = '.par';
our $DEBUG = 0;

### globals

our $result;
our $number_len;
our $recover;
our @FILE;
our $num_files;
our $OFFSET;
our $size_written;
our $outfile;
our @file_name;
our @file_size;
our $result_size;
our $filename;
# our $FILE;
our $num_read;

### SUBS

sub is_parity_file {
	return ($_[0] =~ /\Q$EXTENSION\E$/i) ? 1 : 0;
}

sub read_chunk {
	my ($filename, $size);
	
	$result = '';
	foreach my $i (0 .. $num_files) {
		$filename = $file_name[$i];
		# $FILE =     $FILE[$i];
		$size =     $file_size[$i];
		
		# print "FILE: $FILE[$i] $filename \t$size\n";
		
		$num_read = read $FILE[$i], $a, $LENGTH;
		$size = $size . (' ' x ($number_len - length($size)));
		if ($OFFSET == 0) {
			if (not is_parity_file($filename)) {
				$a = $size . $a;
				# print " SIZE $size . $a ";
				$num_read += $number_len;
			}
			else {
				$num_read += read $FILE[$i], $b, $number_len;
				$a .= $b;
			}
		}
		# print " [ read $filename $num_read $size ", length($a), " ] ", $a, "\n", "-" x 20, "\n";
		$result ^= "$a";
		# print "RESULT: ", $result, "\n", "-" x 20, "\n";
	}
	$OFFSET++;
} # end: read_chunk


sub do_parity {
	### INIT
	
	$number_len = 12;
	$recover = 0;
	@FILE = ();
	@file_name = ();
	@file_size = ();
	$num_files = 0;
	$OFFSET = 0;
	$size_written = 0;
	
	$outfile = shift or return "missing outfile name ";
	print "Out file: $outfile\n" if $DEBUG;
	while ($filename = shift) {
		print "In file: $filename\n" if $DEBUG;
		push @file_name, $filename;
		return "$filename does not exist" unless -e $filename;
	}
	$num_files = $#file_name;
	
	foreach (0 .. $num_files) {
		$filename = $file_name[$_];
		if (is_parity_file($filename)) {
			$recover = 1;
		}
		$file_size[$_] = -s $filename;
		$FILE[$_] = "FILE$_";
		open ($FILE[$_], $filename) or return "can't open $filename";
		binmode ($FILE[$_]);
	}
	open (OUT_FILE, ">$outfile") or return "can't open $outfile";
	binmode (OUT_FILE);
	
	## END: INIT
	
	read_chunk;
	if ($recover) {
		print "Recover \n" if $DEBUG;
		$result_size = substr($result, 0, $number_len);
		print "Size = $result_size\n" if $DEBUG;
		$result = substr($result, $number_len, $LENGTH);
	}
	else {
		print "Make \n" if $DEBUG;
		$result_size = 1e15;
	}
	
	if (($size_written + length($result)) > $result_size) {
		$result = substr($result, 0, $result_size - $size_written);
	}
	print OUT_FILE $result;
	$size_written += length($result);
	
	## LOOP
	
	do {
		read_chunk;
		if (($size_written + length($result)) > $result_size) {
			$result = substr($result, 0, $result_size - $size_written);
		}
		print OUT_FILE $result;
		$size_written += length($result);
	} until length($result) == 0;
	
	## END: LOOP
	
	close (OUT_FILE);
	@FILE = ();	# close files
	
	return 0;
}

1;

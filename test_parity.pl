#!/usr/bin/perl
# Copyright (c) 2000 Flavio Glock <fglock@pucrs.br>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

# test_parity.pl

use Parity;

my $DEBUG = 0;
$Parity::DEBUG = $DEBUG;

my $a;

# init

my @test_file = ("test1_.txt", "test2_.txt", "test_.par");
my @test_data = ("a c e g i", " b d f h ","ABCDEFGHI");
my $data_len = length($test_data[0]);

sub test {

# create test files
foreach (0 .. $#test_file-1) { 
	print "Create $test_file[$_] = \"$test_data[$_]\"\n" if $DEBUG;
	open (FILE, ">$test_file[$_]");
	print FILE $test_data[$_];
	close (FILE);
}

# erase parity file, if any
unlink $test_file[-1];

# do test

# make parity file
print "do_parity ", join(", ", ($test_file[-1], @test_file[0..$#test_file-1])),"\n" if $DEBUG;
$err = Parity::do_parity ($test_file[-1], @test_file[0..$#test_file-1]);
if ($err) {
	die $err;
}

# destroy a file
unlink $test_file[0];

# recover lost file
print "do_parity ", join(", ", ($test_file[0], @test_file[1..$#test_file])),"\n" if $DEBUG;
$err = Parity::do_parity ($test_file[0], @test_file[1..$#test_file]);
if ($err) {
	die $err;
}

# check result
open (FILE, "<$test_file[0]");
$a = <FILE>;
close (FILE);
print "not " if $a ne $test_data[0];
print "ok\n";

} # end sub test


# just test
test;

# test with a small chunk size
$Parity::LENGTH = 2;
test;

# remove test files
foreach (@test_file) { unlink $_ }

1;



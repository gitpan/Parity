package Text::Parity;
require 5.001;
require Exporter;

# Documentation in pod format after __END__ token. See Perl
# man pages to convert pod format to man, html and other formats.

$Version = 1.1; sub Version {$Version}
@ISA = qw(Exporter);
@EXPORT = qw( setEvenParity setOddParity showParity
	      EvenBytes OddBytes
	      isEvenParity isOddParity
	    );

$even_bits = "\0";
$odd_bits = "\200";
foreach (0 .. 7) {
    $even_bits .= $odd_bits;
    ($odd_bits = $even_bits) =~ tr/\0\200/\200\0/;
}

$codes = pack('C*', (0 .. 255));
($even_parity = $codes ^ $even_bits) =~ s/(\W)/sprintf('\%o', ord $1)/eg;
($odd_parity = $codes ^ $odd_bits) =~ s/(\W)/sprintf('\%o', ord $1)/eg;
($show_parity = $even_bits) =~ tr /\0\200/eo/;

$even_codes = '';
while ($even_bits =~ /\0/g) {
    $even_codes .= sprintf '\%o', (pos $even_bits) - 1;
}

eval <<EDQ;

    sub setEvenParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$even_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub setOddParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$odd_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub showParity {
	my(\@s) = \@_;
	foreach (\@s) {
	    tr/\\0-\\377/$show_parity/;
	}
	wantarray ? \@s : join '', \@s;
    }

    sub EvenBytes {
	my \$count = 0;
	foreach (\@_) {
	    \$count += tr/$even_codes//;
	}
	\$count;
    }

    sub OddBytes {
	my \$count = 0;
	foreach (\@_) {
	    \$count += tr/$even_codes//c;
	}
	\$count;
    }

EDQ
die $@ if $@;

sub isEvenParity {
    ! &OddBytes;
}

sub isOddParity {
    ! &EvenBytes;
}

1;

__END__

=head1 NAME

Text::Parity, setEvenParity, setOddParity, showParity, EvenBytes,
OddBytes, isEvenParity, isOddParity - parity handling

=head1 SYNOPSIS

    use Text::Parity;

=head1 DESCRIPTION

=over 8

=item setEvenParity LIST

Copies the elements of LIST to a new list and converts the new elements to
strings of bytes with even parity. In array context returns the new list.
In scalar context joins the elements of the new list into a single string
and returns the string.

=item setOddParity LIST

Does the same as the setEvenParity function, but converts to strings with
odd parity.

=item showParity LIST

Does the same as the setEvenParity function, but converts bytes with even
parity to 'e' and other bytes to 'o'.

=item EvenBytes LIST

Returns the number of even parity bytes in the elements of LIST.

=item OddBytes LIST

Returns the number of odd parity bytes in the elements of LIST.

=item isEvenParity LIST

Returns TRUE if the LIST contains no byte with odd parity, FALSE otherwise.

=item isOddParity LIST

Returns TRUE if the LIST contains no byte with even parity, FALSE otherwise.

=back

=head1 AUTHOR

Winfried Koenig <win@in.rhein-main.de>

 Copyright (c) 1995 Winfried Koenig. All rights reserved.
 This program is free software; you can redistribute it
 and/or modify it under the same terms as Perl itself.

=cut

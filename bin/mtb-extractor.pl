use Data::Dumper;

# headings should not have numbers
sub isHeading() {
    $l = $_[0];
    return 0 if /^\s*$/;
    return 1 unless /\d/;
    return 0;
}

sub unpackHeading() {
    my $l = $_[0];
    chomp $l;
    my @it = split /(\s\s+)/, $l;
    [ [@it], [ ( map { "a" . length($_) } @it ), "a100" ] ];

}

sub lrsplit() {
    local $l = $_[0];
    split /\s\s+/, $l;
}

sub aggregateHeading() {
    my @sections = @_;
    my @rtn      = ();
    my $runline  = '';
    foreach (@sections) {
        if ( $runline ne '' && /description|marital/i ) {
            push @rtn, $runline;
            $runline = '';
        }
        $runline .= $_;
    }
    push @rtn, $runline;
    return @rtn;
}

$newPage = 1;

$hasHeadings = 0;
while (<>) {
    chomp;
    next if /^\s*$/;
    if ( &isHeading($_) ) {
        @sectionHeadings = split /(description|marital)/i, $_;
        print Dumper ( { sections => \@sectionHeadings } );
        @headings = &aggregateHeading(@sectionHeadings);
        print Dumper( { aggh => \@headings } );
        $_           = ":" . $_ if /^\s/;    # poor man's break
        $hasHeadings = 1;
        @names       = split /\s\s+/, $_;

        @sections = ( [] x scalar(@headings) );
        print Dumper ( \@sections );

        # print Dumper ( \@names );
        next;
    }
    next unless $hasHeadings == 1;
    @values = split /\s\s+/, $_;

    # print Dumper( \@values );

    my %hash;
    @hash{@names} = @values;
    print Dumper ( \%hash );
}

exit;

while (<>) {

    # $newPage = 1 if /^/;
    if ( &isHeading($_) ) {
        $uh = ( &unpackHeading($_) );
        print Dumper($uh);
        my $unpk = join "", @{ $uh->[1] };
        print $unpk. $/;
        my $l2 = <>;
        chomp $l2;
        @w = unpack $unpk, $l2;
        map {
            printf Dumper( &lrsplit( $w[ ( 2 * $_ + 1 ) ] ) )

              # Dumper(
              # 						&lrsplit($w[ 1+2*$_]))
        } ( 0 .. ( scalar @w ) / 2 + 1 );

        # print Dumper(@w);

        # print Dumper([ (0..(length(@w)/2))]);
    }

}

exit;

# display first net pay
while (<>) {
    if (/Net Pay/) {
        $l = <>;
        print $l;
    }
}

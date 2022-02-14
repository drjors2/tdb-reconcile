use Data::Dumper;

# headings should not have numbers
$PAYCHECKLEDGERENTRY = q(
%s Paycheck MTB 
    ; PayStart :: %s 
    ; PayEnd ::  %s 
    ; ofxid :: %s-%s
    MTB:Hours                        MTBHRS -%s
    MTB:AR                              USD %s    

);

sub cvdateYmd {
    my ( $m, $d, $y ) = split /\//, $_[0];
    return join "-", $y, $m, $d;
}

# --------------------------------------------------------------------------------

while (<>) {
    chomp;
    if (/Company.*Pay Period Begin/) {
        $payPeriodLine = <>;
        chomp $payPeriodLine;
        @payPeriodTokens = split /\s\s+/, $payPeriodLine;

        # print Dumper ( \@payPeriodTokens );
        $ppBegin     = cvdateYmd( $payPeriodTokens[3] );
        $ppEnd       = cvdateYmd( $payPeriodTokens[4] );
        $ppCheckDate = cvdateYmd( $payPeriodTokens[5] );
    }

    if (/Net Pay/) {
        $netPayLine = <>;
        chomp $netPayLine;
        @netPayTokens = split /\s\s+/, $netPayLine;

        $grossPay = $netPayTokens[2];

        # print Dumper ( \@netPayTokens );
        $amt = $netPayTokens[-1];
        $hrs = $netPayTokens[1];
        $amt =~ s/,//g;
        $amt = $amt;

        # printf "%s : %s\n", $hrs, $amt;
        # printf $PAYCHECKLEDGERENTRY, $ppCheckDate,
        #   $ppBegin, $ppEnd,
        #   $ppBegin, $ppEnd,
        #   $hrs,     $amt;
        print join ",",
          ( $ppCheckDate, $ppBegin, $ppEnd, $hrs, $amt, $grossPay, $/ );

    }
}
exit;

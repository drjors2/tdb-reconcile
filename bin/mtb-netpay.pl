use Data::Dumper;

# headings should not have numbers
$PAYCHECKLEDGERENTRY = q(
%s Paycheck MTB 
    ; PayStart :: %s 
    ; PayEnd ::  %s 
    ; ofxid :: %s
    MTB:Hours                        MTBHRS -%s @@ USD %s
    MTB:AR                              USD %s    
    MTB:Deductions:EmployeeTaxes        USD %s
    MTB:Deductions

);

sub cvdateYmd {
    my ( $m, $d, $y ) = split /\//, $_[0];
    return join "/", $y, $m, $d;
}

sub nn {
    my $l = $_[0];
    $l =~ s/,//g;
    $l;
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
        $payLine = <>;
        chomp $payLine;
        @payTokens = split /\s\s+/, $payLine;

        $grossPay      = nn( $payTokens[2] );
        $employeeTaxes = nn( $payTokens[4] );

        # print Dumper ( \@payTokens );
        $amt = nn( $payTokens[-1] );
        $hrs = $payTokens[1];

        # printf "%s : %s\n", $hrs, $amt;
        printf $PAYCHECKLEDGERENTRY, $ppCheckDate,
          $ppBegin, $ppEnd,
          "$ppBegin-$ppEnd",
          $hrs, $grossPay,
          $amt, $employeeTaxes;
    }
}
exit;

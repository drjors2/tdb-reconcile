use strict;
use warnings;
use Data::Dumper;

use Text::CSV qw( csv );

# use Text::CSV_XS;

# stolen from : /home/djors/ledgers/transactions/statements/org-statements/rbc-checking/src/

my $hmonths  = {};
my @months   = qw|Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec|;
my $remonths = join "|", @months;
my $mid      = 1;
my %h        = map { $months[$_], sprintf( "%02d", 1 + $_ ) } ( 0 .. $#months );
map { $hmonths->{$_} = sprintf( "%02d", $mid++ ) } @months;

my $currentMonth = 0;
my $startYr;
my $isDec = 0;

sub dt() {
    my $m = $_[0];

    # $currentMonth =  $m if  $currentMonth == 0;
    # $yr++ if $m < $currentMonth;
    # $currentMonth = $m;
    return sprintf "%s-%s-%s",
      $startYr + ( ( $isDec == 1 && $m == 1 ) ? 1 : 0 ), $m,
      $_[1];
}

# headings should not have numbers
my $PAYCHECKLEDGERENTRY = q(
%s Paycheck MTB 
    ; PayStart :: %s 
    ; PayEnd ::  %s 
    ; ofxid :: %s-%s
    MTB:Hours                        MTBHRS -%s
    MTB:AR                              USD %s    

);

sub cvdateYmd {
    my ( $m, $d, $y ) = split /\//, $_[0];
    return join "/", $y, $m, $d;
}

# --------------------------------------------------------------------------------

my @CSV;

my $header = 0;

my %stat = ();

my $dir = 1;

while (<>) {
    $dir = 1  if /(Electronic Deposits|Other Credits)/;
    $dir = -1 if /Other Withdrawals/;

    if (/Statement Period/) {
        $startYr = $1 if /Statement Period:.*?(\d{4})-/;
        $isDec   = 1  if /Statement Period:\s+Dec/;
    }
    chomp;
    if (/POSTING DATE.*DESCRIPTION/) {
        chomp;
        my @header = split /\s\s+/, $_;
        if ( $header == 0 ) {
            push @CSV, \@header;

            # print Dumper (@header);
            $header = 1;
        }

        my $l = <>;
        while ( $l =~ /^\w/ ) {
            chomp $l;
            my @post = split /\s\s+/, $l;
            $post[-1] =~ s/,//g;
            $post[-1] = $dir * $post[-1];
            $post[0] =~ s/(\d\d)\/(\d\d)/&dt($1,$2,$startYr)/ge;

            push @CSV, \@post;

            # print Dumper (@post);
            $l = <>;
        }
    }

}

csv( in => \@CSV, out => *STDOUT, eol => $/ );


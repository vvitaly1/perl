#!/cygdrive/c/Perl64/bin/perl

use IO::File;

my $db = $ARGV[0];
my $DateMatch = $ARGV[1]; # passed YearMonth

sub epoch
{
	my $time = shift (@_);    # or any other epoch timestamp
	my @months = ("01","02","03","04","05","06","07","08","09","10","11","12");
	my ($sec,$min,$hour,$day,$month,$year) = (gmtime($time))[0,1,2,3,4,5];

	if ($day < 10){ $day = "0".$day; }
        if ($hour < 10){ $hour = "0".$hour; }
        if ($min < 10){ $min =  "0".$min; }
        if ($sec < 10){ $sec =  "0".$sec; }

	my $date = ($year+1900).$months[$month].$day."_".$hour.":".$min.":".$sec;
	return $date;
}

if (!$db){
	print "No tradebase is specified. Please use parseDB.pl [orders.dat]\n" ;
	exit;
}


my $fh = new IO::File "$db" or die "Cannot open $db : $!";
binmode($fh);
my $buf;
my $buflen = (stat($fh))[7];

sysread $fh, $header, hex(88);
while (sysread ($fh, $buff, 224)){
	my @order = unpack (iiZ12iiiiidddiiiiddddddddia32iiida20, $buff);
	next if ($order[24] !~/Tradency/);
	if(epoch($order[6]) =~ /^$DateMatch/){
		#if($order[24] =~ /(Tradency||TradencyFF):ord=[0-9]*,\sS[0-9]{2,4}(ss||\[sl\])/){
		if($order[24] =~ /(Tradency||TradencyFF)(:ord=[0-9]*)/){
			$acc1{$order[1]}=1;			
		}
	}
}

close $fh;


my $fh2 = new IO::File "$db" or die "Cannot open $db : $!";
binmode($fh2);
my $buf;
my $buflen = (stat($fh2))[7];

sysread $fh2, $header, hex(88);
while (sysread ($fh2, $buff, 224)){
	my @order = unpack (iiZ12iiiiidddiiiiddddddddia32iiida20, $buff);
	if ($acc1{$order[0]}==1 && $order[24] !~/Tradency/){
			$acc{$order[0]}=$order[1];
			$cp{$order[0]}=$order[2];
			$vol{$order[0]}=$order[5];
			$openTime{$order[0]}=$order[6];
			$closeTime{$order[0]}=$order[11];
			$magic{$order[0]}=$order[23];
			$comment{$order[0]}=$order[24];
			$profit{$order[0]}=$order[21];
	} 

}

close $fh2;



for $k (keys %acc){
	print "$k|$acc{$k}|$cp{$k}|$vol{$k}|".epoch($openTime{$k})."|".epoch($closeTime{$k})."|$magic{$k}|$comment{$k}|$profit{$k}\n";
}





# @order :
#	0	order_id
#	1	login
#	2	symbol
#	3	digits
#	4	cmd
#	5	volume
#	6	open_time
#	7	open_mode
#	8	open_price
#	9	sl
#	10	tp
#	11	close_time
#	12	value_date
#	13	expiration
#	14	conv_reserv
#	15	conv_rates_open
#	16	conv_rates_close
#	17	commission
#	18	commission_agent
#	19	storage
#	20	close_price
#	21	profit
#	22	taxes
#	23	magic
#	24	comments
#	25	internal_id
#	26	activation
#	27	margin_reserved
#	28	margin_rate
#	29	reserved

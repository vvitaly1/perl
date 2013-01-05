#!/usr/bin/perl

use IO::File;
use POSIX qw(strftime);

my $date = strftime("%Y%m%d", localtime(time));


open FILE, "<accounts" or die;
while (<FILE>){
 chomp;
 $accounts{$_}=1;
}
close FILE; 

my $fh_14 = new IO::File "<$ARGV[0]" or die "Cannot open orders.dat : $!";
binmode($fh_14);
sysread  $fh_14, $header, hex(88);

while (sysread ($fh_14, my $buff, 224)){
	my @order = unpack (iiZ12iiiiidddiiiiddddd, $buff);
		next if ($accounts{$order[1]}!=1);
		next if ($order[0]==0);
		$swap{$order[1]}=$swap{$order[1]}+$order[19];		
#		print "$order[0]\t$order[1]\t$order[19]\n";
}

my $fh_15 = new IO::File "<$ARGV[1]" or die "Cannot open orders.dat : $!";
binmode($fh_15);
sysread  $fh_15, $header, hex(88);

while (sysread ($fh_15, my $buff, 224)){
	my @order = unpack (iiZ12iiiiidddiiiiddddd, $buff);
		next if ($accounts{$order[1]}!=1);
		next if ($order[0]==0);
		$swap2{$order[1]}=$swap2{$order[1]}+$order[19];		
}



foreach $k (keys %accounts){	
	$swapValue=$swap2{$k}-$swap{$k};
	next if $swapValue==0;
	print "$k;".sprintf("%.2f",$swapValue)."\n";
}


# @order :
#	1	order_id
#	2	login
#	3	symbol
#	4	digits
#	5	cmd
#	6	volume
#	7	open_time
#	8	open_mode
#	9	open_price
#	10	sl
#	11	tp
#	12	close_time
#	13	value_date
#	14	expiration
#	15	conv_reserv
#	16	conv_rates_open
#	17	conv_rates_close
#	18	commission
#	19	commission_agent
#	20	storage
#	21	close_price
#	22	profit
#	23	taxes
#	24	magic
#	25	comments
#	26	internal_id
#	27	activation
#	28	margin_reserved
#	29	margin_rate
#	30	reserved


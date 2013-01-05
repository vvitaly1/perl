#!/usr/bin/perl

use Net::SMTP;
use POSIX qw(strftime);
use POSIX qw(mktime);
#use POSIX;


print localtime(time)." Start the script....\n";
print localtime(time)." MT Time ".localtime(time+7*60*60)."\n";

$pathToMT4 = 'D:\MetaTraderServer4';
$smtpserver = 'smtp.fxdd.com';
#@mailTo = ('tradeadmins@fxdd.com');
@mailTo = ('vitaliy.vasilika@fxdd.com');

$serverName='MT4Live1';
$period = 1; #timeperiod
$max_conn=5000; # lines for the past period
$max_IPs = 15; # max source IPs

$today = strftime("%Y%m%d", localtime(time+7*60*60));
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time+7*60*60);


########################### MAIN ##########################

# gets stat for the past hours ($period)

#print "Open File $pathToMT4\\logs\\$today.log\n";
open LOGFILE, "<$pathToMT4\\logs\\$today.log" or die "can't open logfile $!";

while (<LOGFILE>){
	# 1=hour;2=min;3=sec;4=IP;5=login;6=line
	if($_ =~ /\d\s(\d{2}):(\d{2}):(\d{2})\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*\'(\d*)\':\s*(.*)/){
		next if ($1 < $hour-$period);
		next if ($1 == $hour-$period && $2 < $min);
		next if ($1 == $hour-$period && $2 == $min && $3 < $sec);
#		next if ($5 < 1000); # ignore managers
		next if ($6 =~/unknown user/);
		next if ($6 =~/invalid pass/);

		$conn{$5}=$conn{$5}+1; # connections by login
		$$5{$4}=1; # remember IP
	}
}


foreach(sort {$conn{$b} <=> $conn{$a}} keys %conn) {
	&notify if ($conn{$_} > $max_conn || scalar(keys %$_) > $max_IPs);
}

close LOGFILE;
close BLOCKED;
print localtime(time)." Finish the script....\n";


#########################################################



sub notify{
  $smtp = Net::SMTP->new("$smtpserver");
  $smtp->mail('antifloodcontrol@$serverName.fxdd.com') || print "Can't connect to SMTP server";
  foreach (@mailTo){
    $smtp->to($_);
  }
  $smtp->data();
  $smtp->datasend("Subject: $serverName antiFlood control\n");
  $smtp->datasend("To: @mailTo");
  $smtp->datasend("\n");
  $smtp->datasend("Please check the IP(s) below. They generate huge load on server and it can be a reason of MemoryExceptions.\n\n");
  $smtp->datasend("AccountID - Number of lines in log for past hour - Number of unique IPs used by the account for past hour\n");

foreach(sort {$conn{$b} <=> $conn{$a}} keys %conn) {
	$smtp->datasend("$_ - $conn{$_} - ".scalar(keys %$_)."\n") if ($conn{$_} > $max_conn || scalar(keys %$_) > $max_IPs);
}

#  foreach (@toBlock){
#    $smtp->datasend("$_ - $ip{$_}\n");
#  }
  $smtp->dataend();
  $smtp->quit;           
}


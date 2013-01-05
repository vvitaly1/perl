#!/usr/bin/perl

use Cwd;
use Net::FTP;
use Net::SMTP;
use File::Path;
use POSIX qw(strftime);
use IO::File;
use Digest::MD5 qw(md5 md5_hex md5_base64);

$users1='users_20121204_084812_backup.dat';
$users2='users_20121204_194823_backup.dat';
$orders1='orders_20121204_084812_backup.dat';
$orders2='orders_20121204_094811_backup.dat';

print localtime(time)." Start creating new backup...\n";

&processBases('users');
#&processBases('orders');

sub processBases(){
	%hash=();
	$baseType=shift;
	my $fh_1 = new IO::File "<${${baseType}.1}" or die "Cannot open ${${baseType}.1} $!";	
	my $fh_2 = new IO::File "<${${baseType}.2}" or die "Cannot open ${${baseType}.2} $!";	
	my $fh_out = new IO::File ">${baseType}.dat" or die "${baseType}.dat $!";	

	binmode($fh_1);
	binmode($fh_2);
	binmode($fh_out);
	sysread  $fh_1,  $header, hex(88);
	sysread  $fh_2,  $header, hex(88);
#	syswrite($fh_out,$header);

	if($baseType=='users'){
		$lengh=224;
		$unp="ia220";
	}
	if($baseType=='orders'){
		$lengh=1120;
		$unp="ia1116";
	}

	# read 1
	while (sysread ($fh_1, my $buff, $lengh)){	
		my ($id,$other) = unpack ($unp, $buff);
		$hash{$id}=md5_hex($buff);
	}

#	print scalar(keys %hash)."\n";

	# check 2 
	while (sysread ($fh_2, my $buff2, $lengh)){
		my ($id2,$other2) = unpack ($unp, $buff2);
		if ($hash{$id2} != md5_hex($buff2)){
#			print "$id2 - $hash{$id2} - ".md5_hex($buff2)."\n";
			syswrite($fh_out,$buff2);
		}
	}
}
print localtime(time)." The new backup processed\n";
#!/usr/bin/perl

use Cwd;
use Net::FTP;
use Net::SMTP;
use File::Path;
use POSIX qw(strftime);
use IO::File;
use Digest::MD5 qw(md5 md5_hex md5_base64);

$usersOrigin='users_20121204_084812_backup.dat';
$usersBackup='usersBackup.dat';
$ordersOrigin='orders_20121204_084812_backup.dat';
$ordersBackup='ordersBackup.dat';

print localtime(time)." Start creating new backup...\n";

&processBases('users');
#&processBases('orders');

sub processBases(){
	%hash=();
	$baseType=shift;
	my $fh_full = new IO::File "<${${baseType}.Origin}" or die "Cannot open ${${baseType}.Origin} $!";
	my $fh_part = new IO::File "<${${baseType}.Backup}" or die "Cannot open ${${baseType}.Backup} $!";
	my $fh_total = new IO::File ">${baseType}.dat" or die "${baseType}.dat $!";

	binmode($fh_full);
	binmode($fh_part);
	binmode($fh_total);
	sysread  $fh_full,  $header, hex(88);
	sysread  $fh_part,  $header, hex(88);
	syswrite($fh_total,$header);

	if($baseType=='users'){
		$lengh=224;
		$unp="ia220";
	}
	if($baseType=='orders'){
		$lengh=1120;
		$unp="ia1116";
	}

	# read 1
	while (sysread ($fh_part, my $buff, $lengh)){	
		my ($id,$other) = unpack ($unp, $buff);
		print "$id\n";
		$hash{$id}=md5_hex($buff);
		$data{$id}=$buff;
	}

#	print scalar(keys %hash)."\n";

	# write
	while (sysread ($fh_full, my $buff2, $lengh)){
		my ($id2,$other) = unpack ($unp, $buff2);
		if ($hash{$id2} != md5_hex($buff2) && $hash{$id2} !=""){
#			print "$id2 - $hash{$id2} - ".md5_hex($buff2)."\n";
			syswrite($fh_total,$data{$id2});
		}else{
			syswrite($fh_total,$buff2);
		}
	}
}
print localtime(time)." The new backup processed\n";
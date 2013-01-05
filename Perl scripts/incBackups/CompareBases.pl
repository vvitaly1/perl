#!/usr/bin/perl

use Cwd;
use Net::FTP;
use Net::SMTP;
use File::Path;
use POSIX qw(strftime);
use IO::File;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $fh_1 = new IO::File "<$ARGV[0]" or die "Cannot open ${${baseType}.Origin} $!";
my $fh_2 = new IO::File "<$ARGV[1]" or die "Cannot open ${${baseType}.Origin} $!";
binmode($fh_1);
binmode($fh_2);
sysread  $fh_1,  $header, hex(88);
sysread  $fh_2,  $header, hex(88);

	if($ARGV[0] =/orders/){
		$lengh=224;
		$unp="ia220";
	}
	if($ARGV[0] =/users/){
		$lengh=1120;
		$unp="ia1116";
	}

	# read 1
	while (sysread ($fh_1, my $buff, $lengh)){	
		my ($id,$other) = unpack ($unp, $buff);
		$hash{$id}=md5_hex($buff);
	}

	# read 2
	while (sysread ($fh_2, my $buff2, $lengh)){
		my ($id2,$other) = unpack ($unp, $buff2);
		if ($hash{$id2} != md5_hex($buff2) && $hash{$id2} !=""){
			print "$id2 - $hash{$id2} - ".md5_hex($buff2)."\n";
		}
	}

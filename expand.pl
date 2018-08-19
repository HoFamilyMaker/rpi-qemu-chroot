#!/usr/bin/env perl
use feature 'say';
use strict;
use warnings;
use English;

use File::Basename;
use Cwd;

my $basedir=Cwd::abs_path(dirname($PROGRAM_NAME));
chdir($basedir);

sub usage {
	say "USAGE: $0 source dest size(GB)";
	exit(1);
}

usage() unless $ARGV[0];
usage() unless $ARGV[1];
usage() unless $ARGV[2];

my ($source,$dest,$count)=($ARGV[0],$ARGV[1],$ARGV[2]);

if($UID != 0 ) {
	say "please run with sudo.";
	exit(1);
}

$ENV{LANG}='C';

say "copying file...";
system('cp',$source,$dest);

say "appending...";
system(qq{ dd if=/dev/zero bs=1G count=$count >> $dest });

my $start;
{
	my $fdisk=`fdisk -l $dest`;
	if($fdisk=~/^(.+) 83 Linux$/m) {
		my @buf=split(/\s+/,$1);
		$start=$buf[1];
	}
}

{
	say $start;
	system(q{sh -c '( echo d; echo 2; echo n; echo p; echo 2; echo }.$start.q{; echo; echo w ) | fdisk }.$dest.q{'});
}

{
	my $lo=`losetup -f -P --show $dest`; chomp $lo;
	system('e2fsck','-f',$lo.'p2');
	system('resize2fs',$lo.'p2');
	system('losetup','-d',$lo);
}

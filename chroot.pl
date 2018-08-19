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
	say "USAGE: $0 image name";
	exit(1);
}

usage() unless $ARGV[0];
usage() unless $ARGV[1];

my ($image,$name)=($ARGV[0],$ARGV[1]);

if($UID != 0 ) {
	say "please run with sudo.";
	exit(1);
}

$ENV{LANG}='C';
system('mkdir','-p',"var/$name");

{
	my $fdisk=`fdisk -l $image`;
	my $units;
	if($fdisk=~/^\QUnits: sectors of 1 * \E(\d+) = (\d+) bytes/m) { $units=$1 }
	my $start;
	if($fdisk=~/^(.+) 83 Linux$/m) {
		my @buf=split(/\s+/,$1);
		$start=$buf[1]*$units;
	}
	my $mount;
	system('mount','-v','-o',"offset=$start",'-t','ext4',$image,"var/$name");
}

chdir("var/$name");
system(qw( mount --bind /dev     dev/    ));
system(qw( mount --bind /sys     sys/    ));
system(qw( mount --bind /proc    proc/   ));
system(qw( mount --bind /dev/pts dev/pts ));

$ENV{HOME}='/root';

system('cp','-f','/usr/bin/qemu-arm-static',"usr/bin");

system('chroot','.','bin/bash');

system(qw( umount dev/pts ));
system(qw( umount dev/    ));
system(qw( umount sys/    ));
system(qw( umount proc/   ));

chdir($basedir);
system('umount','-l',"var/$name");
sleep(1);
system('rmdir',"var/$name");



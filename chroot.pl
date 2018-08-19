#!/usr/bin/env perl
use feature 'say';
use strict;
use warnings;
use English;

use File::Basename;
use File::Path qw(mkpath rmtree);
use Cwd;

my $basedir=Cwd::abs_path(dirname($PROGRAM_NAME));

# マウントポイントを作成する場所
my $mountdir="$basedir/mount";

# マルチコア
$ENV{QEMU_CPU}='arm11mpcore';

# シングルコア
$ENV{QEMU_CPU}='arm1176';

$ENV{LANG}='C';
$ENV{HOME}='/root';

chdir($basedir);
mkpath($mountdir) unless(-d $mountdir);

sub usage {
	say "USAGE: $0 [image|block] name";
	exit(1);
}

usage() unless $ARGV[0];
usage() unless $ARGV[1];

my ($image,$name)=($ARGV[0],$ARGV[1]);


if($UID != 0 ) {
	say "please run with sudo.";
	exit(1);
}


mkpath("$mountdir/$name") unless(-d "$mountdir/$name");

my $loopback;
if(-f $image) {
	# ファイルの場合
	$loopback=`losetup -f -P --show $image`;
	chomp $loopback;
	system('mount','-v','-t','ext4',$loopback.'p2',"$mountdir/$name");
	system('mount','-v','-t','vfat',$loopback.'p1',"$mountdir/$name/boot");

} elsif(-b $image) {
	# ブロックデバイスの場合
	system('mount','-v','-t','ext4',$image.'2',"$mountdir/$name");
	system('mount','-v','-t','vfat',$image.'1',"$mountdir/$name/boot");
} else {
	say "unknown file type";
	exit(1);
}


chdir("$mountdir/$name");
system(qw( mount --bind /dev     dev/    ));
system(qw( mount --bind /sys     sys/    ));
system(qw( mount --bind /proc    proc/   ));
system(qw( mount --bind /dev/pts dev/pts ));


system('cp','-f','/usr/bin/qemu-arm-static',"usr/bin");

system('chroot','.','bin/bash');

system(qw( umount dev/pts ));
system(qw( umount dev/    ));
system(qw( umount sys/    ));
system(qw( umount proc/   ));

chdir($basedir);

system('umount','-l',"$mountdir/$name/boot");
system('umount','-l',"$mountdir/$name");
if($loopback) {
	system('losetup','-d',$loopback);
}

sleep(1);

rmdir("$mountdir/$name");


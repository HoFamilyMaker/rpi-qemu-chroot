# AMD64マシンでRaspberry Piエミュレーション環境

qemu-user-static を使用して x86_64 マシンで Raspberry Pi環境へchrootできる。
ARMのバイナリを実行する

Ubuntu 18.04(x86_64)で動作確認

# 利用方法

## セットアップ

	$ sudo apt install qemu qemu-user-static binfmt-support
	$ mkdir images
	$ cd images

images にraspbian image をおく

	$ unzip 2018-06-27-raspbian-stretch-lite.zip
	$ cd ..

## 領域の拡張

4GBのイメージを作成する

	$ sudo ./expand.pl images/2018-06-27-raspbian-stretch-lite.img images/raspi1.img 4

## 環境に入る

	$ sudo ./chroot.pl images/raspi1.img raspi1

## 確認

	# uname -a
	Linux uvm2 4.15.0-32-generic #35-Ubuntu SMP Fri Aug 10 17:58:07 UTC 2018 armv7l GNU/Linux

# 参考URL

* https://wiki.debian.org/RaspberryPi/qemu-user-static
* https://jyn.jp/raspbian-on-qemu/


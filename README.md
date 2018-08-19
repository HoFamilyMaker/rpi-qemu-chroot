# AMD64マシンでRaspberry Piエミュレーション環境

qemu-user-static を使用して x86\_64 マシンで Raspberry Pi環境へchrootできる。
ARMのバイナリを実行する

以下の環境で動作確認しています
* ホスト: Ubuntu 18.04(x86\_64)
* イメージ: Raspbian(2018-06-27-raspbian-stretch-lite)

sudo したときなどUnknown QEMU\_IFLA_\* なエラーがでるけどとりあえず動く。

# 利用方法

## セットアップ

	$ sudo apt install qemu qemu-user-static binfmt-support
	$ mkdir images
	$ cd images

## イメージを使用する

### images にraspbian image を展開

	$ unzip 2018-06-27-raspbian-stretch-lite.zip
	$ cd ..

### 領域の拡張

4GBのイメージを作成する

	$ sudo ./expand.pl images/2018-06-27-raspbian-stretch-lite.img images/raspi1.img 4

### 環境に入る

	$ sudo ./chroot.pl images/raspi1.img raspi1

## ブロックデバイス(SDカードなど)を使用する

すでにマウントされている場合は一度アンマウントしておくこと。

### 環境に入る

	$ sudo ./chroot.pl /dev/sdc raspi1

## 確認

	# uname -a
	Linux uvm2 4.15.0-32-generic #35-Ubuntu SMP Fri Aug 10 17:58:07 UTC 2018 armv7l GNU/Linux

# SDへイメージファイルの書き込み

pv を使うと進捗を確認しながら書き込める。

/dev/sdX は自分の環境にあわせること

	$ sudo apt install pv
	$ sudo sh -c 'pv images/raspi1.img | dd of=/dev/sdX bs=16M'

# 参考URL

* https://wiki.debian.org/RaspberryPi/qemu-user-static
* https://jyn.jp/raspbian-on-qemu/


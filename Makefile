ARM64_CROSS_FLAGS = ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
ARM64_CROSS_FLAGS_BOOT = CROSS_COMPILE=aarch64-linux-gnu-
ARM_CROSS_FLAGS = ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf-
ARM_CROSS_FLAGS_BOOT = CROSS_COMPILE=arm-none-linux-gnueabihf-

all: boot-amazon-otter.img pine64-pinephone.img.xz pine64-pinetab.img.xz purism-librem5.tar.xz boot-xiaomi-beryllium-tianma.img boot-xiaomi-beryllium-ebbg.img boot-oneplus-enchilada.img boot-oneplus-fajita.img


pine64-pinephone.img: fat-pine64-pinephone.img u-boot-sunxi-with-spl.bin
	rm -f $@
	truncate --size 50M $@
	parted -s $@ mktable msdos
	parted -s $@ mkpart primary fat32 2048s 100%
	parted -s $@ set 1 boot on
	dd if=u-boot-sunxi-with-spl.bin of=$@ bs=8k seek=1
	dd if=fat-$@ of=$@ seek=1024 bs=1k

fat-pine64-pinephone.img: initramfs-pine64-pinephone.gz kernel-sunxi.gz pine64-pinephone.scr dtbs/sunxi/sun50i-a64-pinephone-1.2.dtb
	@echo "MKFS  $@"
	@rm -f $@
	@truncate --size 40M $@
	@mkfs.fat -F32 $@
	
	@mcopy -i $@ kernel-sunxi.gz ::Image.gz
	@mcopy -i $@ dtbs/sunxi/sun50i-a64-pinephone-1.2.dtb ::sun50i-a64-pinephone-1.2.dtb
	@mcopy -i $@ dtbs/sunxi/sun50i-a64-pinephone-1.1.dtb ::sun50i-a64-pinephone-1.1.dtb
	@mcopy -i $@ dtbs/sunxi/sun50i-a64-pinephone-1.0.dtb ::sun50i-a64-pinephone-1.0.dtb
	@mcopy -i $@ initramfs-pine64-pinephone.gz ::initramfs.gz
	@mcopy -i $@ pine64-pinephone.scr ::boot.scr

pine64-pinetab.img: fat-pine64-pinetab.img u-boot-sunxi-with-spl.bin
	rm -f $@
	truncate --size 50M $@
	parted -s $@ mktable msdos
	parted -s $@ mkpart primary fat32 2048s 100%
	parted -s $@ set 1 boot on
	dd if=u-boot-sunxi-with-spl.bin of=$@ bs=8k seek=1
	dd if=fat-$@ of=$@ seek=1024 bs=1k

fat-pine64-pinetab.img: initramfs-pine64-pinetab.gz kernel-sunxi.gz pine64-pinetab.scr dtbs/sunxi/sun50i-a64-pinetab.dtb
	@echo "MKFS  $@"
	@rm -f $@
	@truncate --size 40M $@
	@mkfs.fat -F32 $@
	
	@mcopy -i $@ kernel-sunxi.gz ::Image.gz
	@mcopy -i $@ dtbs/sunxi/sun50i-a64-pinetab.dtb ::sun50i-a64-pinetab.dtb
	@mcopy -i $@ initramfs-pine64-pinetab.gz ::initramfs.gz
	@mcopy -i $@ pine64-pinetab.scr ::boot.scr

pine64-pinebookpro.img: fat-pine64-pinebookpro.img u-boot-rk3399.bin
	rm -f $@
	truncate --size 50M $@
	parted -s $@ mktable msdos
	parted -s $@ mkpart primary fat32 32768s 100%
	parted -s $@ set 1 boot on
	dd if=u-boot-rk3399.bin of=$@ bs=32k seek=1
	dd if=fat-$@ of=$@ seek=32768 bs=512

fat-pine64-pinebookpro.img: initramfs-pine64-pinebookpro.gz kernel-rockchip.gz src/pine64-pinebookpro.conf dtbs/rockchip/rk3399-pinebook-pro.dtb
	@echo "MKFS  $@"
	@rm -f $@
	@truncate --size 40M $@
	@mkfs.fat -F32 $@
	
	@mcopy -i $@ kernel-rockchip.gz ::Image.gz
	@mcopy -i $@ dtbs/rockchip/rk3399-pinebook-pro.dtb ::rk3399-pinebook-pro.dtb
	@mcopy -i $@ initramfs-pine64-pinebookpro.gz ::initramfs.gz
	@mmd   -i $@ extlinux
	@mcopy -i $@ src/pine64-pinebookpro.conf ::extlinux/extlinux.conf

kernel-xiaomi-beryllium-tianma.gz-dtb: kernel-sdm845.gz dtbs/sdm845/sdm845-xiaomi-beryllium-tianma.dtb
	cat kernel-sdm845.gz dtbs/sdm845/sdm845-xiaomi-beryllium-tianma.dtb > $@

kernel-xiaomi-beryllium-ebbg.gz-dtb: kernel-sdm845.gz dtbs/sdm845/sdm845-xiaomi-beryllium-ebbg.dtb
	cat kernel-sdm845.gz dtbs/sdm845/sdm845-xiaomi-beryllium-ebbg.dtb > $@

kernel-oneplus-enchilada.gz-dtb: kernel-sdm845.gz dtbs/sdm845/sdm845-oneplus-enchilada.dtb
	cat kernel-sdm845.gz dtbs/sdm845/sdm845-oneplus-enchilada.dtb > $@

kernel-oneplus-fajita.gz-dtb: kernel-sdm845.gz dtbs/sdm845/sdm845-oneplus-fajita.dtb
	cat kernel-sdm845.gz dtbs/sdm845/sdm845-oneplus-fajita.dtb > $@

kernel-amazon-otter.gz-dtb: kernel-omap4.gz dtbs/omap4-kc1.dtb
	echo "This did not work for me..."
	cat kernel-omap4.gz dtbs/omap4-kc1.dtb > $@

boot-%.img: initramfs-%.gz kernel-%.gz-dtb
	rm -f $@
	$(eval BASE := $(shell cat src/deviceinfo_$* | grep base | cut -d "\"" -f 2))
	$(eval SECOND := $(shell cat src/deviceinfo_$* | grep second | cut -d "\"" -f 2))
	$(eval KERNEL := $(shell cat src/deviceinfo_$* | grep kernel | cut -d "\"" -f 2))
	$(eval RAMDISK := $(shell cat src/deviceinfo_$* | grep ramdisk | cut -d "\"" -f 2))
	$(eval TAGS := $(shell cat src/deviceinfo_$* | grep tags | cut -d "\"" -f 2))
	$(eval PAGESIZE := $(shell cat src/deviceinfo_$* | grep pagesize | cut -d "\"" -f 2))
	mkbootimg --kernel kernel-omap4.gz --dt dtbs/omap4-kc1.dtb --ramdisk initramfs-$*.gz --base $(BASE) --second_offset $(SECOND) --kernel_offset $(KERNEL) --ramdisk_offset $(RAMDISK) --tags_offset $(TAGS) --pagesize $(PAGESIZE) --cmdline "console=ttyO2,115200" -o $@

%.img.xz: %.img
	@echo "XZ    $@"
	@xz -c $< > $@

initramfs/bin/busybox: src/busybox src/busybox_config
	@echo "MAKE  $@"
	@mkdir -p build/busybox
	@cp src/busybox_config build/busybox/.config
	@$(MAKE) -C src/busybox O=../../build/busybox $(ARM_CROSS_FLAGS)
	@cp build/busybox/busybox initramfs/bin/busybox
	
splash/%.ppm.gz: splash/%.ppm
	@echo "GZ    $@"
	@gzip < $< > $@
	
initramfs-%.cpio: initramfs/bin/busybox initramfs/init initramfs/init_functions.sh splash/%.ppm.gz splash/%-error.ppm.gz
	@echo "CPIO  $@"
	@rm -rf initramfs-$*
	@cp -r initramfs initramfs-$*
	@cp src/info-$*.sh initramfs-$*/info.sh
	@cp splash/$*.ppm.gz initramfs-$*/splash.ppm.gz
	@cp splash/$*-error.ppm.gz initramfs-$*/error.ppm.gz
	@cp src/info-$*.sh initramfs-$*/info.sh
	@cd initramfs-$*; find . | cpio -H newc -o > ../$@
	
initramfs-%.gz: initramfs-%.cpio
	@echo "GZ    $@"
	@gzip < $< > $@
	
kernel-sunxi.gz: src/linux_config_sunxi src/linux-sunxi
	@echo "MAKE  kernel-sunxi.gz"
	@mkdir -p build/linux-sunxi
	@mkdir -p dtbs/sunxi
	@cp src/linux_config_sunxi build/linux-sunxi/.config
	@$(MAKE) -C src/linux-sunxi O=../../build/linux-sunxi $(ARM64_CROSS_FLAGS) olddefconfig
	@$(MAKE) -C src/linux-sunxi O=../../build/linux-sunxi $(ARM64_CROSS_FLAGS)
	@cp build/linux-sunxi/arch/arm64/boot/Image.gz kernel-sunxi.gz
	@cp build/linux-sunxi/arch/arm64/boot/dts/allwinner/*.dtb dtbs/sunxi/

dtbs/sunxi/sun50i-a64-pinephone-1.2.dtb: kernel-sunxi.gz

dtbs/sunxi/sun50i-a64-pinetab.dtb: kernel-sunxi.gz

kernel-rockchip.gz: src/linux_config_rockchip src/linux-rockchip
	@echo "MAKE  $@"
	@mkdir -p build/linux-rockchip
	@mkdir -p dtbs/rockchip
	@cp src/linux_config_rockchip build/linux-rockchip/.config
	@$(MAKE) -C src/linux-rockchip O=../../build/linux-rockchip $(ARM64_CROSS_FLAGS) olddefconfig
	@$(MAKE) -C src/linux-rockchip O=../../build/linux-rockchip $(ARM64_CROSS_FLAGS)
	@cp build/linux-rockchip/arch/arm64/boot/Image.gz $@
	@cp build/linux-rockchip/arch/arm64/boot/dts/rockchip/*.dtb dtbs/rockchip/

kernel-librem5.gz: src/linux_config_librem5 src/linux-librem5
	@echo "MAKE  $@"
	@mkdir -p build/linux-librem5
	@mkdir -p dtbs/librem5
	@cp src/linux_config_librem5 build/linux-librem5/.config
	@$(MAKE) -C src/linux-librem5 O=../../build/linux-librem5 $(ARM64_CROSS_FLAGS) olddefconfig
	@$(MAKE) -C src/linux-librem5 O=../../build/linux-librem5 $(ARM64_CROSS_FLAGS)
	@cp build/linux-librem5/arch/arm64/boot/Image.gz $@
	@cp build/linux-librem5/arch/arm64/boot/dts/freescale/imx8mq-librem5*.dtb dtbs/librem5/

dtbs/librem5/imx8mq-librem5-r2.dtb: kernel-librem5.gz

kernel-sdm845.gz: src/linux-sdm845
	@echo "MAKE  $@"
	@mkdir -p build/linux-sdm845
	@mkdir -p dtbs/sdm845
	@$(MAKE) -C src/linux-sdm845 O=../../build/linux-sdm845 $(ARM64_CROSS_FLAGS) defconfig sdm845.config
	@printf "CONFIG_USB_ETH=n" >> build/linux-sdm845/.config
	@$(MAKE) -C src/linux-sdm845 O=../../build/linux-sdm845 $(ARM64_CROSS_FLAGS)
	@cp build/linux-sdm845/arch/arm64/boot/Image.gz $@
	@cp build/linux-sdm845/arch/arm64/boot/dts/qcom/sdm845-{xiaomi-beryllium-*,oneplus-enchilada,oneplus-fajita}.dtb dtbs/sdm845/

kernel-omap4.gz: src/linux-omap4
	@echo "MAKE  $@"
	@mkdir -p build/linux-omap4
	@mkdir -p dtbs/
	@cp src/linux_config_kc1 build/linux-omap4/.config
	@printf "CONFIG_USB_ETH=n" >> build/linux-omap4/.config
	@$(MAKE) -C src/linux-omap4 O=../../build/linux-omap4 $(ARM_CROSS_FLAGS)
	@cp build/linux-omap4/arch/arm/boot/zImage $@
	@cp build/linux-omap4/arch/arm/boot/dts/omap4-kc1.dtb dtbs/

dtbs/sdm845/sdm845-xiaomi-beryllium-ebbg.dtb: kernel-sdm845.gz

dtbs/sdm845/sdm845-xiaomi-beryllium-tianma.dtb: kernel-sdm845.gz

dtbs/sdm845/sdm845-oneplus-enchilada.dtb: kernel-sdm845.gz

dtbs/sdm845/sdm845-oneplus-fajita.dtb: kernel-sdm845.gz

dtbs/omap4-kc1.dtb: kernel-omap4.gz

%.scr: src/%.txt
	@echo "MKIMG $@"
	@mkimage -A arm -O linux -T script -C none -n "U-Boot boot script" -d $< $@
	
build/atf/sun50i_a64/bl31.bin: src/arm-trusted-firmware
	@echo "MAKE  $@"
	@mkdir -p build/atf/sun50i_a64
	@cd src/arm-trusted-firmware; make $(ARM64_CROSS_FLAGS_BOOT) PLAT=sun50i_a64 bl31
	@cp src/arm-trusted-firmware/build/sun50i_a64/release/bl31.bin "$@"

u-boot-sunxi-with-spl.bin: build/atf/sun50i_a64/bl31.bin src/u-boot
	@echo "MAKE  $@"
	@mkdir -p build/u-boot/sun50i_a64
	@BL31=../../../build/atf/sun50i_a64/bl31.bin $(MAKE) -C src/u-boot O=../../build/u-boot/sun50i_a64 $(ARM64_CROSS_FLAGS_BOOT) pinephone_defconfig
	@BL31=../../../build/atf/sun50i_a64/bl31.bin $(MAKE) -C src/u-boot O=../../build/u-boot/sun50i_a64 $(ARM64_CROSS_FLAGS_BOOT) ARCH=arm all
	@cp build/u-boot/sun50i_a64/u-boot-sunxi-with-spl.bin "$@"

build/atf/rk3399/bl31.elf: src/arm-trusted-firmware
	@echo "MAKE  $@"
	@mkdir -p build/atf/rk3399
	@cd src/arm-trusted-firmware; make $(ARM64_CROSS_FLAGS_BOOT) PLAT=rk3399 bl31
	@cp src/arm-trusted-firmware/build/sun50i_a64/release/bl31/bl31.elf "$@"

u-boot-rk3399.bin: build/atf/rk3399/bl31.elf src/u-boot
	@echo "MAKE  $@"
	@mkdir -p build/u-boot/rk3399
	@BL31=../../../build/atf/rk3399/bl31.elf $(MAKE) -C src/u-boot O=../../build/u-boot/rk3399 $(ARM64_CROSS_FLAGS_BOOT) rockpro64-rk3399_defconfig
	@BL31=../../../build/atf/rk3399/bl31.elf $(MAKE) -C src/u-boot O=../../build/u-boot/rk3399 $(ARM64_CROSS_FLAGS_BOOT) all
	@cp build/u-boot/rk3399/u-boot "$@"

u-boot-librem5.bin: src/u-boot-librem5
	@echo "MAKE  $@"
	@mkdir -p build/u-boot/librem5
	@cd build/u-boot/librem5 && ../../../src/u-boot-librem5/build_uboot.sh -b librem5
	@cp build/u-boot/librem5/output/uboot-librem5/u-boot-librem5.imx $@

src/linux-rockchip:
	@echo "WGET  linux-rockchip"
	@mkdir src/linux-rockchip
	@wget https://gitlab.manjaro.org/tsys/linux-pinebook-pro/-/archive/v5.6/linux-pinebook-pro-v5.6.tar.gz
	@tar -xf linux-pinebook-pro-v5.6.tar.gz --strip-components 1 -C src/linux-rockchip

src/linux-sunxi:
	@echo "WGET  linux-sunxi"
	@mkdir src/linux-sunxi
	@wget https://github.com/megous/linux/archive/orange-pi-5.9-20201019-1553.tar.gz
	@tar -xf orange-pi-5.9-20201019-1553.tar.gz --strip-components 1 -C src/linux-sunxi

src/linux-librem5:
	@echo "WGET linux-librem5"
	@mkdir src/linux-librem5
	@wget -c https://source.puri.sm/Librem5/linux-next/-/archive/pureos/5.9.16+librem5.2/linux-next-pureos-5.9.16+librem5.2.tar.gz
	@tar -xf linux-next-pureos-5.9.16+librem5.2.tar.gz --strip-components 1 -C src/linux-librem5

src/linux-sdm845:
	@echo "WGET linux-sdm845"
	@mkdir src/linux-sdm845
	@wget -c https://gitlab.com/sdm845-mainline/linux/-/archive/b7a1e57f78d690d02aff902114bf2f6ca978ecfe/linux-b7a1e57f78d690d02aff902114bf2f6ca978ecfe.tar.gz
	@tar -xf linux-b7a1e57f78d690d02aff902114bf2f6ca978ecfe.tar.gz --strip-components 1 -C src/linux-sdm845

src/linux-omap4:
	@echo "GET linux-omap4"
	@mkdir -p src/linux-omap4
	@git clone --depth=1 -b v5.11 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git src/linux-omap4
	@cd src/linux-omap4 && patch -p1 < ../0001-Update-device-tree-for-omap4-kc1.patch
	@cd src/linux-omap4 && patch -p1 < ../0002-Input-ili210x-Fix-ili210x-touchdata-coordinates-endianness.patch
	@cd src/linux-omap4 && patch -p1 < ../0003-Input-ili210x-add-missing-negation-for-touch-indicat.patch
	@cd src/linux-omap4 && patch -p1 < ../0005-HACK-ili210x-Reduce-poll-period-to-1.patch
	@cd src/linux-omap4 && patch -p1 < ../0006-Add-clk32kg-to-twl6030.patch

src/arm-trusted-firmware:
	@echo "WGET  arm-trusted-firmware"
	@mkdir src/arm-trusted-firmware
	@wget https://github.com/ARM-software/arm-trusted-firmware/archive/50d8cf26dc57bb453b1a52be646140bfea4aa591.tar.gz
	@tar -xf 50d8cf26dc57bb453b1a52be646140bfea4aa591.tar.gz --strip-components 1 -C src/arm-trusted-firmware

src/u-boot:
	@echo "WGET  u-boot"
	@mkdir src/u-boot
	@wget https://ftp.denx.de/pub/u-boot/u-boot-2020.04.tar.bz2
	@tar -xf u-boot-2020.04.tar.bz2 --strip-components 1 -C src/u-boot
	@cd src/u-boot && patch -p1 < ../u-boot-pinephone.patch

src/u-boot-librem5:
	@echo "WGET  u-boot-librem5"
	@mkdir src/u-boot-librem5
	@wget https://source.puri.sm/Librem5/u-boot-builder/-/archive/3b1c7d957f46c87c6cdd71cd8dab7c84aca26570/u-boot-builder-3b1c7d957f46c87c6cdd71cd8dab7c84aca26570.tar.gz
	@tar -xf u-boot-builder-3b1c7d957f46c87c6cdd71cd8dab7c84aca26570.tar.gz --strip-components 1 -C src/u-boot-librem5

src/busybox:
	@echo "WGET  busybox"
	@mkdir src/busybox
	@wget https://www.busybox.net/downloads/busybox-1.32.0.tar.bz2
	@tar -xf busybox-1.32.0.tar.bz2 --strip-components 1 -C src/busybox

.PHONY: clean cleanfast purism-librem5

purism-librem5: initramfs-purism-librem5.gz kernel-librem5.gz u-boot-librem5.bin src/purism-librem5.txt dtbs/librem5/imx8mq-librem5-r2.dtb
	cp src/boot-purism-librem5.sh boot-purism-librem5.sh
	cp src/purism-librem5.txt purism-librem5.lst
	@echo 'All done! Switch your phone into flashing mode and run Jumpdrive with `./boot-purism-librem5.sh`'

purism-librem5.tar.xz: purism-librem5
	@echo "XZ    librem5 files"
	@tar cJf $@ initramfs-purism-librem5.gz kernel-librem5.gz u-boot-librem5.bin purism-librem5.lst dtbs/librem5/imx8mq-librem5-r2.dtb boot-purism-librem5.sh

cleanfast:
	@rm -rvf build
	@rm -rvf initramfs-*/
	@rm -vf *.img
	@rm -vf *.img.xz
	@rm -vf *.tar.xz
	@rm -vf *.apk
	@rm -vf *.bin
	@rm -vf *.cpio
	@rm -vf *.gz
	@rm -vf *.gz-dtb
	@rm -vf *.scr
	@rm -vf splash/*.gz
	@rm -vf *.lst
	@rm -vf boot-purism-librem5.sh

clean: cleanfast
	@rm -vf kernel*.gz
	@rm -vf initramfs/bin/busybox
	@rm -vrf dtbs

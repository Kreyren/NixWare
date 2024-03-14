{ self, lib, config, ... }:

# NixOS SD-Card Generator Module for OLIMEX Teres-I

let
	inherit (lib) mkForce;
in {
	formatConfigs.sd-aarch64 = {
		idImage = {
			firmwarePartitionOffset = 8; # All Allwinner SoCs will try to find a boot image at sector 16 (8KB) of an SD card, connected to the first MMC controller -- https://docs.u-boot.org/en/stable/board/allwinner/sunxi.html#installing-on-a-micro-sd-card
			firmwareSize = 30;
			populateFirmwareCommands = ''
				# DNM(Krey): Is that mmcblk1?
				${self.inputs.nixpkgs.legacyPackages.aarch64-linux.busybox}/bin/dd if=${self.inputs.nixpkgs-unstable.legacyPackages.aarch64-linux.ubootOlimexA64Teres1}/u-boot-sunxi-with-spl.bin of=/dev/mmcblk1 bs=1k seek=8
			'';
			compressImage = true;
			expandOnBoot = true;
		};
	};
}

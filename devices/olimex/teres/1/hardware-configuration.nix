{ config, lib, unstable, pkgs, crossPkgs,... }:

# Hardware configuration for OLIMEX Teres-1, tested on Rev.C mainboard

let
	inherit (lib)
		mkIf
		mkDefault
		mkForce;
in {
	# Hardware
		hardware.deviceTree.enable = true; # deviceTree is critical for the kernel to know what to do with the device, required `mkForce` to override

	# Plymouth
		# FIXME-QA(Krey): Include OLIMEX's logo
		boot.plymouth.enable = mkDefault true;
		# boot.plymouth.logo  ...

	# Kernel Params
		boot.kernelParams = mkDefault [
			# Enable the Serial Console
			"console=ttyS0,115200n8"
			"console=tty0"

			"cma=256M" # 125 to prevent crashes in GNOME, 256 are needed for decoding H.264 videos with CEDRUS
		];

	# InitRD
		boot.initrd.availableKernelModules = mkDefault [
			"usbhid" # For USB Support during initrd e.g. external mouse and keyboard

			# Needed for display to work during initrd phase -- https://linux-sunxi.org/Olimex_Teres-A64#Display
			"sun4i-drm"
			"sun4i-tcon"
			"sun8i-mixer"
			"sun8i_tcon_top"
			"gpu-sched"
			"drm"
			"drm_shmem_helper"
			"drm_kms_helper"
			"drm_dma_helper"
			"drm_display_helper"
			"analogix_anx6345"
			"analogix_dp"
		];

		# FIXME-UPSTREAM(Krey): This is not enough to get working display in initrd, discuss including the modules above by default, thus required to be mkForced to change
		boot.initrd.includeDefaultModules = false; # Not optimized for the device

	# Power Management
		# NOTE(Krey): The 'ondemand' seems to be the most functional in terms of responsibility and battery life, thus changing it requires mkForce as other CPU Governors are not recommended
		powerManagement.cpuFreqGovernor = "ondemand"; # Set CPU Governors

	# Platform
		nixpkgs.hostPlatform = mkDefault "aarch64-linux";
}

{ config, lib, unstable, pkgs, crossPkgs,... }:

# Hardware configuration for OLIMEX Teres-1, tested on Rev.C mainboard

let
	inherit (lib)
		mkIf
		mkDefault
		mkForce;
in {
	# Hardware
		hardware.deviceTree.enable = true; # deviceTree is critical for the kernel to know what to do with the device

	# Boot Management
		boot.loader.systemd-boot.enable = true;
		boot.loader.systemd-boot.editor = false; # Can be used to inject commands in the OS, considered a security vulnerability
		boot.loader.efi.canTouchEfiVariables = false; # TowBoot doesn't do that according to samueldr (the creator)

	# Plymouth
		# FIXME-QA(Krey): Include OLIMEX's logo
		boot.plymouth.enable = true;

	# Kernel Params
		boot.kernelParams = [
			"console=ttyS0,115200n8"
			"console=tty0"
			"cma=256M" # 125 to prevent crashes in GNOME, 256 are needed for decoding H.264 videos with CEDRUS
		];

	# InitRD
		boot.initrd.systemd.enable = true;
		boot.initrd.availableKernelModules = [
			"usbhid" # for USB

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

		# FIXME-UPSTREAM(Krey): This is not enough to get working display in initrd, discuss including the modules above by default
		boot.initrd.includeDefaultModules = false; # Not optimized for the device

	# Sound
		sound.enable = true; # Only meant for ALSA-based systems? (https://nixos.wiki/wiki/PipeWire)
		hardware.pulseaudio = {
			enable = mkIf config.services.pipewire.enable false; # PipeWire expects this set to false
			package = pkgs.pulseaudioFull;
		};
		security.rtkit.enable = true;
		services.pipewire = {
			enable = true;
			audio.enable = true; # Use PipeWire as the primary sound server
			alsa.enable = true;
			alsa.support32Bit = false; # TBD
			pulse.enable = true;
			jack.enable = true;
		};

	# Printing
		services.printing.enable = false;

	# Hardware Acceleration
		hardware.opengl = {
			enable = true;
			driSupport = true;
			# driSupport32Bit = true; # "Option driSupport32Bit only makes sense on a 64-bit system." ?
		};

	# Platform
		nixpkgs.hostPlatform = "aarch64-linux";
}

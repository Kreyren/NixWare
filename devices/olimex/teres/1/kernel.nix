{ self, config, lib, crossPkgs, ... }:

# Kernel management module for standard OLIMEX Teres-I, tested on Rev.C mainboard

let
	inherit (lib) mkIf mkForce;
in {
	boot.kernelModules = mkForce []; # Do not load any kernel modules
	boot.extraModulePackages = mkForce []; # Do not load any kernel modules

	# TODO(Krey): Lets first get a baseline on the standard kernel
	# boot.kernelPackages = self.inputs.legacyPackages.aarch64-linux.linux_hardened;
	# # Configure a custom kernel
	# boot.kernelPackages = pkgs.linuxPackagesFor
	# 	(let
	# 		baseKernel = crossPkgs.linux_hardened;
	# 	in
	# 		pkgs.linuxManualConfig {
	# 			inherit (baseKernel) src modDirVersion;
	# 			version = "${baseKernel.version}-teres_i";
	# 			kernelPatches = [ ];
	# 			configfile = ./tinykernel.config;
	# 			allowImportFromDerivation = true;
	# 			# extraMakeFlags = [ "yes2modconfig" "dtbs" ]; # Rebuild dtbs and convert on modules
	# 		}
	# 	);

	# nixpkgs.overlays = [
	# 	# FIXME-UPSTREAM(Krey): To avoid failure due to missing root module 'ahci' which is not present on aarch64 (workarounding a nix bug), or is it needed?
	# 	(final: super: {
	# 		makeModulesClosure = x:
	# 			super.makeModulesClosure (x // { allowMissing = true; });
	# 	})

	# 	# CCache
	# 	(mkIf config.programs.ccache.enable (self: super: {
	# 		linuxManualConfig = super.linuxManualConfig.override { stdenv = super.ccacheStdenv; };
	# 	}))
	# ];
}

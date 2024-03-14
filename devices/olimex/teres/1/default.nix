{ self, ... }:

{
	flake.nixosModules."teres_i".imports = [
		self.inputs.nixos-generators.nixosModules.all-formats

		./hardware-configuration.nix
		# ./power-management.nix
		# ./kernel.nix

		# Blocked-by(Krey): https://github.com/nix-community/nixos-generators/issues/317
		# ./generators/sd-aarch64.nix
	];

	flake.nixosConfigurations."teres_i" = self.inputs.nixpkgs.lib.nixosSystem {
		modules = [ self.nixosModules.teres_i ];
	};
}

{
	description = "NixWare";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

		flake-parts.url = "github:hercules-ci/flake-parts";
		mission-control.url = "github:Platonic-Systems/mission-control";
		flake-root.url = "github:srid/flake-root";

		nixos-generators = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs @ { self, ...}:
		inputs.flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				./devices/olimex/teres/1 # Imports OLIMEX Teres-I

				inputs.flake-root.flakeModule
				inputs.mission-control.flakeModule
			];

			systems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];

			perSystem = { system, config, ... }: {
				# FIXME-QA(Krey): Move this to  a separate file somehow?
				# FIXME-QA(Krey): Figure out how to shorten the `inputs.nixpkgs-unstable.legacyPackages.${system}` ?
				## _module.args.nixpkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
				## _module.args.nixpkgs = import inputs.nixpkgs { inherit system; };
				mission-control.scripts = {
					# Editors
					vscodium = {
						description = "VSCodium (Fully Integrated)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs-unstable.legacyPackages.${system}.vscodium}/bin/codium ./default.code-workspace";
					};
					vim = {
						description = "vIM (Minimal Integration, fixme)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.vim}/bin/vim .";
					};
					neovim = {
						description = "Neovim (Minimal Integration, fixme)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.neovim}/bin/nvim .";
					};
					emacs = {
						description = "Emacs (Minimal Integration, fixme)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.emacs}/bin/emacs .";
					};
					# Code Formating
					nixpkgs-fmt = {
						description = "Format Nix Files With The Standard Nixpkgs Formater";
						category = "Code Formating";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt}/bin/nixpkgs-fmt .";
					};
					alejandra = {
						description = "Format Nix Files With The Uncompromising Nix Code Formatter (Not Recommended)";
						category = "Code Formating";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.alejandra}/bin/alejandra .";
					};
				};
				devShells.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
					name = "NixWare-devshell";
					nativeBuildInputs = [
						inputs.nixpkgs.legacyPackages.${system}.bashInteractive # For terminal
						inputs.nixpkgs.legacyPackages.${system}.nil # Needed for linting
						inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt # Nixpkgs formatter
						inputs.nixpkgs.legacyPackages.${system}.git # Working with the codebase
						inputs.nixpkgs.legacyPackages.${system}.fira-code # For liquratures in code editors
						inputs.nixos-generators.packages.${system}.nixos-generate
					];
					inputsFrom = [ config.mission-control.devShell ];
					# Environmental Variables
					#RULES = "./secrets/secrets.nix"; # For ragenix to know where secrets are
				};

				formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
			};
		};
}

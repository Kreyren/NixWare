{ lib, self, ... }:

# Automatic suspension then hibernation for OLIMEX Teres-I
# * Credit: https://gist.githubusercontent.com/mattdenner/befcf099f5cfcc06ea04dcdd4969a221/raw/14d15f8c634dc4cf28b41e76c7924979f35463ea/suspend-and-hibernate.nix

let
	inherit (lib) mkDefault;

	hibernateEnvironment = {
		HIBERNATE_SECONDS = mkDefault "180"; # 3 Min
		HIBERNATE_LOCK = "/var/run/autohibernate.lock";
		HIBERNATE_LOG = "/tmp/autohibernate.log";
	};
in {
	services.logind = {
		powerKey = mkDefault "suspend-then-hibernate"; # Perform suspend-then-hibernate on power button press
		powerKeyLongPress = mkDefault "poweroff"; # Poweroff on long-press ~5 sec, if held for ~10 sec forced halt (depending on bootloader configuration)
		lidSwitch = mkDefault "suspend-then-hibernate"; # While on battery power perform suspend-then-hibernate on lid close
		lidSwitchExternalPower = mkDefault "suspend"; # To speed-up charging suspend if the lid is closed and on external power
	};

	# Managing after-suspend awake
	systemd.services."awake-after-suspend-for-a-time" = {
		description = "Sets up the suspend so that it'll wake for hibernation";
		wantedBy = [ "suspend.target" ];
		before = [ "systemd-suspend.service" ];
		environment = hibernateEnvironment;
		script = ''
			# If external power is NOT connected
			if [ "$(cat /sys/class/power_supply/axp813-ac/online)" = 0 ]; then
				curtime="$(date +%s)" # Get Current Time
				echo "$curtime $1" >> "$HIBERNATE_LOG" # Log auto-hibernations
				echo "$curtime" > "$HIBERNATE_LOCK"
				${self.inputs.nixpkgs.legacyPackages.aarch64-linux.utillinux}/bin/rtcwake --mode no --seconds "$HIBERNATE_SECONDS" # Set RTC Wake-UP Time to HIBERNATE_SECONDS seconds
			else
				echo "System is on AC power, skipping wake-up scheduling for hibernation." >> "$HIBERNATE_LOG"
			fi
		'';
		serviceConfig.Type = "simple";
	};

	# Perform hibernation after timeout
	systemd.services."hibernate-after-recovery" = {
		description = "Hibernates after a suspend recovery due to timeout";
		wantedBy = [ "suspend.target" ];
		after = [ "systemd-suspend.service" ];
		environment = hibernateEnvironment;
		script = ''
			curtime="$(date +%s)"
			sustime="$(cat "$HIBERNATE_LOCK")"

			rm "$HIBERNATE_LOCK" # Remove hibernation lock file

			# If current time MINUS suspension time is greater than HIBERNATE_SECONDS
			if [ "$(($curtime - $sustime))" -ge "$HIBERNATE_SECONDS" ] ; then
				systemctl hibernate # Perform hibernation
			else
				${self.inputs.nixpkgs.utillinux}/bin/rtcwake --mode no --seconds 1 # Set RTC Wake-UP Time to 1 Second
			fi
		'';
		serviceConfig.Type = "simple";
	};
}

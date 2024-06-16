# This module can be used to expose NixOS system metadata to Prometheus.
# It requires the system to be built via flakes.
# In your flake.nix, add this to your NixOS system call:
# mayutils.nixosModules.prometheus-nixos-system-info # Import the mayutils Prometheus NixOS system module
# {
#   monitoring.prometheus-nixos-system-info = {
#     enable = true;
#     system-flake = self;
#   };
# }
# The system-flake attribute will be used to derive the age of the nixpkgs input age.

{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.monitoring.prometheus-nixos-system-info;
  make-fixed-metric = args: ''
    echo '# HELP ${args.name} ${args.help}'
    echo '# TYPE ${args.name} gauge'
    echo '${args.name}{host="${config.networking.hostName}"} ${builtins.toString args.value}'
  '';
  make-dynamic-metric = args: ''
    echo '# HELP ${args.name} ${args.help}'
    echo '# TYPE ${args.name} gauge'
    echo -n '${args.name}{host="${config.networking.hostName}"} '
    ${args.command}
  '';
in {
  options.monitoring.prometheus-nixos-system-info = {
    enable = mkEnableOption "Prometheus adapter for NixOS system version";
    system-flake = mkOption {
      type = types.anything;
    };
    prometheus-text-exporter-directory = mkOption {
      type = types.string;
      default = "/var/lib/prometheus-node-exporter-text-files";
    };
  };

  config =
    mkIf cfg.enable
    {
      system.activationScripts.node-exporter-nixos-system-info = ''
        mkdir -pm 0775 ${cfg.prometheus-text-exporter-directory}
        cd ${cfg.prometheus-text-exporter-directory}

        (
          ${make-fixed-metric {
          name = "nixos_nixpkgs_last_modified_timestamp_secconds";
          help = "Timestamp of the last modification of the nixpkgs system flake input";
          value = cfg.system-flake.inputs.nixpkgs.lastModified;
        }}
          ${make-dynamic-metric {
          name = "nixos_system_generation_counter";
          help = "Current NixOS generation number";
          command = "readlink /nix/var/nix/profiles/system | cut -d- -f2";
        }}
        ) > nixos-system-info.prom.next
        mv nixos-system-info.prom.next nixos-system-info.prom
      '';

      services.prometheus.exporters.node = {
        enable = true;
        enabledCollectors = [
          "textfile"
        ];
        extraFlags = [
          "--collector.textfile.directory=${cfg.prometheus-text-exporter-directory}"
        ];
      };
    };
}

{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.prometheus-remote-storage;
in {
  options.services.prometheus-remote-storage = {
    enable = mkEnableOption "Enable Prometheus remote write to a remote storage adapter for influx etc.";
    influxdb-url = mkOption {
      type = types.str;
      default = "http://localhost:8086";
    };
    influxdb-username = mkOption {
      type = types.str;
      default = "metrics";
    };
    influxdb-pwfile = mkOption {
      type = types.path;
    };
    influxdb-database = mkOption {
      type = types.str;
      example = "metrics";
    };
    prometheus_remote_storage_adapter_pkg = mkPackageOption pkgs "prometheus_remote_storage_adapter" {};
  };

  config = mkIf cfg.enable {
    systemd.services.prometheus_remote_storage_adapter = {
      description = "Remote storage adapter (bridging Prometheus to InfluxDB)";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = "prometheus_remote_storage_adapter";
        Group = "prometheus_remote_storage_adapter";
        DynamicUser = true;

        ExecStart = let
          prometheus_remote_storage_adapter_wrapped = pkgs.writeShellApplication {
            name = "prometheus_remote_storage_adapter_wrapped";
            text = ''
              INFLUXDB_PW=$(cat "${cfg.influxdb-pwfile}")
              export INFLUXDB_PW
              ${cfg.prometheus_remote_storage_adapter_pkg}/bin/prometheus_remote_storage_adapter \
              --influxdb-url="${cfg.influxdb-url}" \
              --influxdb.username="${cfg.influxdb-username}" \
              --influxdb.database="${cfg.influxdb-database}" \
              --web.listen-address="127.0.0.1:9201"
            '';
          };
        in "${prometheus_remote_storage_adapter_wrapped}/bin/prometheus_remote_storage_adapter_wrapped";
      };
    };

    services.prometheus.remoteWrite = [
      {
        url = "http://127.0.0.1:9201";
      }
    ];
  };
}

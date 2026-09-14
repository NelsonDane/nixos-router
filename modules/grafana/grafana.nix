{
  flake.modules.nixos.grafana =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # JSON dashboards live next to this module; bundle them into the store so
      # Grafana's file provider can read them at runtime.
      dashboardsDir = pkgs.runCommand "grafana-dashboards" { } ''
        mkdir -p $out
        cp ${../grafana/dashboards/router.json} $out/
        cp ${../grafana/dashboards/blocky.json} $out/
      '';
    in
    {
      persistence.extraDirectories = [
        "/var/lib/grafana"
        "/var/lib/prometheus2"
      ];
      # Grafana + Prometheus admin password from an agenix secret
      age.secrets.grafanaAdmin = {
        rekeyFile = ../../secrets/grafana.age;
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };

      # Grafana database encryption secret key
      age.secrets.grafanaSecretKey = {
        rekeyFile = ../../secrets/grafanaSecretKey.age;
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };

      # ── Prometheus ────────────────────────────────────────────────────────
      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9090;
        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "127.0.0.1:9100" ];
                labels = {
                  host = "router";
                };
              }
            ];
          }
          {
            job_name = "wireguard";
            static_configs = [
              {
                targets = [ "127.0.0.1:9586" ];
                labels = {
                  instance = "router";
                };
              }
            ];
          }
          {
            job_name = "kea";
            static_configs = [
              {
                targets = [ "127.0.0.1:9547" ];
                labels = {
                  instance = "router";
                };
              }
            ];
          }
          {
            job_name = "blocky";
            static_configs = [
              {
                targets = [ "127.0.0.1:4000" ];
                labels = {
                  instance = "router";
                };
              }
            ];
          }
          {
            job_name = "unbound";
            static_configs = [
              {
                targets = [ "127.0.0.1:9167" ];
                labels = {
                  instance = "router";
                };
              }
            ];
          }
        ];
      };

      # nixpkgs-provided exporters
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9100;
      };

      services.prometheus.exporters.wireguard = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9586;
        interfaces = [ "wg0" ];
      };

      services.prometheus.exporters.kea = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9547;
        targets = [ "/run/kea/kea-dhcp4.socket" ];
      };

      # The exporter module runs as a throwaway DynamicUser which cannot read
      # kea's unix socket (owned by the real kea user). Run it as the kea user.
      systemd.services.prometheus-kea-exporter.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "kea";
        Group = lib.mkForce "kea";
      };

      # Unbound has no prometheus.exporters.* submodule, so run the exporter
      # directly. It talks to unbound's unix control socket (see dns.nix); with
      # a unix:// host the exporter skips TLS, so no cert/key flags are needed.
      systemd.services.prometheus-unbound-exporter = {
        description = "Prometheus exporter for Unbound";
        wantedBy = [ "multi-user.target" ];
        after = [ "unbound.service" ];
        requires = [ "unbound.service" ];
        serviceConfig = {
          ExecStart = toString [
            (lib.getExe pkgs.prometheus-unbound-exporter)
            "-web.listen-address"
            "127.0.0.1:9167"
            "-unbound.host"
            "unix:///run/unbound/unbound.ctl"
          ];
          DynamicUser = false;
          User = "unbound";
          Group = "unbound";
          Restart = "on-failure";
        };
      };

      # ── Grafana ───────────────────────────────────────────────────────────
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            enforce_domain = true;
            enable_gzip = true;
            domain = "grafana.nelsondane.com";
            root_url = "https://grafana.nelsondane.com";
          };
          security = {
            # Read admin password from the decrypted agenix secret.
            admin_password = "\$__file{${config.age.secrets.grafanaAdmin.path}}";
            secret_key = "\$__file{${config.age.secrets.grafanaSecretKey.path}}";
          };
          "auth.anonymous" = {
            # Read-only viewer so the dashboards are reachable without login.
            enabled = true;
            org_role = "Viewer";
            org_name = "Main Org.";
          };
          users.allow_sign_up = false;
          analytics.reporting_enabled = false;
        };
        provision = {
          datasources.settings = {
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
              }
            ];
          };
          dashboards.settings = {
            providers = [
              {
                name = "router";
                type = "file";
                options = {
                  path = toString dashboardsDir;
                  foldersFromFilesStructure = false;
                };
              }
            ];
          };
        };
      };
    };
}

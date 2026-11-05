let
  domain = "redbarn.casa";
  subdomains = {
    "ha" = "http://127.0.0.1:8123";
    "netbox" = "http://127.0.0.1:8000";
    "unifi" = "https://127.0.0.1:8443";
  };
in
{
  flake.modules.nixos.nginx = { config, lib, ... }: {
    # https://wiki.nixos.org/wiki/Nginx
    services.nginx = {
      enable = true;

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.genAttrs (lib.attrNames subdomains) (subdomain: {
        serverName = "${subdomain}.${domain}";
        useACMEHost = "${domain}";
        forceSSL = true;
        # Strict HSTS once we always serve over TLS
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        '';
        locations = {
          "/" = {
            proxyPass = subdomains.${subdomain};
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        }
        # NetBox requires nginx to serve /static/ directly from STATIC_ROOT
        // lib.optionalAttrs (subdomain == "netbox") {
          "/static/".alias = config.services.netbox.settings.STATIC_ROOT;
        };
      });
    };

    # https://wiki.nixos.org/wiki/ACME
    age.secrets.cloudflare-redbarn.rekeyFile = ../secrets/cloudflare-redbarn.age;
    security.acme = {
      acceptTerms = true;
      certs."${domain}" = {
        inherit domain;
        extraDomainNames = [ "*.${domain}" ];
        group = "nginx";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = config.age.secrets.cloudflare-redbarn.path;
        reloadServices = [ "nginx" ];
      };
    };

    persistence.extraDirectories = [ "/var/lib/acme" ];
  };
}

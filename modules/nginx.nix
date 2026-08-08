let
  domain = "nelsondane.com";
  subdomains = {
    "unifi" = "https://127.0.0.1:8443";
    "ha" = "http://127.0.0.1:8123";
    "*.cluster" = "http://10.0.2.50:80";
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
        locations."/" = {
          proxyPass = subdomains.${subdomain};
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      });
    };

    # https://wiki.nixos.org/wiki/ACME
    age.secrets.cloudflare.rekeyFile = ../secrets/cloudflare.age;
    security.acme = {
      acceptTerms = true;
      certs."${domain}" = {
        inherit domain;
        extraDomainNames = [
          "*.${domain}"
          "*.cluster.${domain}"
        ];
        group = "nginx";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = config.age.secrets.cloudflare.path;
        reloadServices = [ "nginx" ];
      };
    };

    persistence.extraDirectories = [ "/var/lib/acme" ];
  };
}

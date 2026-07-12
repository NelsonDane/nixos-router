{ lib, ... }:
let
  domain = "nelsondane.com";
  subdomains = {
    "opnsense" = "https://10.0.2.1:443";
    "datto" = "https://10.0.2.5:8006";
    "unifi" = "https://localhost:8443";
    "ha" = "http://10.0.2.20:8123";
    "*.cluster" = "http://10.0.2.50:80";
  };
in
{
  flake.modules.nixos.nginx = {
    # https://wiki.nixos.org/wiki/Nginx
    services.nginx = {
      enable = true;

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      virtualHosts = lib.genAttrs (lib.attrNames subdomains) (subdomain: {
        serverName = "${subdomain}.${domain}";
        useACMEHost = "${domain}";
        forceSSL = true;
        locations."/" = {
          proxyPass = subdomains.${subdomain};
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      });
    };

    # https://wiki.nixos.org/wiki/ACME
    # age.secrets.cloudflare.rekeyFile = ../../secrets/cloudflare.age;
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
        # environmentFile = config.age.secrets.cloudflare.path;
        reloadServices = [ "nginx" ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}

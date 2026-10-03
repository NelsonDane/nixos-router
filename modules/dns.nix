{
  flake.modules.nixos.dns = {
    # https://casualcompute.com/posts/ad-blocking-recursive-dns-for-nixos/

    # Loopback address for DNS
    systemd.network.networks."00-lo" = {
      matchConfig.Name = "lo";
      networkConfig.Address = "127.0.0.8/8";
    };

    # Unbound DNS caching server
    services.unbound = {
      enable = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      settings.server = {
        interface = [ "127.0.0.8" ];
        do-ip4 = true;
        do-ip6 = false;

        # Blocky does caching
        prefetch = true;
        cache-max-ttl = 3600;
        cache-max-negative-ttl = 300;
        serve-original-ttl = true;
      };
    };

    # Blocky DNS server
    services.blocky = {
      enable = true;
      settings = {
        ports = {
          dns = [
            "10.0.2.1:53"
            "127.0.0.1:53"
          ];
          # Prometheus metrics + API on loopback only
          http = [ "127.0.0.1:4000" ];
        };
        prometheus = {
          enable = true;
          path = "/metrics";
        };
        connectIPVersion = "v4";

        upstreams = {
          strategy = "strict";
          groups.default = [
            "127.0.0.8" # Unbound
            "1.1.1.1" # Cloudflare
            "9.9.9.9" # Quad9
          ];
        };

        # Split-horizon: resolve locally-served subdomains to the router
        # instead of reaching out to the public records (Oracle jumphost).
        customDNS = {
          mapping = {
            "unifi.redbarn.casa" = "10.0.2.1";
            "ha.redbarn.casa" = "10.0.2.1";
          };
        };

        blocking = {
          denylists = {
            "stevenblack" = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
            "big.oisd" = [ "https://big.oisd.nl/" ];
          };
          clientGroupsBlock.default = [
            "stevenblack"
            "big.oisd"
          ];

          # Blocky needs Unbound up to resolve the block list
          loading = {
            downloads = {
              attempts = 8;
              cooldown = "2s";
            };
            strategy = "fast";
            concurrency = 1;
          };
        };

        caching = {
          prefetching = true;
          minTime = "1m";
        };
      };
    };
  };
}

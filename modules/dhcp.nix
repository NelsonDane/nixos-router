{
  flake.modules.nixos.dhcp = {
    # https://casualcompute.com/posts/creating-a-basic-router-using-nixos/#implementing-dhcp
    services.kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config.interfaces = [
          "lan"
          "guest"
          "iot"
        ];

        valid-lifetime = 4000;
        renew-timer = 1000;
        rebind-timer = 2000;

        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
          lfc-interval = 3600;
        };

        subnet4 = [
          {
            id = 1;
            subnet = "10.0.2.0/24";
            pools = [ { pool = "10.0.2.100 - 10.0.2.254"; } ];
            option-data = [
              {
                name = "routers";
                data = "10.0.2.1";
              }
              {
                name = "domain-name-servers";
                data = "10.0.2.1";
              }
            ];
          }
          {
            id = 2;
            subnet = "10.0.3.0/24";
            pools = [ { pool = "10.0.3.10 - 10.0.3.254"; } ];
            option-data = [
              {
                name = "routers";
                data = "10.0.3.1";
              }
              {
                name = "domain-name-servers";
                data = "10.0.2.1";
              }
            ];
          }
          {
            id = 3;
            subnet = "10.0.4.0/24";
            pools = [ { pool = "10.0.4.10 - 10.0.4.254"; } ];
            option-data = [
              {
                name = "routers";
                data = "10.0.4.1";
              }
              {
                name = "domain-name-servers";
                data = "10.0.2.1";
              }
            ];
          }
        ];
      };
    };
  };
}

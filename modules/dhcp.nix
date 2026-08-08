{
  flake.modules.nixos.dhcp = { lib, ... }: {
    # https://casualcompute.com/posts/creating-a-basic-router-using-nixos/#implementing-dhcp
    systemd.services.kea-dhcp4-server.serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "15s";
      DynamicUser = lib.mkForce false;
    };

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
            reservations = [
              # TP-Link Switch
              {
                hw-address = "34:60:f9:06:77:c8";
                ip-address = "10.0.2.2";
              }
              # Desktop PC
              {
                hw-address = "a8:a1:59:bc:e4:96";
                ip-address = "10.0.2.15";
              }
              # Cluster Node 1
              {
                hw-address = "e0:70:ea:cd:a6:2c";
                ip-address = "10.0.2.51";
              }
              # Cluster Node 2
              {
                hw-address = "e0:70:ea:cd:a9:38";
                ip-address = "10.0.2.52";
              }
              # Cluster Node 3
              {
                hw-address = "e0:70:ea:a5:e8:bc";
                ip-address = "10.0.2.53";
              }
              # Cluster Node 4
              {
                hw-address = "bc:e9:2f:88:e2:39";
                ip-address = "10.0.2.54";
              }
              # Work Laptop
              {
                hw-address = "ac:b4:80:1c:1a:b8";
                ip-address = "10.0.2.77";
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

    persistence.extraDirectories = [ "/var/lib/kea" ];
  };
}

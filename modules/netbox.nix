{
  flake.modules.nixos.netbox = { pkgs, ... }: {
    services.netbox = {
      enable = true;
      package = pkgs.netbox_4_7;
      bind = "127.0.0.1:8000";
    };

    # Allow nginx to read NetBox's static files
    users.users.nginx.extraGroups = [ "netbox" ];

    persistence.extraDirectories = [ "/var/lib/netbox" ];
  };
}

{
  flake.modules.nixos.users = _: {
    # User
    users.users.ndane = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINV6PE0WZp/heKzffIJzaJjN/A0anqO4zFxaMwsxmAS9 ndane@macbook"
      ];
    };
    security.sudo.wheelNeedsPassword = false;

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}

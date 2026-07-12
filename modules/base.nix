_: {
  flake.modules.nixos.base = {
    # Nix settings
    nixpkgs.config.allowUnfree = true;
    nix = {
      enable = true;
      # Garbage collection + store optimise
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Other cache locations
        always-allow-substitutes = true;
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        ];
      };
    };

    # Timezone
    time.timeZone = "America/New_York";

    # Disable docs
    documentation = {
      enable = false;
      doc.enable = false;
      info.enable = false;
      man.enable = false;
    };
  };
}

_: {
  flake.modules.nixos.age =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    with lib;
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ];

      options.age.hostPubkey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The system's public key for age encryption.";
      };

      config = {
        age.rekey = {
          hostPubkey = mkIf (config.age.hostPubkey != null) config.age.hostPubkey;
          masterIdentities = [ ../secrets/yubikey.pub ];
          storageMode = "local";
          localStorageDir = ../secrets/rekeyed;
        };
        environment.systemPackages = mkIf (config.age.hostPubkey != null) [
          inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
}

{
  inputs,
  lib,
  config,
  ...
}:
let
  sys = "x86_64-linux";
  inherit (inputs) deploy-rs;
in
{
  # https://github.com/serokell/deploy-rs
  flake.deploy.nodes = {
    router = {
      hostname = "10.0.2.1";
      sshUser = "ndane";
      sshOpts = [
        "-i"
        "~/.ssh/router"
      ];
      remoteBuild = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${sys}.activate.nixos config.flake.nixosConfigurations.router;
      };
    };
  };

  perSystem = { system, ... }: {
    apps.deploy-rs = {
      type = "app";
      program = "${deploy-rs.packages.${system}.deploy-rs}/bin/deploy";
    };
    checks = lib.optionalAttrs (system == sys) (deploy-rs.lib.${sys}.deployChecks config.flake.deploy);
  };
}

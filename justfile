export NH_SHOW_ACTIVATION_LOGS := "1"

default:
  @just --list

fmt:
  nix fmt

rekey:
  nix shell nixpkgs#age-plugin-yubikey -c nix run .#agenix-rekey.aarch64-darwin.rekey -- -a

check:
  nix flake check

build:
  nix build .#nixosConfigurations.router.config.system.build.toplevel --no-link

deploy:
  NIX_SSHOPTS="-i ~/.ssh/router" nh os switch .#router --target-host ndane@10.0.2.1 --build-host ndane@10.0.2.1 --elevation-strategy passwordless

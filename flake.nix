{
  description = "mayjs NixOS helpers for homeserver applications";

  inputs = {
  };

  outputs = {
    nixpkgs,
    self,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    formatter.x86_64-linux = pkgs.alejandra;
    nixosModules = {
      prometheus-nixos-system-info = import ./modules/prometheus-nixos-system-info.nix;
    };
  };
}

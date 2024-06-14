{
  description = "A very basic flake";

  inputs = {
  };

  outputs = {
    nixpkgs,
    self,
  }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosModules = {
      prometheus-nixos-system-info = import ./modules/prometheus-nixos-system-info.nix;
    };
  };
}

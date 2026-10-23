{
  description = "Nix overlay providing packages that are not yet available in upstream nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      overlays.default = import ./overlay.nix;

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        in
        nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) (
          import ./pkgs { inherit (pkgs) callPackage; }
        )
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Build the packages in `nix flake check`, including on CI.
      checks = self.packages;

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.formatter.${system}
              pkgs.nixfmt
            ];
          };
        }
      );
    };
}

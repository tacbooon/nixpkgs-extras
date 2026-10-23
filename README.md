# nixpkgs-extras

A Nix overlay repository providing packages that are not yet available in upstream [NixOS/nixpkgs](https://github.com/nixos/nixpkgs).

## Usage

You can add this repository as an input to your `flake.nix` and use its overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-extras = {
      url = "github:tacbooon/nixpkgs-extras";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-extras, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixpkgs-extras.overlays.default ];
      };
    in {
      # Use packages provided by the overlay via pkgs.<package-name>
    };
}
```

Or consume packages directly from flake outputs:

```bash
nix run github:tacbooon/nixpkgs-extras#<package-name>
```

## Packages

| Package | Version | Description |
| --- | --- | --- |

## Adding Packages

1. Create a package directory under `pkgs/<package-name>/default.nix`.
2. Expose the package in `pkgs/default.nix`:

   ```nix
   { callPackage }:
   {
     <package-name> = callPackage ./<package-name> { };
   }
   ```

3. Add the package to the `Packages` table in `README.md`.

## Updating Packages

Update the version and the source hash with [`nix-update`](https://github.com/Mic92/nix-update):

```bash
nix run nixpkgs#nix-update -- --flake <package-name>
```

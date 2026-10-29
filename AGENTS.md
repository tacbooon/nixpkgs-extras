# AGENTS.md

Nix flake that provides an overlay of packages not yet in nixpkgs.

## Workflow

- When you add or bump a package, update `pkgs/default.nix` (keep entries alphabetical) and the `Packages` table in `README.md`.
- Get hashes from a `lib.fakeHash` build. Never guess them.
- Before you finish, run `nix fmt` and `nix flake check -L`, which builds every package through `checks`. These need network access.
- Write packages in current nixpkgs style: `finalAttrs`, `tag =`, `env.NIX_CFLAGS_COMPILE`.
- Only update `flake.lock` when the task asks for it, and do it in its own commit.

## Package specific workflows

- When you bump `lute`, regenerate `pkgs/lute/deps.nix` with `pkgs/lute/update-deps.sh`.

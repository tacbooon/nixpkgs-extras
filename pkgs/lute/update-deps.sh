#!/usr/bin/env bash
# Regenerate deps.nix from the dependency revisions that upstream Lute pins in
# its `extern/*.tune` files.
#
# Usage: pkgs/lute/update-deps.sh [VERSION]
#
# VERSION defaults to the version in ./default.nix, so the usual flow is
#
#   nix run nixpkgs#nix-update -- --flake lute
#   pkgs/lute/update-deps.sh
set -euo pipefail

for cmd in curl jq nix; do
  if ! command -v "$cmd" >/dev/null; then
    echo "error: $cmd is required, but not found in PATH" >&2
    exit 1
  fi
done

pkgdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
upstream="https://github.com/luau-lang/lute"
raw="https://raw.githubusercontent.com/luau-lang/lute"

version="${1:-$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$pkgdir/default.nix")}"
if [[ -z "$version" ]]; then
  echo "error: cannot read the version from $pkgdir/default.nix" >&2
  exit 1
fi

sources="$(mktemp)"
tune="$(mktemp)"
out="$(mktemp)"
trap 'rm -f "$sources" "$tune" "$out"' EXIT

curl -fsSL "https://api.github.com/repos/luau-lang/lute/contents/extern?ref=v$version" |
  jq -r '.[].name' | LC_ALL=C sort >"$sources"

{
  printf '%s\n' \
    "# Source copies of the dependencies pinned in upstream Lute's" \
    "# \`extern/*.tune\` files. Regenerate this file with ./update-deps.sh" \
    "# after bumping the version. Keep these in sync with:" \
    "# $upstream/tree/v$version/extern" \
    "#" \
    "# Lute is built against these copies rather than against nixpkgs' versions, so" \
    "# fixes for them (security fixes included) only reach this package when it is" \
    "# bumped to a version that pins newer revisions. The licenses of these" \
    "# dependencies are listed in meta.license of ./default.nix." \
    "{ linkFarm, fetchFromGitHub }:" \
    'linkFarm "lute-deps" ['
} >"$out"

while read -r file; do
  curl -fsSL "$raw/v$version/extern/$file" -o "$tune"

  field() { sed -n "s/^$1 = \"\([^\"]*\)\"\$/\1/p" "$tune"; }
  name="$(field name)"
  remote="$(field remote)"
  branch="$(field branch)"
  revision="$(field revision)"
  if [[ -z "$name" || -z "$remote" || -z "$revision" ]]; then
    echo "error: cannot parse $file" >&2
    exit 1
  fi

  if [[ $remote != https://github.com/* ]]; then
    echo "error: $file pins $remote, but only GitHub remotes are supported" >&2
    exit 1
  fi

  slug="${remote#https://github.com/}"
  slug="${slug%.git}"
  owner="${slug%%/*}"
  repo="${slug#*/}"

  echo "fetching $name at $revision" >&2
  hash="$(nix store prefetch-file --unpack --json \
    "https://github.com/$owner/$repo/archive/$revision.tar.gz" | jq -r .hash)"

  {
    if [[ -n "$branch" ]]; then
      printf '  # extern/%s (branch %s)\n' "$file" "$branch"
    else
      printf '  # extern/%s\n' "$file"
    fi
    printf '  {\n'
    printf '    name = "%s";\n' "$name"
    printf '    path = fetchFromGitHub {\n'
    printf '      owner = "%s";\n' "$owner"
    printf '      repo = "%s";\n' "$repo"
    printf '      rev = "%s";\n' "$revision"
    printf '      hash = "%s";\n' "$hash"
    printf '    };\n'
    printf '  }\n'
  } >>"$out"
done <"$sources"

printf ']\n' >>"$out"
mv "$out" "$pkgdir/deps.nix"
echo "wrote $pkgdir/deps.nix for lute $version" >&2

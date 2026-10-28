# Source copies of the dependencies pinned in upstream Lute's
# `extern/*.tune` files. Regenerate this file with ./update-deps.sh
# after bumping the version. Keep these in sync with:
# https://github.com/luau-lang/lute/tree/v1.0.0/extern
#
# Lute is built against these copies rather than against nixpkgs' versions, so
# fixes for them (security fixes included) only reach this package when it is
# bumped to a version that pins newer revisions. The licenses of these
# dependencies are listed in meta.license of ./default.nix.
{ linkFarm, fetchFromGitHub }:
linkFarm "lute-deps" [
  # extern/boringssl.tune (branch 0.20250415.0)
  {
    name = "boringssl";
    path = fetchFromGitHub {
      owner = "google";
      repo = "boringssl";
      rev = "2b44a3701a4788e1ef866ddc7f143060a3d196c9";
      hash = "sha256-/GZutq286F3gwQ3UhYjuR20bXzbqo4FxiC7E0yt5T60=";
    };
  }
  # extern/curl.tune (branch curl-8_13_0)
  {
    name = "curl";
    path = fetchFromGitHub {
      owner = "curl";
      repo = "curl";
      rev = "1c3149881769e7bd79b072e48374e4c2b3678b2f";
      hash = "sha256-huAGWNm2rYBmgzUuYQ21IYp2skyQECelEkXPMBJY3cE=";
    };
  }
  # extern/libsodium.tune (branch 1.0.20-RELEASE)
  {
    name = "libsodium";
    path = fetchFromGitHub {
      owner = "jedisct1";
      repo = "libsodium";
      rev = "9511c982fb1d046470a8b42aa36556cdb7da15de";
      hash = "sha256-ZPVzKJZRglZT2EJKqdBu94I4TRrF5sujSglUR64ApWA=";
    };
  }
  # extern/libuv.tune (branch v1.50.0)
  {
    name = "libuv";
    path = fetchFromGitHub {
      owner = "libuv";
      repo = "libuv";
      rev = "8fb9cb919489a48880680a56efecff6a7dfb4504";
      hash = "sha256-1Z/zf4qZYDM5upHdRtc1HGpHaGTRHm147azJZ0pT5pU=";
    };
  }
  # extern/luau.tune (branch 0.716)
  {
    name = "luau";
    path = fetchFromGitHub {
      owner = "luau-lang";
      repo = "luau";
      rev = "4ca11dbc3b31ddf27ee8ec1ab6c036676de9f240";
      hash = "sha256-nfXJ16zkw9snA6dByPbP+OntPC4qXq5DK9ZnN5pvV98=";
    };
  }
  # extern/uSockets.tune (branch v0.8.8)
  {
    name = "uSockets";
    path = fetchFromGitHub {
      owner = "uNetworking";
      repo = "uSockets";
      rev = "833497e8e0988f7fd8d33cd4f6f36056c68d225d";
      hash = "sha256-ZlyY2X0aDdjfV0zjcecOLaozwp1crDibx6GBbUnDyAk=";
    };
  }
  # extern/uWebSockets.tune (branch v20.74.0)
  {
    name = "uWebSockets";
    path = fetchFromGitHub {
      owner = "uNetworking";
      repo = "uWebSockets";
      rev = "c445faa38125bf782eed3fec97f83b4733c7fb91";
      hash = "sha256-BEArW6TILz1Z39rjkge1PTz3defKwgITO6nBpyS13b8=";
    };
  }
  # extern/zlib.tune (branch v1.3.1)
  {
    name = "zlib";
    path = fetchFromGitHub {
      owner = "madler";
      repo = "zlib";
      rev = "51b7f2abdade71cd9bb0e7a373ef2610ec6f9daf";
      hash = "sha256-TkPLWSN5QcPlL9D0kc/yhH0/puE9bFND24aj5NVDKYs=";
    };
  }
]

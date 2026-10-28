{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  cmake,
  ninja,
  gitMinimal,
  writableTmpDirAsHomeHook,
}:

let
  externDeps = callPackage ./deps.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lute";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "luau-lang";
    repo = "lute";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g52fa/dQ4/Fk+NwbckrPtSkEjjql/+EU3tHsiV4jH40=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    gitMinimal # `tools/luthier.luau` runs `git --version` at the top level.
    ninja
  ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  env.NIX_CFLAGS_COMPILE = lib.concatStringsSep " " (
    lib.optionals stdenv.cc.isGNU [
      "-Wno-error=stringop-overflow"
      "-Wno-error=array-bounds"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=character-conversion"
    ]
  );

  preConfigure = ''
    # Refuse to build with copies that do not match the revisions upstream
    # pins, so a forgotten `update-deps.sh` cannot hide behind a successful
    # build.
    for revision in $(grep -h '^revision = ' extern/*.tune | cut -d'"' -f2); do
      if ! grep -q "$revision" ${./deps.nix}; then
        echo "error: deps.nix does not pin $revision from extern/*.tune" >&2
        echo "       run pkgs/lute/update-deps.sh after bumping the version" >&2
        exit 1
      fi
    done

    # Keep upstream's extern/*.tune files: they document the pinned revisions.
    cp -rL ${externDeps}/. extern/
    chmod -R u+w extern

    # Populate the generated sources with empty stubs so that the initial
    # stdless build can succeed. `luthier generate` replaces them afterwards.
    mkdir -p lute/std/src/generated
    cp ./tools/templates/std_impl.cpp ./lute/std/src/generated/modules.cpp
    cp ./tools/templates/std_header.h ./lute/std/src/generated/modules.h

    mkdir -p lute/cli/generated
    cp ./tools/templates/cli_impl.cpp ./lute/cli/generated/commands.cpp
    cp ./tools/templates/cli_header.h ./lute/cli/generated/commands.h

    mkdir -p lute/batteries/generated
    cp ./tools/templates/batteries_impl.cpp ./lute/batteries/generated/batteries.cpp
    cp ./tools/templates/batteries_header.h ./lute/batteries/generated/batteries.h

    mkdir -p lute/definitions/src/generated
    cp ./tools/templates/definitions_impl.cpp ./lute/definitions/src/generated/modules.cpp
    cp ./tools/templates/definitions_header.h ./lute/definitions/src/generated/modules.h
  '';

  # The setup hook of cmake only adds `-GNinja` when `buildPhase` is
  # `ninjaBuildPhase`, which this package replaces.
  cmakeFlags = [ "-GNinja" ];

  buildPhase = ''
    runHook preBuild

    buildDir="$(pwd)"
    srcRoot="$NIX_BUILD_TOP/$sourceRoot"

    # Bootstrap a stdless `lute` and use it to embed the Luau sources.
    ninja -j"$NIX_BUILD_CORES" lute/cli/lute
    pushd "$srcRoot"
    "$buildDir/lute/cli/lute" tools/luthier.luau generate
    popd

    ninja -j"$NIX_BUILD_CORES" lute/cli/lute

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    buildDir="$(pwd)"
    srcRoot="$NIX_BUILD_TOP/$sourceRoot"

    ninja -j"$NIX_BUILD_CORES" tests/lute-tests

    # The doctests and standard library tests have to be run from the source root.
    pushd "$srcRoot"
    "$buildDir/tests/lute-tests"
    "$buildDir/lute/cli/lute" test
    popd

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 lute/cli/lute $out/bin/lute

    runHook postInstall
  '';

  meta = {
    description = "Standalone Luau runtime for general-purpose programming";
    homepage = "https://lute.luau.org";
    changelog = "https://github.com/luau-lang/lute/releases/tag/v${finalAttrs.version}";
    # Lute builds the dependencies in ./deps.nix instead of nixpkgs' ones, so
    # their licenses are listed here as well.
    license = with lib.licenses; [
      asl20 # boringssl, uSockets, uWebSockets
      curl
      isc # libsodium
      mit # lute, luau, libuv
      zlib
    ];
    mainProgram = "lute";
    platforms = lib.platforms.unix;
  };
})

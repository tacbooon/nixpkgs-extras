{
  bashInteractive,
  buildGoModule,
  fetchFromGitHub,
  gitMinimal,
  lib,
  nix-update-script,
  nodejs,
  shellcheck,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "jactionlint";
  version = "2.3.0";

  subPackages = [ "cmd/jactionlint" ];

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "jactionlint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/gCh+9NmRDsoqrcLl287qxmpiLnb2hF3vb2KTNP+BXM=";
  };

  vendorHash = "sha256-SnP9Siop3zgGrVMuHU2IOqDkPKnfyJZVxUB/iBV8hIA=";

  ldflags = [
    "-X github.com/jdx/jactionlint/v2.version=${finalAttrs.version}"
    "-X github.com/jdx/jactionlint/v2.installedFrom=nix"
  ];

  # `checkPhase` only tests `subPackages`, but the tests live in the root
  # package, so add it to the packages under test. `node` and `shellcheck` are
  # used by the tests, `bashInteractive` provides `complete`/`compgen`.
  nativeCheckInputs = [
    bashInteractive
    gitMinimal
    nodejs
    shellcheck
  ];

  preCheck = ''
    subPackages+=(".")

    # The tests expect the version of a `go test` binary, not the one set by
    # our release `ldflags`.
    ldflags=()
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Static checker for GitHub Actions workflow files";
    homepage = "https://github.com/jdx/jactionlint";
    changelog = "https://github.com/jdx/jactionlint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "jactionlint";
  };
})

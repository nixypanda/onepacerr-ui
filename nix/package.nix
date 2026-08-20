{
  buildNpmPackage,
  elmPackages,
  lib,
  runCommand,
}:

let
  registry = runCommand "onepacerr-ui-elm-registry.dat" { } ''
    base64 --decode ${./registry.dat.gz.b64} | gzip --decompress > $out
  '';
in
buildNpmPackage {
  pname = "onepacerr-ui";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = ../.;
    filter =
      path: _type:
      !builtins.elem (baseNameOf path) [
        ".direnv"
        ".git"
        "README.md"
        "PROGRESS.md"
        "api-examples"
        "dist"
        "elm-stuff"
        "flake.lock"
        "flake.nix"
        "lol.json"
        "nix"
        "node_modules"
        "tests"
      ];
  };

  npmDepsHash = "sha256-6AboZCJfdluFqOGwxZCm3XqSQIqU424R9/0NennDPmQ=";
  npmRebuildFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ elmPackages.elm ];

  postConfigure = elmPackages.fetchElmDeps {
    elmPackages = import ./elm-srcs.nix;
    elmVersion = elmPackages.elm.version;
    registryDat = registry;
  };

  npmBuildScript = "build";
  dontNpmPrune = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/onepacerr-ui
    cp -R dist/. $out/share/onepacerr-ui/
    runHook postInstall
  '';

  meta = {
    description = "Web dashboard for OnePacerr";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}

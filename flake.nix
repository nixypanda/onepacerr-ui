{
  description = "Web UI for OnePacerr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        onepacerr-ui = pkgs.callPackage ./nix/package.nix { };
      in
      {
        packages = {
          default = onepacerr-ui;
          frontend = onepacerr-ui;
          inherit onepacerr-ui;
        };

        checks.default = onepacerr-ui;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            elmPackages.elm
            elmPackages.elm-format
            elmPackages.elm-test-rs
          ];

          shellHook = ''
            echo "onepacerr-ui dev shell"
          '';
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}

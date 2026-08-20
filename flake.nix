{
  description = "Web UI for OnePacerr";

  inputs = {
    # 26.05 is the last nixpkgs line supporting the deployment's Intel Mac
    # development host while still providing the Linux package used in NixOS.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
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
